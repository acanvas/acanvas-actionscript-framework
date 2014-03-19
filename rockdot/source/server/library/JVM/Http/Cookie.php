<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2011, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc: set, manipulate, delete cookies
 * @see: http://php.net/manual/de/function.setcookie.php 
 * @see: http://tools.ietf.org/html/rfc2109
 *
 * @limitations:
 *  4 KB per cookie maximum
 *  300 total cookies, for a total of 1.2 Mbytes maximum
 *  20 cookies accepted from a particular server or domain
 * 
 * @author 			joerg.diterlizzi
 * @version 		1.0			
 * @lastmodified:
 * @package         JVM_Http
 *
 * @dependencies:
 * @import: JVM_Http_Exception
 */
require_once('JVM/Http/Exception.php');

class JVM_Http_Cookie{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */		
   	/**
	* valid cookie options
	* @var  :array
	*/
	private $_validOptions = array(
		'name',
		'value',
		'time',
		'path',
		'domain',
		'secure',
		'httponly',
		'lock'
	);
	
	/**
	* lock cookies //deny overwrite
	* @var  :array
	*/
	private static $_lockedCookies = array();

	/**
	* cookies
	* @var  :array
	*/
	private $_cookies;
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc optionally set cookies via construct
	*	
	* @input-required:
	* @param -> $_options		:array
	*
	* @access public
	*/
	public function __construct(array $_options = array()){
		$this->_cookies = $_COOKIE;
		//set internal cookie array
		if(!empty($_options)){
			if(!isset($_options[0])){
				$_options = array($_options);			
			}
			foreach($_options as $_cookie){
				$this->setCookie($_cookie);
			}
		}
	}
/*	+-----------------------------------------------------------------------------------+
	|	handles cookie-manupulation (set, get, delete)
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* checks if value / param exists
	*
	* @input-required:
	* @param -> $name		:request Parameter name
	*
	* @return :boolean
	*
	* @access public
	*/
	public static function issetCookie($name){
		return(isset($_COOKIE[$name]));
	}

	/**
	* @desc
	* returns cookie
	*
	* @input-required:
	* @param -> $name		:request Parameter name
	*	
	* @return :boolean
	*
	* @access public
	*/
	public static function getCookie($name){
		if(self::issetCookie($name)){
			return $_COOKIE[$name];
		}
	return NULL;
	}
	
	/**
	* @desc
	* returns cookie
	*
	* @void
	*	
	* @return :boolean
	*
	* @access public
	*/
	public static function getCookies(){
	return $_COOKIE;
	}	

	/**
	* @desc
	* returns requestkeys
	*
	* @void
	* @return :boolean
	*
	* @access public
	*/
	public function getCookieNames(){
	return(array_keys($_COOKIE));
	}
	
