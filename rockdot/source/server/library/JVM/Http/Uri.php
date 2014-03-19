<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2011, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc builds and modifies urls
 * http://username:password@domain.de/path/?querystring[0]=1#fragment
 *
 * @notice if working with internla/local urls class does not validate if local/inernal url exists
 * 
 * @author          joerg.diterlizzi
 * @version         
 * @lastmodified:   
 * @copyright       Copyright (c) Jung von Matt / Neckar
 * @package         JVM_Http
 *
 * @dependencies
 * @import: JVM_Http_Exception	 
 */
require_once('JVM/Http/Exception.php');
require_once('JVM/Validate/Url.php');
 
class JVM_Http_Uri{
/*  +-----------------------------------------------------------------------------------+
	| 	class member-vars
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @desc uri
	* @var  :string
	* @access : protected
	*/	
	private $uri = NULL;
	
	/**
	* query string prefix
	* @var  :array
	*/
	private $prefix = 'JVM_';
	
	/**
	* query string separator (& &amp: /)
	* @var  :array
	*/
	private $separator = '&';
	
	/**
	* flag is rewrite
	* @var  :boolean
	*/
	private $isRewriteUrl = false;	

	/**
	* are internal urls allowed 
	* @var  :boolean
	*/
	private $allowInternal = true;	
	
	/**
	* are international urls allowed 
	* @var  :boolean
	*/
	private $allowInternational = true;
	
	/**
	* is the url internal
	* @var  :array
	*/
	private $isInternal = false;	
		
	/**
	* all url parts (scheme host usw)
	* @var  :array
	*/		
	private $_components = array();
	
	/**
	* query string parameter
	* @var  :array
	*/
	private $_queryParams = array();
	
	/**
	* valid components
	* @var  :array
	*/		
	private static $_validComponents = array(
		'scheme',
		'user',
		'pass',
		'host',
		'port',
		'path',
		'query',
		'fragment'
	);
	
	/**
	* @see http://www.w3.org/Addressing/URL/url-spec.txt
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
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* creates valid url with given params
	* querystring creation based on http_build_query (http://php.net/manual/de/function.http-build-query.php)
	* 
	* @input-required:
	* @param -> $url   				:string path / url
	* 
	* @input-optional:
	* @param -> $_queryParams 		:array variables to add to url	
	* @param -> $prefix  			:string //if queryKey is numeric
	* @param -> $separator  		:string //('&', '&amp;')
	* @param -> $allowInternal  	:boolean 
	* @param -> $_validSchemes 		:array (allow schemes)
	*/
	public function __construct($url, $_queryParams = array(), $prefix = 'JVM_', $separator = '&', $allowInternational = true, $allowInternal = true, $_validSchemes = NULL){
		//allow internal
		$this->setAllowInternal($allowInternal);
		//allow international
		$this->setAllowInternational($allowInternational);
		//define valid schemes
		if($_validSchemes !== NULL){
			$this->setAllowedSchemes($_validSchemes);
		}
		//build internal uri		
		$this->setUri(
			$url, 
			$_queryParams, 
			$prefix, 
			$separator
		);
	}
	
	/**
	* @desc
	* creates valid url with given params
	* querystring creation based on http_build_query (http://php.net/manual/de/function.http-build-query.php)
	* 
	* @input-required:
	* @param -> $url   				:string path / url
	* @param -> $_queryParams 		:array variables to add to url	
	* 
	* @input-optional:
	* @param -> $prefix  			:string //if queryKey is numeric
	* @param -> $separator  		:string //('&', '&amp;')
	* @param -> $allowInternal  	:boolean 
	* @param -> $_validSchemes 		:array (allow schemes)
	*	
	* @return :JVM_Http_Uri
	*/
	public static function factory($url, $_queryParams = array(), $prefix = 'JVM_', $separator = '&', $allowInternational = true, $allowInternal = true, $_validSchemes = NULL){
		return (
			new self(
				$url, 
				$_queryParams, 
				$prefix, 
				$separator, 
				$allowInternational, 
				$allowInternal, 
				$_validSchemes
			)
		);
	}
	
	/**
	* @desc
	* creates internal valid url with given params		
	* 
	* @input-required:
	* @param -> $url   				:string path / url
	* @param -> $_queryParams 		:array variables to add to url	
	* 
	* @input-optional:
	* @param -> $prefix  			:string //if queryKey is numeric
	* @param -> $separator  		:string //('&', '&amp;')
	* @param -> $useModrewrite  	:boolean 
	*	
	* @return :string
	*
	* @access public
	*/ 
	public function setUri($url, $_queryParams = array(), $prefix = 'JVM_', $separator = '&'){
		$this->_queryParams 	= $_queryParams;	//query params
		$this->prefix 			= $prefix;			//prefix
		$this->separator 		= $separator; 		//querystring build separator
		//build url the components scheme user pass host port aso.
		$this->setComponents($url);	
		//build url	
		$this->uri = $this->getUrl();				
	return $this;
	}
	
