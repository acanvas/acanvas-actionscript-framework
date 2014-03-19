<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2012, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc Maintanence/Interim 
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 *
 * @dependencies
 * @import: Zend_Controller_Plugin_Abstract
 */
require_once('Zend/Controller/Plugin/Abstract.php');
 
class JVM_Zend_Plugin_Maintenance extends Zend_Controller_Plugin_Abstract{
	/**
	* @description
	* redirect all requests to the maintenance page.
	*
	* @input-required
	* @param $request 	:Zend_Controller_Request_Abstract   
	*
	* @return :none
	*
	* @access public
	*/
	public function routeShutdown(Zend_Controller_Request_Abstract $request){
        $request->setActionName('index');
        $request->setModuleName('default');
        $request->setControllerName('maintenance');
    } 
}