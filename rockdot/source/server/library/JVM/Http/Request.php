<?php
/*	
+-----------------------------------------------------------------------------------+
| Copyright (c) 2010/11, Joerg Di Terlizzi												|
| All rights reserved.																|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>								|
+-----------------------------------------------------------------------------------+ 
*/
/**
 * Http(s) Request Handler enables direct access to the superglobals (GET, POST, COOKIES, FILES, SERVER, ENV)
 * Parameternames are sanitized by php ("eval(3+4)tets" changes to "eval(3_4)tets")
 * 
 * @author joerg.diterlizzi
 * @version: 1.02
 * @import: JVM_Http_Exception
 */
require_once('JVM/Http/Exception.php');
require_once('JVM/Data.php');

class JVM_Http_Request{
/*  +-----------------------------------------------------------------------------------+
	| 	class member-vars
	+-----------------------------------------------------------------------------------+  */
	/**
	* this object instance
	* @var  self::object
	*/
	private static $selfInstance;
	
	/**
	* static ip (for mocking REMOTE_ADDR)
	* @var :string
	*/
	private static $ip = NULL;
	
	/**
	* default storage container for userset variables
	* @var :array
	*/	
	private $_container = array(
		'INTERNAL' => array()
	);
	
	/**
	* splitchar for easy/lazy access 
	* @var  :char
	*/		
	private $separator = ',';
	
	/**
	* supported superglobals
	* @var  :string
	*/	
	private $_supportedGlobals = array(
		'GET',
		'POST',
		'COOKIE',
		'FILES',
		'SERVER',
		'ENV',
	);

	/**
	* supported overwritable superglobals
	* @var  :string
	*/		
	private $_writableGlobals = array(
		'GET', 
		'POST'
	);
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* disallow multiple instances
	* no new instance with clone-function or new 
	* _register defines which globals are bound to request 	
	*	
	* @input-required:
	* @param -> $_register		:array
	*
	* @access protected
	*/
	protected function __construct(array $_register){
		//declare / register valid / internal references to Superglobals
		$this->register($_register);
	}
	
	/**
	* @desc
	* _register the globals to object 	
	*	
	* @input-required:
	* @param -> $_register		:array
	*
	* @access protected
	*/	
	public function register(array $_register){
		foreach($_register as $name){
			if(!in_array($name,  $this->_supportedGlobals)){
				throw new JVM_Http_Exception('only supported superglobals are allowed to register', 1004);		
			}
			if(!isset($this->_container[$name])){
				$this->_container[$name] =& $GLOBALS['_'.$name];
			}
		}
	return($this);
	}

	/**
	* @desc
	* disallow cloning of obj
	*
	* @access private	
	*/
	private function __clone(){} 

	/**
	* @desc
	* singleton method delivers single instance of request object
	*
	* @input-optional:
	* @param -> $_register		:array (default: array('GET', 'POST', 'COOKIE', 'FILES'))
	*
	* @return :instance self this
	*
	* @access public
	*/	
	public static function getInstance(array $_register = array('GET', 'POST', 'COOKIE', 'FILES')){
		if(self::$selfInstance == NULL){
			self::$selfInstance = new self($_register);
		}
		return(self::$selfInstance);
	} 
/*	+-----------------------------------------------------------------------------------+
	| 	request Type
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @desc
	* delivers current Request-Method
	*
	* @void
	*
	* @return :string
	*
	* @access public
	*/
	public function getMethod(){
	return $_SERVER['REQUEST_METHOD'];
	}
	
	/**
	* @desc
	* check request-method if is post
	*
	* @void
	*
	* @return :boolean
	*
	* @access public
	*/
	public static function isPost(){
		if($_SERVER['REQUEST_METHOD'] === 'POST'){
			return true;
		}
	return false;
	}
	
	/**
	* @desc
	* check request-method if is get
	*
	* @void
	*
	* @return :boolean
	*
	* @access public
	*/
	public static function isGet(){
		if($_SERVER['REQUEST_METHOD'] === 'GET'){
			return true;
		}
	return false;
	}
	
    /**
     * Is this a Javascript XMLHttp request
	 *
	 * @void
	 *
	 * @return :boolean
	 *
	 * @access public static
     */
    public static function isAjax(){
        if(isset($_SERVER['X_REQUESTED_WITH'])){
			if( 
				($_SERVER['X_REQUESTED_WITH'] === 'XMLHttpRequest') || 
				($_SERVER['X_REQUESTED_WITH'] === 'jqXHR')  
			){
				return true;
			}
		}
	return false;
	}