	/**
	* @desc
	* sets internal flag if url should be treated as a rewrite url		
	* 
	* @input-required:
	* @param -> $doRewrite 		:boolena	
	*	
	* @return :this
	*
	* @access private
	*/	
	private function setRewrite($doRewrite){
		if(!is_bool($doRewrite)){
			throw new JVM_Http_Exception('param must be type of boolean');
		}
		$this->isRewriteUrl = $doRewrite;
	return $this;		
	}
	
	/**
	* @desc
	* internal function to valid url from parsed components
	* used by all set funtions to overwrite components like username 		
	* 
	* @input-required:
	* @param -> $url 		:string	
	*	
	* @return :string
	*
	* @access private
	*/	
	private function setComponents($url){
		$this->_components = parse_url($url);
		//query string  to array()
		$this->parseQueryParams();	
		if(stream_is_local($url)){
			$this->isInternal = true;		
		}
		elseif( 
			!isset($this->_components['scheme']) || 
		    (isset($this->_components['scheme']) && !$this->isValidScheme($this->_components['scheme']))
		){
			throw new JVM_Http_Exception('submitted uri($url) seems invalid. url must have protocol/scheme see supported schemes', 1002);
		}
	} 
		
	/**
	* @desc
	* parses query string an adds params to _queryParams
	* 
	* @void	
	*	
	* @return :none
	*
	* @access private
	*/
	private function parseQueryParams(){
		if(isset($this->_components['query']) && !empty($this->_components['query'])){
			$_params = $this->queryStringToArray($this->_components['query']);
			$this->_queryParams = $_params + $this->_queryParams;
		}
		$this->_components['query'] = http_build_query(
			$this->_queryParams, 
			$this->prefix, 
			$this->separator
		);
	}
	
	/**
	* @desc
	* parses query string into an array
	* @notice ignores empty values!
	* 
	* @input-required:
	* @param -> $queryString 	:string	
	*	
	* @return :array
	*
	* @access public
	*/
	public static function queryStringToArray($queryString){
		$_queryParams = array();
		if(strstr($queryString, '?')){
			$queryString = parse_url($queryString, PHP_URL_QUERY); 	
		}
		else{
			$queryString = str_replace('?', '', $queryString);
		}
		//parse the string
		parse_str($queryString, $_queryParams);
	return $_queryParams;	
	}
	
	/**
	* @desc
	* internal function to valid url from parsed components
	* used by all set funtions to overwrite components like username 		
	* 
	* @input-required:
	* @param -> $url 		:string	(valid url)
	* @param -> $component 	:string	(valid component)
	*	
	* @return :mixed (string or array)
	*
	* @access public
	*/	
	public static function getComponent($url, $component = NULL){
		if(!self::isValid($url)){
			throw new JVM_Http_Exception('submitted uri($url) seems invalid.');
		}
		if($component !== NULL && (!is_string($component) || !in_array($component, self::$_validComponents))){
			throw new JVM_Http_Exception('submitted uri($url) seems invalid.');
		}
		//parse url
		$_components = @parse_url($url);
		if($component !== NULL && array_key_exists($component, $_components)){
			return($_components[$component]);
		}
	return($_components);
	}	
/*	+-----------------------------------------------------------------------------------+
	| 	uri functions
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @desc
	* retuns flag if url is www or server-internal
	*
	* @notice does not validate if local/inernal url exists
	* 
	* @void	
	*	
	* @return :boolean
	*
	* @access public
	*/
	public function isInternal(){
	return $this->isInternal;
	}
	
	/**
	* @desc
	* retuns flag if url is www or server-internal
	*
	* @notice does not validate if local/inernal url exists
	* 
	* @void	
	*	
	* @return :boolean
	*
	* @access public
	*/
	public static function isLocal($uri){
		if(!self::isValid($uri, true, true)){
			throw new JVM_Http_Exception('submitted uri($url) is invalid', 1002);
		}
	return stream_is_local($uri);
	}	

