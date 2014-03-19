<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2012, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc Form Wrapper-Class: handles error-messaging, allows setting a global css-error-class
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 *
 * @dependencies
 * @import: Zend_Form		
 * @dependencies (autoloding enabled)
 */
require_once('Zend/Form.php');
require_once('JVM/Config.php');
require_once('JVM/Zend/Form/Exception.php');
 
class JVM_Zend_Form extends Zend_Form{
/*	+-----------------------------------------------------------------------------------+
	| 	class-member-vars
	+-----------------------------------------------------------------------------------+  */
	/**
	* form configuration object 
	* @var JVM_Config
	*/
	protected $FormConfig = NULL;	
	
	/**
	* global css-form-error-class
	* @var string
	*/
	protected $cssError = '';
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @description
	* loads form configuration file an inits the parent::form (setup)
	*
	* @input-required
	* @param $options 	:array
	*
	* @return none
	*
	* @access public
	*/
	public function __construct($options = NULL){
		if(!isset($options['config']) && !$options instanceof JVM_Config){
			throw new JVM_Zend_Form_Exception('configuration is missing', 1001);	
		}
		//add configuration file
		if($options instanceof JVM_Config){
			$this->FormConfig = $options;	
		}
		elseif(is_string($options['config']) || is_array($options['config'])){
			$this->FormConfig = new JVM_Config(
				$options['config']
			);
		}
		if(isset($options['csserror']) && is_string($options['csserror'])){
			$this->cssError = $options['csserror'];	
		}
		parent::__construct($options);		
	}
	
	/**
	* @description
	* sets css error class
	*
	* @input-required
	* @param $cssError :string
	*
	* @return :this
	*
	* @access public
	*/
	public function setCssErrorClass($cssError){
		if(!is_string($cssError)){
			throw new JVM_Zend_Form_Exception('cssErrorClass must be type of string', 1001);
		}
		$this->cssError = $cssError;
	return $this;
	}
	
	/**
	* @description
	* returns customized errorstack based on config array
	*
	* @void  
	*
	* @return :array
	*
	* @access public
	*/
	public function getErrorStack(){
		//setup error messages
		$_errorMessages = array();
		//------------------------------------------------------------------
		//handles localized error-messages - remap zend-formerrror-messages
		foreach($this->getMessages() as $elementName => $_elementErrors){
			foreach($_elementErrors as $type => $message){
				if(isset($this->$elementName) && $this->$elementName->hasErrors()){
					//-----------------------------------------
					//replace vars
					$_replace = array(
						'%min%'   => ($this->$elementName->getValidator('StringLength')  ? $this->$elementName->getValidator('StringLength')->getMin() : ''),
						'%max%'   => ($this->$elementName->getValidator('StringLength') ? $this->$elementName->getValidator('StringLength')->getMax() : ''),
						'%value%' => htmlentities($this->$elementName->getValue(), ENT_COMPAT, APPLICATION_ENC, false)
					);
					//-----------------------------------------
					//set message template
					if(isset($this->FormConfig->errors->$elementName->$type)){
						//error-message
						$_errorMessages[$elementName][$type] = str_replace(
							array_keys($_replace), 
							array_values($_replace), 
							$this->FormConfig->errors->$elementName->$type
						);
					}
					elseif(isset($this->FormConfig->errors->$elementName->default)){
						$_errorMessages[$elementName]['default'] = str_replace(
							array_keys($_replace), 
							array_values($_replace), 
							$this->FormConfig->errors->$elementName->default
						);	
					}
					else{
						$_errorMessages[$elementName]['messageMissing'] = 'Errors in: '.$elementName;		
					}
					//-----------------------------------------
				}
			}
		}	
		//------------------------------------------------------------------
		//add error classes
		if($this->cssError != NULL){
			foreach ($this->getElements() as $element) {
				if(isset($_errorMessages[$element->getName()])){
					//add error class to element
					$element->setAttrib(
						'class', 
						$element->getAttrib('class').' '.$this->cssError
					);
				}
			}
		}
	return $_errorMessages;
    }
	
	/**
	* @description
	* returns form configuration file
	*	
	* @void
	*
	* @return :JVM_Config
	*
	* @access public
	*/
	public function getFormConfig(){
	return $this->FormConfig;
	} 
}