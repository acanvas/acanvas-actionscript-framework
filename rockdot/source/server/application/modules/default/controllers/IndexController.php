<?php

class IndexController extends Zend_Controller_Action
{

    public function init()
    {
        /* Initialize action controller here */
    }

    public function indexAction()
    {
    	$config = Zend_Registry::get('Application_Config');
    	$jvm_registry = JVM_Registry::getInstance();
    	
    	$fb_sig = $jvm_registry->get('fb_sig_data');
    	$app_data = $jvm_registry->get('app_data');
    	$request_ids = $this->getRequest()->getQuery("request_ids");
    	
    	/* ### Automatic Auth in FB Frame in case of App Data ### */
    	if(!empty($fb_sig['user_id']) && !empty($app_data) && $config->facebook->autoAuthInFBFrame == true)
    	{
    		echo $this->view->partial('partials/fbRedirect.phtml');
    	}
    	/* ### USER IS COMING VIA APP-REQUEST ### */
    	else if( !empty($request_ids)){
    		echo $request_ids;
    		//$this->_redirect('/requests');
    	}
    	/* ### USER IS FAN ### */
    	else if( ($fb_sig && $fb_sig["page"]["liked"]==1) || $this->getRequest()->getQuery("gate")=="off"){
    		//render index.phtml
    	}
    	/* ### USER IS NO FAN (FANGATE) ### */
    	else{
    		$this->_redirect('/fangate');
    	}
    	
    	
    	//see if we have any access to fb
		/*
		if(Zend_Auth::getInstance()->hasIdentity())
		{
			$this->view->identity = Zend_Auth::getInstance()->getIdentity();
			$this->view->userObj = $this->view->identity['user'];
		}
		*/
    }
    
    public function fangateAction()
    {
    	//display fangate
    }

    public function requestsAction()
    {
    	$configuration_locale = Zend_Registry::get('Application_Config_Locale');
    	$config = Zend_Registry::get('Application_Config');
    	
    	//get request data and redirect
    	$a_request_ids = explode(",", $this->getRequest()->getQuery("request_ids"));
    	
    	$adapter = Zend_Registry::get('db');
    	
    	$select = $adapter->select();
		$select->from($config->db->prefix . '_log_invites');
		$select->where('request_id = ?', $a_request_ids[sizeof($a_request_ids )-1]);
		$select->limit(1);
		
		$rows = $adapter->fetchAll(
				$select
		);
		
		$this->view->invite_app_data = $rows[0]["data"];
		$this->view->invite_redirect = $configuration_locale->page_url;
		
		echo $this->view->partial('partials/requestsRedirect.phtml');
    }


}

