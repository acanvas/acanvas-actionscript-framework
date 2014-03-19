<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2012, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc JVM_Zend_View_Helper_FormText extends Zend_View_Helper_FormText
 * renders html-5 specific input fields (ie. <input type="email"...)
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 * @package________JVM_Zend_View_Helper       
 *
 * @dependencies
 * @import: Zend_View_Helper_FormText		 
 */
require_once('Zend/View/Helper/FormText.php');
 
class JVM_Zend_View_Helper_FormText extends Zend_View_Helper_FormText{
	/**
	* @desc overwrites Zend_View_Helper_FormText with custom render function
	* allows to render htm-5 input-elements or the parent default 'text' element.
	* 
	* @see Zend_View_Helper_FormText for more info
	*
	* @access public
	*
	* @param string|array $name If a string, the element name. If an
	* array, all other parameters are ignored, and the array elements
	* are used in place of added parameters.
	*
	* @param mixed $value The element value.
	*
	* @param array $attribs Attributes for the element tag.
	*
	* @return string The element XHTML.
	*/
    public function formText($name, $value = NULL, $_attribs = NULL){
        $info = $this->_getInfo($name, $value, $_attribs);
		//extract: name, value, attribs, options, listsep, disable
        extract($info); 
		//element disabled
        $disabled = (($disable) ? ' disabled="disabled"' : '');
        //XHTML or HTML end tag?
        $endTag = ' />';
        if (($this->view instanceof Zend_View_Abstract) && !$this->view->doctype()->isXhtml()){
            $endTag= '>';
        }
        $type = 'text';
        if(isset($_attribs['type'])){
            $type = $_attribs['type'];
            unset($_attribs['type']);
        }
        return( 
			'<input type="'.$type.'" '.
			' name="'.$this->view->escape($name).'"'.
			' id="'.$this->view->escape($id).'"'.
			' value="'.$this->view->escape($value).'"'.
			$disabled.
			$this->_htmlAttribs($_attribs).
			$endTag
		);
    }
	
}