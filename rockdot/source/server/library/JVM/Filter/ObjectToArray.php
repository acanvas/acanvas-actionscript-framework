<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2012, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc extends JVM_Filter_Abstract for concrete implementation
 * filters input parse Object to array
 * 
 * @author          joerg.diterlizzi
 * @version         
 * @lastmodified:   
 * @copyright       Copyright (c) Jung von Matt / Neckar
 * @package         JVM_Filter
 *
 * @dependencies
 * @import: JVM_Exception
 * @import: JVM_Filter_Abstract	 
 */
require_once('JVM/Filter/Exception.php');
require_once('JVM/Filter/Abstract.php');
	
class JVM_Filter_ObjectToArray extends JVM_Filter_Abstract{	
/*	+-----------------------------------------------------------------------------------+
	| 	class-member-vars
	+-----------------------------------------------------------------------------------+  */
	/**
	* document version
	* @var int
	*/
	private $ignoreVisibility = false;
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @description
	* overwrites parents empty construct
	*	
	* @input-optional
	* @param $ignoreVisibility	:boolean
	*
	*
	* @return none
	*
	* @access public
	*/
	public function __construct($ignoreVisibility = false){
		if(is_array($ignoreVisibility) && isset($ignoreVisibility['options']) && is_array($ignoreVisibility['options'])){
			$this->setOptions($ignoreVisibility['options']);	
		}
		else{
			$this->setIgnoreVisibility($ignoreVisibility);
		}
	}
	
	/**
	* @description
	* set ignoreVisibility flag
	*	
	* @input-optional
	* @param $ignoreVisibility 	:boolean 
	*
	* @return this
	*
	* @access public
	*/
	public function setIgnoreVisibility($ignoreVisibility){
		if(!is_bool($ignoreVisibility)){
			throw new JVM_Filter_Exception('ignoreVisibility must be type of boolean', 1001);	
		}
		$this->ignoreVisibility = $ignoreVisibility;
	return $this;
	}	
	
	/**
	* @desc 
	* abstract inherited method defined in JVM_Filter_Abstract must be overridden
	* returns filtered-value
	*
	* @input-required
	* @param $value :mixed
	*
	* @return string	
	*
	* @access public
	*/
	public function filter($value){
		if($this->ignoreVisibility === true){
			$reflect = new ReflectionClass($value);
			$_properties  = $reflect->getProperties();
			/*if($this->ignoreVisibility === true){ $_properties  = $reflect->getProperties(); }
			else{ $_properties  = $reflect->getProperties(ReflectionProperty::IS_PUBLIC);	 }*/
			foreach($_properties as $property) {
				$property->setAccessible(true);
				$_return[$property->getName()] = $property->getValue($value);
			}	
			return $_return;
		}
		else{
			$_return = array();
			if(is_object($value)){
				$_input = get_object_vars($value);
			}
			else{
				$_input = $value;
			}
			foreach ($_input as $name => $val) {
				if(is_array($val) || is_object($val)) {
					$val = $this->filter($val);
				}
				$_return[$name] = $val;
			}
			return $_return;
		}
	}
	
}