    /**
    * is this a Flash request?
	*
	* @void
	*
	* @return :boolean
	*
	* @access public static
    */
    public static function isFlash(){
		if(isset($_SERVER['USER_AGENT'])){
			if(strstr(strtolower($_SERVER['USER_AGENT']), ' flash')){
				return true;
			}
		}
	return false;
	}
/*	+-----------------------------------------------------------------------------------+
	| 	get set delete
	+-----------------------------------------------------------------------------------+  */			
	/**
	* @desc
	* returns $_GET / $_GET[$name]
	* writable container
	*
	* @input-optional:
	* @param -> $name	:keyname of Superglobal array
	*
	* @return :mixed 
	*
	* @access public static
	*/	
	public static function getGet($name = NULL){
		if(isset($_GET[(string) $name])){
			return($_GET[(string) $name]);
		}
		if($name === NULL){
			return ($_GET);
		}
	return(NULL);
	}		

	/**
	* @desc
	* returns $_POST / $_POST[$name]
	* writable container
	*
	* @input-optional:
	* @param -> $name	:keyname of Superglobal array
	*
	* @return :mixed 
	*
	* @access public static
	*/		
	public static function getPost($name = NULL){
		if(isset($_POST[(string) $name])){
			return($_POST[(string) $name]);
		}
		if($name === NULL){
			return $_POST;
		}
	return NULL;
	}

	/**
	* @desc
	* returns $_GET+$_POST+$_COOKIE+['INTERNAL']
	*
	* @void
	*
	* @return :array 
	*
	* @access public
	*/	
	public function getRequest(){
		return ($this->_container['INTERNAL']+$_POST+$_GET+$_COOKIE);
	}		
	
	/**
	* @desc
	* returns $_COOKIE / $_COOKIE[$name]
	* unwritable container
	*
	* @input-optional:
	* @param -> $name	:keyname of Superglobal array
	*
	* @return :mixed 
	*
	* @access public static
	*/	
	public static function getCookie($name = NULL){
		if(isset($_COOKIE[(string) $name])){
			return($_COOKIE[(string) $name]);
		}
		if($name === NULL){
			return $_COOKIE;
		}
	return NULL;
	}
	
	/**
	* @desc
	* returns requested property of $_FILES array or the whole global
	* unwritable container
	*
	* @input-not-required:
	* @param -> $elementName	:string - elementName (form)
	* @param -> $property		:string property of $_FILES[$elementName] array	
	*	
	* @return :boolean
	*
	* @access public static
	*/
	public static function getFiles($elementName = NULL, $property = NULL){
		if(	$elementName !== NULL && 
			!isset($_FILES[$elementName])
		){	
			return NULL;
		}
		if(	$elementName !== NULL && 
			$property !== NULL &&
			in_array($property, array('name', 'type', 'tmp_name', 'error', 'size') ) 
		){	//get property of element
			return($_FILES[(string) $elementName][(string) $property] );
		}
		elseif($elementName !== NULL){  //get file element
			return ($_FILES[(string) $elementName]);
		}
	return $_FILES;		
	}				
	
	/**
	* @desc
	* returns $_SERVER / $_SERVER[$name]
	* unwritable container
	*
	* @input-optional:
	* @param -> $name	:keyname of Superglobal array
	*
	* @return :mixed 
	*
	* @access public static
	*/
	public static function getServer($name = NULL){
		if(isset($_SERVER[(string) $name])){
			return($_SERVER[(string) $name]);
		}
		if($name === NULL){
			return $_SERVER;
		}
	return NULL;
	}

