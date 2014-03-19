<?php
/*	
+-----------------------------------------------------------------------------------+
| Copyright (c) 2011, Joerg Di Terlizzi												|
| All rights reserved.																|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>								|
+-----------------------------------------------------------------------------------+ 
*/
/**
 * @desc Registry supports a storage for objects 
 *
 * @pattern/scope   multi-singleton (namespaced instances)
 * @author 			joerg.diterlizzi
 * @version 		1.0			
 * @lastmodified	
 * @copyright  		Copyright (c) Jung von Matt / Neckar
 * @package 		JVM_Registry
 * 
 * @dependencies
 * @import JVM_Registry_Exception
 */
require_once('JVM/Registry/Exception.php');

class JVM_Registry{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */	
    /**
	* selfstorage stores object instances by Namespace
	* @var  self::object
	*/
	private static $_selfInstances = array();
	
   	/**
	* object-container/storage   
	* @var  :array
	*/
	private $_registry = array();
	
   	/**
	* allowed types rray   
	* @var  :array
	*/
	private $_allowedTypes = array();	

  	/**
	* static container array   
	* @var  :array
	*/
	private $nameSpace = NULL;
	
	/**
	* const nameSpace 
	* @var  :string
	*/
	const DEFAULT_NAMESPACE = 'JVM_DEFAULT_NAMESPACE';
/*	+-----------------------------------------------------------------------------------+
	| 	contruct and init functionallity
	+-----------------------------------------------------------------------------------+  */
   /**
    * @desc 
    * Initialize
    * 
    * @params void()
    * 
 	* @access protected
    */
	protected function __construct($nameSpace, $_allowedTypes){
		$this->nameSpace = $nameSpace;		
		$this->_allowedTypes = $_allowedTypes;	
	}
	
	/**
	* @desc
	* disallow cloning of obj
	* @access private	
	*/
	private function __clone(){} 

	/**
	* @desc
	* singleton method delivers single instance
	*
	* @void	
	*
	* @return :instance self this
	*
	* @access public
	*/  	
	public static function getInstance($nameSpace = NULL, array $_allowedTypes = NULL){
		if($nameSpace === NULL){
			$nameSpace = self::DEFAULT_NAMESPACE;	
		}
		if(!is_string($nameSpace) || !preg_match('/[a-zA-Z_]/', $nameSpace[0])){
			throw new JVM_Registry_Exception('nameSpace must be type of string with a length of at least 1 char an must start with a letter', 1001);	
		}
		if(!isset(self::$_selfInstances[$nameSpace]) || self::$_selfInstances[$nameSpace] === null){
			self::$_selfInstances[$nameSpace] = new JVM_Registry($nameSpace, $_allowedTypes);
		}
	return(self::$_selfInstances[$nameSpace]);
	}
		
	/**
    * @desc 
    * sets a new nameSpace
    *
	* @void
    * 
 	* @access public
    */	
	public function getAllowedTypes(){
	return($this->_allowedTypes);		
	}
	
	/**
    * @desc 
    * sets a new nameSpace
    *
	* @void
    * 
 	* @access public
    */	
	public function getNameSpace(){
	return($this->nameSpace);		
	}	
	
	/**
    * @desc 
    * sets a new nameSpace
    *
	* @input-required:
	* @param -> $nameSpace 	:string //name of assigned item
    * 
 	* @access public static 
    */	
	public static function getRegisteredInstances(){
		return(array_keys(self::$_selfInstances));
	}
		
	/**
    * @desc 
    * registers the passed object in container 
    *
	* @input-required:
	* @param -> $registryId 	:string //name of assigned item
	* @param -> $param 			:mixed //(object,array)
	*
	* @input-optional:
	* @param -> $overwrite		:boolean
    * 
 	* @access public 
    */	
	public function set($registryId, $registerValue, $overwrite = false){
		if(is_array($this->_allowedTypes)){
			if( (is_object($registerValue) && !in_array(get_class($registerValue), $this->_allowedTypes)) ||
				(!is_object($registerValue) && !in_array(gettype($registerValue), $this->_allowedTypes))
			){
				throw new JVM_Registry_Exception('this type ('.gettype($registerValue).') is not allowed. this namespace was bound to: '.implode(', ',$this->_allowedTypes), 1002);			
			}
		}
		if($this->isRegister($registryId) && $overwrite === false){
			throw new JVM_Registry_Exception('registry-id already in use! use overwrite-flag to re-set a register-entry.', 1003);	
		}
		if(!preg_match('/[a-zA-Z_]/', $registryId[0])){
			throw new JVM_Registry_Exception('a registryId must start with a letter.', 1004);		
		}
		$this->_registry[$registryId] = /*serialize*/($registerValue);
	return($this);
	}
		
	/**
    * @desc 
    * registers the passed object in container 
    *
	* @input-required:
	* @param -> $registryId 	:string //name of assigned item
	* @param -> $param 			:mixed //
    * 
 	* @access public static 
    */	
	public function get($registryId){
		if($this->isRegister($registryId)){
			return(($this->_registry[$registryId]));
		}
	return(NULL);
	}

	/**
    * @desc 
    * removes the object from container 
    *
	* @input-required:
	* @param -> $registryId :string //name of assigned item
    * 
 	* @access public
    */	
	public function delete($registryId){
		if($this->isRegister($registryId)){
			unset($this->_registry[$registryId]);
		}
	return($this);
	}
	
	/**
    * @desc 
    * removes all objects from container 
    *
	* @void
    * 
 	* @access public static
    */	
	public function clear(){
		$this->_registry = array();
	return($this);
	}
	
	/**
    * @desc 
    * checks if object exists in registry
    *
	* @input-required:
	* @param -> $registryId :string //name of assigned item
    * 
 	* @access public static 
    */
	public function isRegister($registryId){
		if( 
			isset($this->_registry[$registryId]) && 
			$this->_registry[$registryId] !== NULL
		){
			return(true);
		}
	return(false);
	}
	
	/**
	* @description
	* returns all assigned registryIds
	*
	* @void
	*	
	* @return :array
	*
	* @access public static
	*/
	public function getRegister(){
		if(isset($this->_registry) && is_array($this->_registry)){
			return(array_keys($this->_registry));	
		}
	return(array());
	}
	
	/**
	* @description
	* enables direct access
	*
	* @input-required:
	* @param -> $registryId	:string	
	*	
	* @return :mixed
	*
	* @access public
	*/	
	public function __isset($registryId){
		return(
			$this->isRegister($registryId)
		);
	}

	/**
	* @description
	* dissallow direct access
	*
	* @input-required:
	* @param -> $name		:string	
	* @param -> $value		:string	
	*	
	* @return :mixed
	*
	* @access public
	*/	
	public function __set($name, $value){
		throw new JVM_Registry_Exception('direct setting is not allowed! use set() instead', 1002);
	}	
	
	/**
	* @description
	* enables direct access
	*
	* @input-required:
	* @param -> $registryId	:string	
	*	
	* @return :mixed
	*
	* @access public
	*/	
	public function __get($registryId){
		//var has higher prio than instance
		if($this->isRegister($registryId)){
			return(
				$this->get($registryId)
			);
		}
		elseif(isset(self::$_selfInstances[$registryId /*aka Namespace*/])){
			return(self::getInstance($registryId));
		}
	return(NULL);
	}	
	
}