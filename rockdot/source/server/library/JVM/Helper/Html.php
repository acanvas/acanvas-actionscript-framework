<?php
/*	
+-----------------------------------------------------------------------------------+
| Copyright (c) 2011, Joerg Di Terlizzi												|
| All rights reserved.																|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>								|
+-----------------------------------------------------------------------------------+ 
*/
/**
 * JVM_Helper_Html Helper Class for rendering Html
 * 
 * @author joerg.diterlizzi
 * @version 1.0
 * @import: JVM_Helper_Html_Exception
 */
require_once('JVM/Helper/Html/Exception.php');

class JVM_Helper_Html{
/*  +-----------------------------------------------------------------------------------+
	| 	class member-vars
	+-----------------------------------------------------------------------------------+  */		
	/**
	* @var  string  element-tag
	* @access private
	*/
	private $element = '';
	
	/**
	* @var  boolean 
	* @access private
	*/
	private $isXHtml = true;
	
	/**
	* @var  boolean 
	* @access private
	*/
	private $allowCustomAttributes = true;	

	/**
	* @var  array attributes
	* @access private
	*/
	private $_attributes = array();
	
	/**
	* @var  string (element-type)
	* @access private
	*/
	private $renderType = '';	
	
	/**
	* @var  string (element content / body /inner HTML)
	* @access private
	*/
	private $body = '';
	
	/**
	* @var  array (suported elements)
	* @access private
	*/
	private $_validElements = array(
		'tagclosing' => array(
			'p',
			'a',
			'h1',
			'h2',
			'h3',
			'h4',
			'h5',
			'h6',		
			'div',
			'table',
			'tbody',
			'thead',
			'tfoot',
			'th',
			'td',
			'tr',
			'span',
			'ul',
			'ol',
			'li',
			'code',
			'font',
			'textarea'
		),
		'selfclosing' => array(
			'button',
			'input',						
			'img',
			'br'
		)
	);
	
	/**
	* @var  array (suported attributes)
	* @access private
	*/
	private $_validAttributes = array(
		'id',
		'name',
		'value',
		'type',
		'checked',
		'selected',
		'src',
		'href',
		'title',
		'alt',
		'rel',
		'style',
		'class',
		'width',
		'height',
		'onclick',
		'ondblclick',
		'onblur',
		'onchange',
		'onfocus',
		'onreset',
		'onselect',
		'onsubmit',
		'onselect',
		'onmouseout',
		'onmouseover',
		'onmouseup',
		'onmousedown',
		'onkeydown',
		'onkeypress',
		'onkeyup',
		'tabindex',
		'target',
		'type',
		'shape'
	);
	
	/**
	* @var  array (not supported attributes)
	* @access private
	*/
	private $_invalidAttributes = array(
		'ct', 
		'body',
		'html',
		'text',
		'doctype',
		'meta',
		'link'
	);
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* switch on /off
	*
	* @input-not-required:
	* @param -> $element		:string
	* @param -> $_attributes	:array
	*
	* @return :true
	*
	* @access public
	*/ 
	public function __construct($element, $_attributes = array(), $allowCustomAttributes = true, $isXHtml = true){
		$this->setElement($element);
		$this->setAttributes($_attributes);
		$this->setAllowCustomAttributes($allowCustomAttributes);
		$this->setXHtml($isXHtml);
	}

	/**
	* @desc
	* renders attributes in array-structure
	*
	* @input-not-required:
	* @param -> $_params		:array  
	* ex.: array('id' => 'testId', 'class' => 'testClass');
	*
	* @return :this
	*
	* @access public
	*/ 
	public function setAttributes($_input){
		if(is_array($_input) && !empty($_input)){
			foreach($_input as $attribute => $parameter){
				if($parameter !== '' && is_string($parameter)){
					switch($attribute){
						case(
							( in_array($attribute, $this->_validAttributes) || $this->allowCustomAttributes === true ) && 
							( !in_array($attribute, $this->_invalidAttributes) )
						):
						case(strstr($attribute, 'data-')):
							if(strstr($parameter, '"')){//avoid json errors
								$this->_attributes[$attribute] = " ".$attribute."='".$parameter."'";	
							}
							else{
								$this->_attributes[$attribute] = ' '.$attribute.'="'.$parameter.'"';
							}
						break;
						case('ct'):
						case('body'):
						case('html'):
						case('text'):
							$this->setContent($parameter);
						break;
						default:
							//throw new JVM_Helper_Html_Exception('Attribute: '.$attribute.' not supported');
						break;
					}
				}
			}
		}
	return $this;
	}
	
