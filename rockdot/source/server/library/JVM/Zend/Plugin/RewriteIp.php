<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2012, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc forces all script to https (redirects http-reqquests to https)
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 *
 * @dependencies
 * @import: Zend_Controller_Action_HelperBroker
 * @import: Zend_Controller_Plugin_Abstract		
 * @import: JVM_Http_Request
 * @import: JVM_Http_Response
 */
require_once('Zend/Controller/Plugin/Abstract.php');
require_once('Zend/Session/Namespace.php');
require_once('Zend/Session/Namespace.php');
require_once('JVM/Http/Request.php');
 
class JVM_Zend_Plugin_RewriteIp extends Zend_Controller_Plugin_Abstract{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @desc prixie list (2lc based)
	* @var  :array
	*/
	private $_proxies = array(
		'de' => '78.138.117.42',
		'at' => '213.164.18.147',
		'uk' => '80.88.201.121',
		'fr' => '91.121.27.218',
		'ch' => '213.188.40.62',
		'es' => '130.185.95.247',
		'pt' => '194.65.138.109',
		'be' => '85.26.55.236',
		'lu' => '194.154.214.173',
		'dk' => '93.166.121.107',
		'no' => '188.124.142.22',
		'se' => '176.10.215.6',
		'us' => '173.213.113.111',
		'mx' => '187.185.71.90',
		'nl' => '188.142.107.35'
	);
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* init ip (proxies) to overwrite $_SERVER['REMOTE_ADDR']
	*	
	* @input-optional:
	* @param -> $_config  :array|Zend_Config|JVM_Config
	*
	* @access public
	*/
	public function __construct($_config = array()){
		if(is_array($_config)){
			$_proxies = $_config;
		}
		elseif($_config instanceof Zend_Config || $_config instanceof JVM_Config){
			$_proxies = $_config->toArray();	
		}
		//fill and validate proxylist
		if(!empty($_proxies)){
			$this->_proxies = array();
			foreach($_proxies as $lc => $ip){
				if(!preg_match('/[a-z]{2}/', $lc)){
					throw new JVM_Zend_Plugin_Exception('ivalid 2lc submitted', 1001);		
				}
				if(!filter_var($ip, FILTER_VALIDATE_IP)){ //, FILTER_FLAG_IPV4, FILTER_FLAG_IPV6
					throw new JVM_Zend_Plugin_Exception('invalid ip-address', 1001);	
				}
				$this->_proxies[$lc] = $ip;
			}
		}
	}
	
	/**
	* @autocalled by callstack in Zend_Controller_Plugin_Abstract
	*
	* @desc
	* rewrites current ip
	*
	* @input-required:
	* @param -> $request :Zend_Controller_Request_Abstract
	*	
	* @return none
	*
	* @access public
	*/
    public function routeStartup(Zend_Controller_Request_Abstract $request){
		//set if ip switch submitted
		if(isset($request->system_iplc) && isset($this->_proxies[$request->system_iplc])){
			//set classinternal mock-ip
			JVM_Http_Request::setIp($this->_proxies[$request->system_iplc]);
			//overwrite global server-var
			$_SERVER['REMOTE_ADDR']	= $this->_proxies[$request->system_iplc];
		}   	
    }
}