  	/**
    * returns an info array about ssl support (regarding the load balancer )
	*
	* @input-optional:
	* @param -> $name	:keyname of SSL array
	* @param -> $minBit	:int 
	*
	* @return :array
	*
	* @access public static
    */	
	public static function getSSL($name = NULL, $minBit = 128){
		$keySize = 0;
		if(isset($_SERVER['SERVER_SOFTWARE'])){
			if(strstr($_SERVER['SERVER_SOFTWARE'], 'Apache/1.')){
				$keySize = $_SERVER['HTTPS_SECRETKEYSIZE'];
			} 
			elseif(strstr($_SERVER['SERVER_SOFTWARE'], 'Apache/2.')){
				// NOTE: regarding load balancer!!!
				if(isset($_SERVER['HTTP_FW_HTTPS'])){
					$_SERVER['HTTPS'] 				  = (isset($_SERVER['HTTP_FW_HTTPS']) ? $_SERVER['HTTP_FW_HTTPS'] : 'OFF');
					$_SERVER['SSL_CIPHER_USEKEYSIZE'] = (isset($_SERVER['HTTP_FW_KEYLENGTH']) ? $_SERVER['HTTP_FW_KEYLENGTH'] : 0);
				}
				$keySize = (isset($_SERVER['SSL_CIPHER_USEKEYSIZE']) ? $_SERVER['SSL_CIPHER_USEKEYSIZE'] : 0);
			}
		}
		$_SSL = array();
		$_SSL['SSL_ENABLED'] 		= ((isset($_SERVER['HTTPS']) && strtoupper($_SERVER['HTTPS']) == 'ON') ? true : false);
		$_SSL['SSL_STATE']         	= ((isset($_SERVER['HTTPS']) && strtoupper($_SERVER['HTTPS']) == 'ON') ? 'ON' : 'OFF');
		$_SSL['SSL_USER_KEY_SIZE']	= $keySize;
		$_SSL['SSL_KEY_ERROR']		= ($keySize < intval($minBit) ? true : false);
		if(isset($_SSL[(string) $name])){
			return($_SSL[(string) $name]);
		}
		if($name === NULL){
			return $_SSL;
		}
	return NULL;
	}	
	
	/**
    * returns boolean flag if current schemme matches https
	*
	* @void
	* @return :boolean
	*
	* @access public static
    */
	public static function isSsl(){
		if(self::getSSL('SSL_ENABLED') === true){
			return true;	
		}
	return false;	
	}
		
	/**
	* @desc
	* returns $_ENV / $_ENV[$name]
	* unwritable container
	*
	* @input-optional:
	* @param -> $name	:keyname of Superglobal array
	*
	* @return :mixed 
	*
	* @access public
	*/	
	public function getEnv($name = NULL){
		if(isset($_ENV[(string) $name])){
			return($_ENV[(string) $name]);
		}
		if($name === NULL){
			return $_ENV;
		}
	return NULL;
	}
	
	/**
	* @desc
	* returns current url
	*
	* @input-optional:
	* @param -> $forceSsl	:boolean force https-scheme
	*
	* @return :string 
	*
	* @access public
	*/	
	public static function getUrl($forceSsl = false){
		$uri = '';
		$uri .= (self::getSSL('SSL_ENABLED') === true || $forceSsl === true) ? 'https://' : 'http://';
		$uri .= $_SERVER['HTTP_HOST'];
		if($_SERVER['SERVER_PORT'] != '80') {
  			$uri .= ':'.$_SERVER['SERVER_PORT'];
 		}
		$uri .= $_SERVER['REQUEST_URI'];
	return $uri;
	}
	
	/**
	* @desc
	* trys to detect current ip address
	*
	* @input-optional:
	* @param -> $default :default return value if everything fails
	*
	* @return :string 
	*
	* @access public static
	*/
	public static function getIp($default = NULL){
		if(self::$ip !== NULL){
			return self::$ip;	
		}
		if(isset($_SERVER['HTTP_X_FORWARDED_FOR']) && trim($_SERVER['HTTP_X_FORWARDED_FOR'])) {
			$_tmp = preg_split('/,/', $_SERVER['HTTP_X_FORWARDED_FOR'], -1, PREG_SPLIT_NO_EMPTY);
			if (isset($_tmp[0]) && trim($_tmp[0])) {
				return trim($_tmp[0]);
			}
		}
		$_checkIdx = array(
			'HTTP_CLIENT_IP',
			'HTTP_X_FORWARDED',
			'HTTP_FORWARDED_FOR',
			'HTTP_FORWARDED',
			'REMOTE_ADDR',
		);
		foreach($_checkIdx as $idx){
			if(isset($_SERVER[$idx]) && trim($_SERVER[$idx])){	
				return $_SERVER[$idx];
			}
		}
	return $default;
	}
	
	/**
	* @desc
	* sets internal ip address mannualy (debugging/mocking)
	*
	* @input-optional:
	* @param -> $ip :ip adress
	*
	* @return :string 
	*
	* @access public static
	*/
	public static function setIp($ip){
		if(!filter_var($ip, FILTER_VALIDATE_IP)){ //, FILTER_FLAG_IPV4, FILTER_FLAG_IPV6
			throw new JVM_Http_Exception('invalid ip-address submitted', 1004);	
		}
		self::$ip = $ip;	
	}
	