	/**
	* @desc
	* delivers scheme
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getScheme(){
	return( (isset($this->_components['scheme']) ?  $this->_components['scheme'] : '') );
	}	
	
	/**
	* @desc
	* delivers scheme
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getUser(){
	return( (isset($this->_components['user']) ?  $this->_components['user'] : '') );
	}
	
	/**
	* @desc
	* delivers scheme
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getPass(){
	return( (isset($this->_components['pass']) ?  $this->_components['pass'] : '') );
	}
	
	/**
	* @desc
	* delivers scheme
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getAuth(){
		return( 
			isset($this->_components['user']) && isset($this->_components['pass']) ?  
			$this->concat($this->getUser(), ':', true) . $this->concat($this->getPass(), '@', true) :
			''
		);
	}
	
	/**
	* @desc
	* delivers host
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getHost(){
	return( (isset($this->_components['host']) ?  $this->_components['host'] : '') );
	}	
	
	/**
	* @desc
	* delivers port
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getPort($doConcat = false){
	return( (isset($this->_components['port']) ? $this->_components['port'] : '') );
	}	

	/**
	* @desc
	* delivers path (prepends slash if required)
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getPath(){
		$path = ( isset($this->_components['path']) ? $this->_components['path'] : '' );
		if(strlen($path) > 1 && $path[0] !== '/'){
			$path = '/'.$path;	
		}
	return($path);	
	}
	
	/**
	* @desc
	* delivers query
	* 
	* @void
	*	
	* @return :string
	*/
	public function getQueryString(){	
	return( (isset($this->_components['query']) ?  $this->_components['query'] : '') );	
	}

	/**
	* @desc
	* delivers _queryParams	
	* 
	* @void	
	*	
	* @return :array
	*
	* @access public
	*/
	public function getQueryParams(){
	return($this->_queryParams);
	}	
	
	/**
	* @desc
	* delivers fragment #demo
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getFragment(){
	return( (isset($this->_components['fragment']) ?  $this->_components['fragment'] : '') );
	}	
	
	/**
	* @desc
	* helperfunction to concat uri-components with concatchars (i.e :, /)
	* boolean flag defines if character is appended/prepended
	*
	* @input-required:
	* @param -> $component  :string
	* @param -> character	:string
	*  
	* @input-optional:
	* @param -> $append  	:boolean
	*	
	* @return :string
	*
	* @access public
	*/
	private function concat($component, $character, $append = false){
		if($component && !empty($component)){
			if($append === true){
				return $component . $character;
			}
			else{
				return $character . $component;	
			}
		}
	return '';
	}
		
	/**
	* @desc
	* delivers url
	* 
	* @void
	*	
	* @return :string
	*
	* @access public
	*/
	public function getUrl(){
		return(
			$this->buildURL(
				( 
					$this->concat($this->getScheme(), '://', true) .
					$this->getAuth() .
					$this->getHost() .
					$this->concat($this->getPort(), ':') .
					$this->getPath() .
					$this->concat($this->getQueryString(), '?').
					$this->concat($this->getFragment() , '#')
				),
				array(), //$this->getQueryParams(),
				$this->prefix,
				$this->separator,
				$this->allowInternational,
				$this->allowInternal,
				$this->_validSchemes
			)
		);
	}	
	
	/**
	* @desc
	* delivers mod rewrite url rewrites url replace connectors
	* 
	* @input-optional:
	* @param -> $url  			:string
	*	
	* @return :string
	*
	* @access public
	*/	
	public function getRewriteUrl($url = NULL){
		if($url !== NULL && $this->isValid($url)){
			$uri = $this->setUri($url); //if url passed into function
		}
		return(
			$this->concat($this->getScheme(), '://', true) .
			$this->getAuth() .
			$this->getHost() .
			$this->concat($this->getPort(), ':') .
			$this->getPath() .
			str_replace(array('?', '=', '&', '//'), '/', $this->concat($this->getQueryString(), '?') ).
			$this->concat($this->getFragment() , '#')
		);
	}	
	
	/**
	* @desc
	* check if current scheme isSSL 	
	* 
	* @void	
	*	
	* @return :boolean
	*
	* @access public
	*/ 
	public function isSSL(){
		if($this->getScheme() === 'https'){
			return true;
		}
	return false;
	}