	/**
	* @desc
	* sets a cookie to the current user
	*
	* @input-required:
	* @param -> $name               :string (name or array of options
	* @param -> $value=false
	* @param -> $time=3600
	* @param -> $path='/'
	* @param -> $domainname=false
	* @param -> $isboolsecure=1 
	* @param -> $overwrite=false	
	*	
	* @return :false
	*
	* @access public
	*/
	public static function setCookie($_nameOrOptions, $value = 0, $time=0, $path='/', $domain=false, $secure=false, $httpOnly = false, $lock = false){
		if(is_array($_nameOrOptions)){
			if(!isset($_nameOrOptions['name']) || !is_string($_nameOrOptions['name'])){
				throw new JVM_Http_Exception('cookie-name is a required parameter and must be type of string', 1002);
			}
			$name = $_nameOrOptions['name'];
			//value
			if(isset($_nameOrOptions['value'])){
				if(!is_scalar($_nameOrOptions['value']) ){
					throw new JVM_Http_Exception('cookie-value be type of int, float, boolean, or string', 1000);
				}
				/*if(!is_bool($_nameOrOptions['value']) && (strlen($_nameOrOptions['value'])*8) > 4096){
						throw new JVM_Http_Exception('cookie-value is to big only 4kb allowed', 1000);
				}*/
				$value = $_nameOrOptions['value'];
			}
			//time
			if(isset($_nameOrOptions['time'])){
				if(!is_int($_nameOrOptions['time'])){
					throw new JVM_Http_Exception('cookie-time be type of int', 1000);
				}
				$time = $_nameOrOptions['time'];
			}
			//path
			if(isset($_nameOrOptions['path'])){
				if(!is_string($_nameOrOptions['path'])){
					throw new JVM_Http_Exception('cookie-path must be type of string', 1000);
				}
				$path = $_nameOrOptions['path'];
			}
			//domain
			if(isset($_nameOrOptions['domain'])){
				if(!is_string($_nameOrOptions['domain']) &&!is_bool('domain')){
					throw new JVM_Http_Exception('cookie-domain must be type of string', 1000);
				}
				$domain = $_nameOrOptions['domain'];
			}
			else{
				//default
				$domain = $_SERVER['HTTP_HOST'];	
			}
			//secure
			if(isset($_nameOrOptions['secure'])){
				if(!is_bool($_nameOrOptions['secure'])){
					throw new JVM_Http_Exception('cookie-secure must be type of boolean', 1000);
				}
				$secure = $_nameOrOptions['secure'];
			}
			//httpOnly
			if(isset($_nameOrOptions['httponly'])){
				if(!is_bool($_nameOrOptions['httponly'])){
					throw new JVM_Http_Exception('cookie-httpOnly must be type of boolean', 1000);
				}
				$httpOnly = $_nameOrOptions['httponly'];
			}
			//overwrite
			if(isset($_nameOrOptions['lock'])){
				if(!is_bool($_nameOrOptions['lock'])){
					throw new JVM_Http_Exception('cookie-lock must be type of boolean', 1000);
				}
				$lock = $_nameOrOptions['lock'];
			}
		}
		else{
			$name = $_nameOrOptions;
		}
		//handle domain
		if($domain === false || empty($domain)){
			$domain = $_SERVER['HTTP_HOST'];	
		}		
		//lock array
		if($lock === true){
			self::$_lockedCookies[$name] = true;
		}
		else{
			self::unlockCookie($name);	
		}
		//set the cookie
		if(!self::issetCookie($name) || (self::issetCookie($name) && !array_key_exists($name, self::$_lockedCookies))){
			if(!setcookie($name, $value, $time, $path, $domain, $secure, $httpOnly)){
				throw new JVM_Http_Exception('cookie not set something went wrong', 1000);	
			}
		}
	}
	
	/**
	* @desc
	* locks a cookie (allow overwrite)
		* lock is not permanent only for current response
	*
	* @input-required:
	* @param -> $name	:string
	*	
	* @return :none
	*
	* @access public
	*/
	public static function unlockCookie($name){
		if(isset(self::$_lockedCookies[$name])){
			unset(self::$_lockedCookies[$name]);	
		}
	}
	
	/**
	* @desc
	* unlocks a cookie (allow overwrite)
	* lock is not permanent only for current response
	*
	* @input-required:
	* @param -> $name	:string
	*	
	* @return :none
	*
	* @access public
	*/
	public static function lockCookie($name){
		if(!isset(self::$_lockedCookies[$name])){
			self::$_lockedCookies[$name] = true;
		}
	}
	
	/**
	* @desc
	* returns list of locked cookies
	* lock is not permanent only for current response
	*
	* @void
	*	
	* @return :none
	*
	* @access public
	*/
	public static function getLockedCookieList(){
	return self::$_lockedCookies;	
	}
	
	/**
	* @desc
	* deletes cookie of current user / sets cookie to false
	* @notice! Cookies must be deleted with the same params they were set
	* (ie. if bound to specific path that path must be in delete as well)
	* 
	*
	* @input-required:
	* @param -> $name	:string		current cookie isset to false	
	*	
	* @return :none
	*
	* @access public
	*/
	public static function deleteCookie($name, $path = false, $domain = false, $secure=false, $httpOnly = false){
		if(self::issetCookie($name)){
			if($path === false){
				$path = '/';
			}
			if($domain === false){
				$domain = $_SERVER['HTTP_HOST'];
			}
			self::setCookie($name, false, time()-3600, $path, $domain, $secure, $httpOnly);
		}
	}
		
	/**
	* @desc
	* direct acces of cookie params
	*
	* @input-required:
	* @param -> $name	:string	
	*	
	* @return: mixed
	*
	* @access public
	*/	
	public function __get($name){
		if(isset($_COOKIE[(string) $name])){
			return ($_COOKIE[(string) $name]);
		}
	return NULL;
	}		

}