	/**
	* @desc
	* returns header (if set)
	* searches in $_SERVER first then switches to
	* apache_request_headers if function exists
	*
	* @input-required:
	* @param -> $name	:keyname
	*
	* @return :mixed 
	*
	* @access public
	*/	
	public function getHeader($name){
        $temp = 'HTTP_' . strtoupper(str_replace('-', '_', $name));
        if (!empty($_SERVER[$temp])) {
            return $_SERVER[$temp];
        }
        if (function_exists('apache_request_headers')) {
            $_headers = apache_request_headers();
            if (!empty($_headers[$name])) {
                return ($_headers[$name]);
            }
        }
    return NULL;
    }				
		
	/**
	* @desc
	* get a superglobal (easy access supported)
	*
	* @input-required:
	* @param -> $name	:keyname
	*
	* @input-optional:
	* @param -> $type	:NULL (specify a superglobal
	*	
	* @return none
	*
	* @access public
	*/
	public function getParam($name, $type = NULL){
		if($type !== NULL && !isset($this->_container[$type])){
			throw new JVM_Http_Exception('unsupported superglobal', 1004);	
		}
		elseif($type !== NULL && isset($this->_container[$type])){
			return(JVM_Data::getValueByPath($name, $this->_container[$type], $this->separator));
		}
		foreach($this->_container as $_container){
			//container == global var
			$result = JVM_Data::getValueByPath($name, $_container, $this->separator);
			if($result !== NULL){
				return $result;
			}
		}
	return NULL;
	}
	
	/**
	* @desc
	* get all params set by user/script 
	* if type passed requested arrays are merged to one
	*
	* @input-optional:
	* @param -> $_types	:mixed (array|string) (specify a superglobal
	*	
	* @return none
	*
	* @access public
	*/	
	public function getParams($_types = NULL){
		//default result 
		$result = $this->_container['INTERNAL'];
		//add all support
		if($_types !== NULL && ($_types === 'ALL' || $_types === true)){
			$_types = $this->_supportedGlobals;
		}
		//add string support
		if($_types !== NULL && is_string($_types)){
			$_types = array($_types);
		}
		//add requested types dynamically
		if($_types !== NULL && is_array($_types)){
			foreach($_types as $type){
				//only valid types are merged to result
				if(isset($this->_container[$type])){
					$result += $this->_container[$type];
				}	
			}	
		}
		else{
			//merge GET and POST with internal values (default result)
			$result += $this->_container['GET'];
			$result += $this->_container['POST'];
			$result += $this->_container['COOKIE'];
		}
	return $result;
	}

	/**
	* @desc
	* tests if param exist by the use of getTrail
	*
	* @input-required:
	* @param -> $name
	*
	* @input-optional:
	* @param -> $type	:NULL (specify a superglobal
	*	
	* @return none
	*
	* @access public
	*/		
	public function isParam($name, $type = NULL){
		if($this->getParam($name, $type) !== NULL){
			return true;
		}
	return false;	
	}
	
	/**
	* @desc
	* sets a param does not touch superglobal values 
	* and uses internal container until type === NULL
	*
	* @input-required:
	* @param -> $name
	* @param -> $value
	*
	* @input-optional:
	* @param -> $type	:NULL (specify a superglobal
	*	
	* @return none
	*
	* @access public
	*/	
	public function setParam($name, $value, $type = NULL){
		if(!is_scalar($name)){
			throw new JVM_Http_Exception('1st argument (name) has to be a scalar', 1004);	
		}
		if(strstr($name, $this->separator)){
			throw new JVM_Http_Exception('1st argument (name) contains an invalid character previous defined as easy access splitchar', 1004);	
		}
		if($type !== NULL && in_array($type, $this->_writableGlobals)){
			$this->_container[$type][$name] = $value;
		}
		else{
			$this->_container['INTERNAL'][$name] = $value;
		}
	return $this;
	}
	
