<?php
class MessagebrokerController extends Zend_Controller_Action 
{ 
	public function init()
	{
 		$this->_helper->layout()->disableLayout();
	}
 
	public function amfAction()
	{
		$server = new Zend_Amf_Server();
		$server->addDirectory(APPLICATION_PATH . '/services/');
		echo($server->handle());
	}
	
	public function testAction()
	{
		
	}
}