	/**
	* @desc
	* creates valid url with given params
	* querystring creation based on http_build_query (http://php.net/manual/de/function.http-build-query.php)
	* 
	* @input-required:
	* @param -> $url   				:string path / url
	* @param -> $_queryParams 		:array variables to add to url	
	* 
	* @input-optional:
	* @param -> $prefix  			:string //if queryKey is numeric
	* @param -> $separator  		:string //('&', '&amp;')
	* @param -> $allowInternal  :boolean 
	*	
	* @return :string
	*
	* @access public
	*/ 
	public static function buildURL($url, array $_queryParams = array(), $prefix = 'JVM_', $separator = '&', $allowInternational = true, $allowInternal = true, array $_validSchemes = array()){
		//validate input
		if(!self::isValid($url, $allowInternational, $allowInternal, $_validSchemes)){
			throw new JVM_Http_Exception('submitted uri($url) is invalid', 1002);
		}
		if(!self::isValidSeparator($separator)){
			throw new JVM_Http_Exception('submitted separator($separator) is invalid', 1003);
		}
		if(!is_string($prefix)){
			throw new JVM_Http_Exception('prefix must be typeof string', 1005);
		}			 		 
		//handle fragments 
		$fragment 	= strstr($url, '#');
		if($fragment !== false){
			$url = str_replace($fragment, '', $url);
		}
		//build the full uri
		if(!empty($_queryParams)){
			//build querystring
			$queryString = http_build_query($_queryParams, (string)$prefix, (string)$separator);
			//set query connector 
			$urlConnector  = '?';
			if(strstr($url, '?')){
				$urlConnector = '&';
				if($url[intval(strlen($url)-1)] == '?'){//if ? is last char
					$urlConnector = '';	
				} 
			}
			$url .=  $urlConnector . $queryString;
		}
		//add fragment
		if($fragment !== false){
			$url .=  $fragment;
		}
	return $url;
	}
	
	/**
	* @desc
	* set scheme
	* 
	* @input-required:
	* @param -> $scheme   :string
	*	
	* @return :this
	*
	* @access public
	*/ 	
	public function setScheme($scheme){
		if(!$this->isValidScheme($scheme)){
			throw new JVM_Http_Exception('invalid scheme (not in config list)', 1005);	
		}
		$this->_components['scheme'] = $scheme;
	return $this;
	}
	
	
	/**
	* @desc
	* set/changes username in uri
	* 
	* @input-required:
	* @param -> $userName   :string
	*	
	* @return :this
	*
	* @access public
	*/ 	
	public function setUser($userName){
		if(!is_string($userName) && $userName !== ''){
			throw new JVM_Http_Exception('userName must be typeof string', 1003);
		}
		$this->_components['user'] = (string) $userName;
	return $this;
	}
	
	/**
	* @desc
	* set/changes pass in uri
	* 
	* @input-required:
	* @param -> $password   :string
	*	
	* @return :this
	*
	* @access public
	*/	
	public function setPass($password){
		if(!is_string($password) && $password !== ''){
			throw new JVM_Http_Exception('password must be typeof string', 1003);
		}
		$this->_components['pass'] = (string) $password;
	return $this;
	}
	
	/**
	* @desc
	* set/changes host in uri
	* 
	* @input-required:
	* @param -> $host   :string
	*	
	* @return :this
	*
	* @access public
	*/	
	public function setHost($host){
		if(!is_string($host)){
			throw new JVM_Http_Exception('host must be typeof string', 1003);
		}
		$this->_components['host'] = (string) $host;
	return $this;
	}
	
	/**
	* @desc
	* set/changes port in uri
	* 
	* @input-required:
	* @param -> $port   :mixed //interger or ''
	*	
	* @return :this
	*
	* @access public
	*/
	public function setPort($port){
		if(!is_int($port) && $port !== '' || ($port > 65536 || $port < 0)){
			throw new JVM_Http_Exception('port must be typeof int or empty string', 1003);
		}
		$this->_components['port'] = $port;
	return $this;
	}	
	
	/**
	* @desc
	* set/changes pass in uri
	* 
	* @input-required:
	* @param -> $path   :string
	*	
	* @return :this
	*
	* @access public
	*/	
	public function setPath($path){
		if(!is_string($path)){
			throw new JVM_Http_Exception('path must be typeof string', 1003);
		}
		$this->_components['path'] = (string) $path;
	return $this;
	}
	
	/**
	* @desc
	* set/changes fragment in uri
	* 
	* @input-required:
	* @param -> $path   :string
	*	
	* @return :this
	*
	* @access public
	*/
	public function setFragment($fragment){
		if(!is_string($fragment)){
			throw new JVM_Http_Exception('fragment must be typeof string', 1003);
		}
		$this->_components['fragment'] = (string) preg_replace('/#/', '', $fragment);
	return $this;
	}

	/**
	* @desc
	* set/changes user and pass in uri
	* uses setUser and setPass
	* 
	* @input-required:
	* @param -> $userName   :string
	* @param -> $password   :string	
	*	
	* @return :this
	*
	* @access public
	*/
	public function setAuth($userName, $password){
	return($this->setUser($userName)->setPass($password));
	}
	