	/**
	* @desc
	* deletes a param does not touch superglobal values 
	* and uses internal container until type !== NULL
	*
	* @input-required:
	* @param -> $name
	*
	* @input-optional:
	* @param -> $type	:NULL (specify a superglobal
	*	
	* @return none
	*
	* @access public
	*/	
	public function deleteParam($name, $type = NULL){
		if(!is_scalar($name)){
			throw new JVM_Http_Exception('1st argument (name) has to be a scalar', 1004);	
		}
		if($type !== NULL && in_array($type, $this->_writableGlobals) && isset($this->_container[$type][$name])){
			unset($this->_container[$type][$name]);
		}
		elseif(isset($this->_container['INTERNAL'][$name])){
			unset($this->_container['INTERNAL'][$name]);
		}
	return $this;
	}	
/*	+-----------------------------------------------------------------------------------+
	| 	internal helper + magic implementations
	+-----------------------------------------------------------------------------------+  */			
	/**
	* @desc
	* set a splitvarable for easyaccess-params
	* notice:
	* your keynames should not contain the separatorchar
	*
	* @input-optional:
	* @param -> $separator 	:char
	*	
	* @return this
	*
	* @access public
	*/	
	public function setSeparator($separator){
		$_separators = array(',', ';', '/', ':', '.', '+', '>');
		if(!in_array($separator, $_separators)){
			throw new JVM_Http_Exception('separator should not corrupt the parameternames. use valid separators instead: ('.implode(' ', $_separators).')', 1004);		
		}
		$this->separator = $separator;
	return $this;
	}
	
	/**
	* @desc
	* sanitizes input //recursive
	*
	* @input-required  		
	* @param -> $_input 	:array 
	*
	* @return	 array
	*
	* @access 	 public
	*/	
	public static function sanitize($_input){
		if(!is_array($_input)){
			throw new JVM_Http_Exception('input must be type of array', 1004);		
		}
		if(!isset($_output)){
			$_output = array();
		}
		foreach($_input as $name => $value){
			if(is_array($value)){
				 $_output[$name] = self::sanitize($value);//recursive
			}
			else{
				$_output[$name] = filter_var(trim($value), FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_LOW);
			}
		}
	return $_output;
	}		

	/**
	* @desc
	* empty/clear full container or specific type + internal
	*
	* @void	
	*	
	* @return :this
	*
	* @access public
	*/		
	public function reset($type = NULL){
		if($type !== NULL && in_array($type, $this->_writableGlobals)){
			$this->_container[$type] 	  = array();
			$this->_container['INTERNAL'] = array();
			if(isset($GLOBALS['_'.$type])){
				$GLOBALS['_'.$type] = array();	
			}
		}
		else{
			foreach(array('GET', 'POST', 'INTERNAL') as $type){
				$this->_container[$type] = array();
				if(isset($GLOBALS['_'.$type])){
					$GLOBALS['_'.$type] = array();	
				}
			}
		}		
	return $this;
	}		
	
	/**
	* @desc
	* __ magic method __ 
	* make params accessible like an object
	* @see http://msdn.microsoft.com/en-us/library/system.web.httprequest.item.aspx
	*
	* @input-required:
	* @param -> $name :string (parameter name)
	*	
	* @return none
	*
	* @access public
	*/	
	public function __get($name){
		foreach($this->_container as $_superGlobal){
			if(isset($_superGlobal[$name])){
				return ($_superGlobal[$name]);
			}
		}
	return NULL;
	}
	
	/**
	* @desc
	* __ magic method __
	* notify: not allowed
	* 
	* @input-required:
	* @param -> $name	:string
	* @param -> $value	:string
	*	
	* @return none
	*
	* @access public
	*/	
	public function __set($name, $value){
		throw new JVM_Http_Exception('setting superglobals not allowed! use setParam() instead', 1004);
	}

	/**
	* @desc
	* __ magic method __
	* notify: not allowed
	* 
	* @input-required:
	* @param -> $name	:string
	* @param -> $value	:string
	*	
	* @return none
	*
	* @access public
	*/	
	public function __unset($name){
		throw new JVM_Http_Exception('unset superglobal is not allowed! use deleteParam() instead', 1004);
	}	
	
	/**
    * @desc 
	* __ magic method __
    * @see http://msdn.microsoft.com/en-us/library/system.web.httprequest.item.aspx
    * 
	* @input-required:
	* @param -> $name :string (parameter name)
    * 
 	* @access public
    */	
 	public function __isset($name){
		foreach($this->_container as $_innerContainer){
			if(isset($_innerContainer[$name])){
				return true;
			}
		}
	return false;
    }
	
}