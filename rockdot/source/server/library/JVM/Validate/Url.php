<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2012, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc extends JVM_Validate_Abstract for concrete implementation
 * validates if input is a valid url
 * @see http://www.w3.org/Addressing/URL/url-spec.txt
 * 
 * @author          joerg.diterlizzi
 * @version         
 * @lastmodified:   
 * @copyright       Copyright (c) Jung von Matt / Neckar
 * @package         JVM_Validate
 *
 * @dependencies
 * @import: JVM_Validate_Exception
 * @import: JVM_Validate_Abstract	 
 */
require_once('JVM/Validate/Exception.php');
require_once('JVM/Validate/Abstract.php');
	
class JVM_Validate_Url extends JVM_Validate_Abstract{	
	/*	+-----------------------------------------------------------------------------------+
	| 	class-member-vars
	+-----------------------------------------------------------------------------------+  */	
	/**
	* are allowInternational urls (specialschares)
	* @var boolean
	*/
	private $allowInternational;
	
	/**
	* are allowInternal urls (no scheme and host) allowed
	* @var boolean
	*/
	private $allowInternal;

	/**
	* defines valid schemes
	* @var boolean
	*/
	private $_allowedSchemes = array(
		'http', 
		'https'
	);
	
	/**
	* @see http://www.w3.org/Addressing/URL/url-spec.txt
	* @notice for info only
	* valid schemes 
	* @var array
	*/
	private $_validSchemes = array(
		'http', 		//Hypertext Transfer Protocol 
		'https', 		//Hypertext Transfer Protocol SSL
		'ftp', 			//File Transfer protocol 
		'gopher',  		//The Gopher protocol 
		'mailto',	 	//Electronic mail address 
		'mid' ,    	 	//Message identifiers for electronic mail 
		'cid', 			//Content identifiers for MIME body part             
		'news', 		//Usenet news             
		'nntp', 		//Usenet news for local NNTP access only             
		'prospero', 	//Access using the prospero protocols            
		'telnet', 		//Reference to interactive sessions
		'rlogin', 		//Reference to interactive sessions
		'tn3270',   	//Reference to interactive sessions 
		'wais'			//Wide Area Information Servers 
	);
	
	/**
	* set an age specific default message
	* @var string
	*/
	protected $message = 'invalid url';
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @description
	* overwrites parents empty construct
	*	
	* @input-required
	* @param $min 			:int
	* @param $max 			:int
	*	
	* @input-optional
	* @param $inclusive 	:boolean
	*
	* @return none
	*
	* @access public
	*/
	public function __construct($allowInternational = false, $allowInternal = false, array $_allowedSchemes = array('http', 'https')){
		if(!is_bool($allowInternational)){
			throw new JVM_Validate_Exception('allowInternational must be type of string');	
		}
		$this->allowInternational = $allowInternational;
		if(!is_bool($allowInternal)){
			throw new JVM_Validate_Exception('allowInternal must be type of string');	
		}
		$this->allowInternal = $allowInternal;
		$this->_allowedSchemes = $_allowedSchemes;
	}
	
	/**
	* @desc 
	* abstract inherited method defined in JVM_Validate_Abstract must be overridden
	* validates allowInternal value an returns a boolean
	* NOTICE: does not validate if local/inernal url exists
	*
	* @input-required
	* @param $value :mixed  //the tested value
	*
	* @return boolean	
	*
	* @access public
	*/
	public function isValid($value){ 
		if(!is_string($value) || empty($value)){
			return false;	
		}
		//internal url
		if($this->allowInternal === true && $value[0] === '/'){
			//if(preg_match('/^\/(([\pL0-9\,\+\.\-_])|([\pL\._\-0-9\,]\/)|(\?[\pL\[\]\/0-9\.\,\?\+&%#\=~_\-\"\']*([\pL\[\]\/0-9\.\,\?\+&%#\=~_\-\"\'])))*$/u', $value, $match)){ //'/^\/($|[\pL\[\]\/0-9\.\,\?\+&%#\=~_\-\"\']*)$/u'
			if(stream_is_local($value)){
				return true;		
			}
			return false;
		}
		//external url
		else{
			$scheme = @parse_url($value, PHP_URL_SCHEME);
			// check for allowed schemes if _allowedSchemes was set
			if(!empty($this->_allowedSchemes) && (empty($scheme) || !in_array($scheme, $this->_allowedSchemes))){
				return false;	
			}
			if($this->allowInternational === true){
				//external url allowInternationalized domain names (containing non-ASCII characters) will fail 
				//result: if filter var and ignore non-ASCII
				$value = iconv(@mb_detect_encoding($value), "ASCII//IGNORE", $value);
				if($value === false){
					//reset the filtered value
					
					return false;		
				}
			}
			//!strstr($value, '..') && !strstr($value, '/./') aviods filter_var-bug http://www..fe , http://www././
			if(filter_var($value, FILTER_VALIDATE_URL) !== false && !strstr($value, '..') && !strstr($value, '/./')){
				//reset the filtered value
					 
				return true;
			}
		}
	return false;
	}

}