	/**
	* @desc
	* unsets attributes
	*
	* @void
	*
	* @return :this
	*
	* @access public
	*/ 
	public function unsetAttributes(){
		$this->_attributes = array();
	return $this;	
	}
	
	/**
	* @desc
	* delivers attributes
	*
	* @void
	*
	* @return :true
	*
	* @access public
	*/ 
	public function getAttributes(){
	return(implode('', $this->_attributes));
	}
	
	/**
	* @desc
	* renders attributes in array-structure
	*
	* @void
	*
	* @return :array
	*
	* @access public
	*/ 
	public function getElement(){
		return($this->element);	
	}
	
	/**
	* @desc
	* returns closure for element
	*
	* @void
	*
	* @return :array
	*
	* @access public
	*/ 
	private function getClosure(){
		if($this->isXHtml && $this->renderType == 'selfclosing'){
			return(' />');	
		}
		elseif(!$this->isXHtml && $this->renderType == 'selfclosing'){
			return('></'.$this->element.'>');	
		}
		else{
			return('</'.$this->element.'>');
		}
		throw new JVM_Helper_Html_Exception('unknown error during rendering', 1001);
	}
	
	/**
	* @desc
	* sets xhtml flag
	*
	* @input-required:
	* @param -> $flag :boolean
	*
	* @return :this
	*
	* @access public
	*/
	public function setXHtml($flag){
		if(!is_bool($flag)){
			throw new JVM_Helper_Html_Exception('argument (flag) must be type of boolean', 1001);
		}
		$this->isXHtml = $flag;
	return $this;
	}
	
	/**
	* @desc
	* sets allowCustomAttributes flag
	*
	* @input-required:
	* @param -> $flag :boolean
	*
	* @return :this
	*
	* @access public
	*/
	public function setAllowCustomAttributes($flag){
		if(!is_bool($flag)){
			throw new JVM_Helper_Html_Exception('argument (flag) must be type of boolean', 1001);
		}
		$this->allowCustomAttributes = $flag;
	return $this;
	}
	
	/**
	* @desc
	* sets the current element
	*
	* @input-required:
	* @param -> $element :string
	*
	* @return :this
	*
	* @access public
	*/
	private function setElement($element){
		if(!is_string($element)){
			throw new JVM_Helper_Html_Exception('argument (element) must be type of string', 1002);	
		}
		if(in_array($element, $this->_validElements['tagclosing'])){	
			$this->renderType = 'tagclosing';
		}
		elseif(in_array($element, $this->_validElements['selfclosing'])){	
			$this->renderType = 'selfclosing';
		}
		else{
			throw new JVM_Helper_Html_Exception('Element: '.(string) $element.' not supported', 1003);	
		}
		$this->element = $element;
	return $this;
	}
	
	/**
	* @desc
	* adds data to body/content
	*
	* @input-required:
	* @param -> $data :mixed (string|JVM_Helper_Html)
	*
	* @return :this
	*
	* @access public
	*/
	public function addContent($data){
		if($data instanceof JVM_Helper_Html){
			$data = $data->render();	
		}
		$this->body .= $data;
	return $this;
	}
	
	/**
	* @desc
	* set body/content
	*
	* @input-required:
	* @param -> $data :mixed (string|JVM_Helper_Html)
	*
	* @return :this
	*
	* @access public
	*/
	public function setContent($data){
		if($data instanceof JVM_Helper_Html){
			$data = $data->render();	
		}
		$this->body = $data;
	return $this;
	}
	
	/**
	* @desc
	* clears body
	*
	* @void
	*
	* @return :this
	*
	* @access public
	*/
	public function unsetContent(){
		$this->body = '';
	return $this;
	}
	
	/**
	* @desc
	* returns body
	*
	* @void
	*
	* @access public
	*/
	public function getContent(){
	return $this->body;
	}
	
	/**
	* @desc
	* renders element with passed attributes
	*
	* @void
	*
	* @return :string (rendered html)
	*
	* @access public
	*/
	public function render(){
		if($this->renderType === 'tagclosing'){
			return('<'.$this->element.$this->getAttributes().'>'.$this->getContent().$this->getClosure());	
		}
		if($this->renderType === 'selfclosing'){
			return('<'.$this->element.$this->getAttributes().$this->getClosure());
		}
	}
	
	/**
	* @desc
	* renders and displays current element
	*
	* @void
	*
	* @return :array
	*
	* @access public
	*/
	public function display(){
		echo $this->render();
	return $this;
	}
	
	/**
	* @desc
	* implements magic method __toString()
	* in case of direct output o$this
	*
	* @void
	*
	* @return :string 
	*
	* @access public
	*/
	public function __toString(){
		return ($this->render());
	}

}