<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2012, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc Detect Mobile Plugin - detects mobile / non-mobile devices
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 *
 * @dependencies
 * @import: Zend_Controller_Plugin_Abstract		
 * @import: Zend_View	
 * @import: Zend_Layout	 	
 * @import: Zend_Auth		
 * @import: JVM_Zend_View_Helper_Page		
 * @import: JVM_Zend_Plugin_Exception			
 */
require_once('Zend/Controller/Plugin/Abstract.php');
require_once('Zend/View.php');
require_once('Zend/Auth.php');
require_once('Zend/Layout.php');
 
class JVM_Zend_Plugin_LoginStatus extends Zend_Controller_Plugin_Abstract{
	/**
	* @description
	* set view parameter if user logged in
	*
	* @input-required
	* @param $request 	:Zend_Controller_Request_Abstract   
	*
	* @return :none
	*
	* @access public
	*/
	public function preDispatch(Zend_Controller_Request_Abstract $request){
		try{
			$view = Zend_Layout::getMvcInstance()->getView();
			if((!Zend_Auth::getInstance()->getStorage()->isEmpty() && Zend_Auth::getInstance()->hasIdentity())){
				$view->user =Zend_Auth::getInstance()->getIdentity();
				$view->isLoggedIn = true;
			}
			else{
				$view->user = false;
				$view->isLoggedIn = false;	
			}
		}
		catch(Exception $e){}
    }

}