	/**
	* @desc
	* overwrites current queryString
	* uses setUser and setPass
	* 
	* @input-required:
	* @param -> $_queryParams   :array
	*	
	* @return :this
	*
	* @access public
	*/	
	public function setQueryString($_queryParams = array()){
		if(!is_array($_queryParams)){
			throw new JVM_Http_Exception('queryParams must be typeof array', 1003);
		}
		$this->_components['query'] = ''; //empty
		$this->_queryParams = $_queryParams;
		$this->parseQueryParams();
	return $this;
	}	
	
	/**
	* @desc
	* adds one ore more params to current url
	* 
	* @param -> $_queryParams 		:array variables to add to url	
	* 
	* @input-optional:
	* @param -> $prefix  			:string //if queryKey is numeric
	* @param -> $separator  		:string //('&', '&amp;')
	* @param -> $useModrewrite  	:boolean 
	*	
	* @return :self::object
	*/
	public function addToQueryString(array $_queryParams){
		if(!is_array($_queryParams)){
			throw new JVM_Http_Exception('queryParams must be typeof array', 1003);
		}
		$this->_queryParams = $_queryParams+$this->_queryParams;
		$this->parseQueryParams();	
	return $this;
	}
	
	/**
	* @desc
	* set allowed schemes
	* 
	* @input-required:
	* @param -> $_validSchemes : array
	*	
	* @return :this
	*
	* @access public static
	*/
	public function setAllowedSchemes($_validSchemes){
		if(!is_array($_validSchemes)){
			throw new JVM_Http_Exception('_validSchemes must be typeof array', 1003);	
		}
		$this->_validSchemes = $_validSchemes;
	return $this;
	}
	
	/**
	* @desc
	* set flag for internal urls allowed
	* 
	* @input-required:
	* @param -> $allowInternal : bool
	*	
	* @return :this
	*
	* @access public
	*/
	public function setAllowInternal($allowInternal){
		if(!is_bool($allowInternal)){
			throw new JVM_Http_Exception('allowInternal must be typeof boolean', 1003);		
		}
		$this->allowInternal = $allowInternal;
	return $this;
	}	
	
	/**
	* @desc
	* set flag for international urls allowed
	* 
	* @input-required:
	* @param -> $allowInternational : bool
	*	
	* @return :this
	*
	* @access public
	*/
	public function setAllowInternational($allowInternational){
		if(!is_bool($allowInternational)){
			throw new JVM_Http_Exception('allowInternational must be typeof boolean', 1003);		
		}
		$this->allowInternational = $allowInternational;
	return $this;
	}		

	/**
	* @desc
	* check if submitted parameter is valid
	* 
	* @input-required:
	* @param -> $separator :string	
	*	
	* @return none
	*
	* @access public
	*/	
	public static function isValidSeparator($separator){
		if(in_array($separator, array('&amp;', '&', '/'))){
			return true;
		}
	return false;		
	}	
	
	/**
	* @desc
	* check if submitted parameter is valid
	*
	* @notice!!!
	* Note that the function will only find the protocols (http,https,ftp,tcp) to be valid; 
	* 
	* @input-required:
	* @param -> $scheme :string	
	*	
	* @return none
	*
	* @access public
	*/	
	public function isValidScheme($scheme, array $_validSchemes = NULL){
		if($_validSchemes !== NULL){
			$this->_validSchemes = $_validSchemes;	
		}
		if(empty($this->_validSchemes) || in_array($scheme, $this->_validSchemes)){
			return true;
		}
	return false;		
	}	
	
	/**
	* @desc
	* validates if input is a valid url
	*
	* @see JVM_Validate_Url for further information
	* 
	* @input-required:
	* @param -> $url :string
	*	
	* @return boolean
	*
	* @access public static
	*/	
	public static function isValid($url, $allowInternational = true, $allowInternal = true, $_validSchemes = array()){
		$validate = new JVM_Validate_Url(
			$allowInternational, 
			$allowInternal, 
			$_validSchemes
		);
	return $validate->isValid($url);
	}	
	
	/**
	* @desc
	* returns current url if object forced to string
	*
	* WARNING! returns empty string in case of exception
	*
	* @void	
	*	
	* @return string
	*
	* @access public
	*/	
	public function __toString(){
		try{
			if($this->isRewriteUrl){
				return $this->getRewriteUrl();
			}
			return $this->getUrl();	
		}
		catch(Exception $e){ 
			return '';//$e->getMessage();
		}
	}
		
}