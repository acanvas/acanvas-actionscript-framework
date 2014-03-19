<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2012, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc Plugin_Navigation_Helper is an navigation helper class for linking, currentPage infos and more
 * (this class is Plugin and ViewHelper at the same time )
 * renders pagetitle an meta-tags
 * switches protocol to ssl-https if specified in navigation-config 
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
 * @import: JVM_Helper_Html	
 * @import: JVM_Http_Uri
 * @import: JVM_Http_Request
 * @import: JVM_Http_Response	
 * @import: JVM_Zend_View_Helper_Exception
 * @dependencies (autoloding enabled)
 */
require_once('Zend/Controller/Plugin/Abstract.php');
require_once('Zend/Controller/Action/HelperBroker.php');
require_once('JVM/Http/Request.php');
require_once('JVM/Http/Response.php');
require_once('JVM/Http/Uri.php');
require_once('JVM/Helper/Html.php');
require_once('JVM/Zend/View/Helper/Exception.php');
 
class JVM_Zend_View_Helper_Page extends Zend_Controller_Plugin_Abstract{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */		
   	/**
	* meta/title sourceheader defaults
	* NOTICE! example values please overwrite when using plugin
	* @var  :array
	*/
	private $_defaults = array(
		'keywords' 	=> '',
		'desc'		=> '',
		'title' 	=> '',
		'tracking'	=> array()
	);
	
	/**
	* default doctype
	* @var  :string
	*/
	private $doctype = 'HTML5';
	
	/**
	* default charset (encoding)
	* @var  :string
	*/
	private $charset = 'UTF-8';
	
	/**
	* add language to generated links
	* @var  :boolean
	*/
	private static $addLanguage = false;
	
	/**
	* render links as html (default: true)
	* @var  :boolean
	*/
	private static $htmlify = true;
	
	/**
	* current active path
	* @var  :array
	*/
	private static $_activePath = array();
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* renders a naviagtion link by its id
	*
	* @input-optional:
	* @param -> $_options		:array
	*
	* @return :none
	*
	* @access public
	*/ 
	public function __construct(array $_options = array()){
		$this->setOptions($_options);
	}
	
	/**
	* @description
	* setOptions
	*
	* @void
	*
	* @return :string
	*
	* @access public
	*/
	public function setOptions(array $_options = array()){
		//set-options
		if(!empty($_options)){
			foreach($_options as $name => $_args){
				$func = (string) 'set'.ucwords(strtolower($name));
				if(method_exists($this, $func) && $func !== 'setOptions'){
					$_args = array($_args);	
					if(!empty($_args)){
						call_user_func_array(array($this, $func), $_args);	
					}
				}
			}
		}	
	return $this;
	}
	
	/**
	* @description
	* set addLanguage flag (all links append language flag)
	*	
	* @input-optional
	* @param $addLanguage :boolean   
	*
	* @return none
	*
	* @access public static
	*/
	public static function setAddLanguage($addLanguage){
		if(!is_bool($addLanguage)){
			throw new JVM_Zend_View_Helper_Exception('addLanguage must be type of boolean');	
		}
		self::$addLanguage = $addLanguage;	
	}
	
		
	/**
	* @description
	* set htmlify flag (all links)
	*	
	* @input-optional
	* @param $htmlify :boolean   
	*
	* @return none
	*
	* @access public static
	*/
	public static function setHtmlify($htmlify){
		if(!is_bool($htmlify)){
			throw new JVM_Zend_View_Helper_Exception('htmlify must be type of boolean');	
		}
		self::$htmlify = $htmlify;	
	}
	
	/**
	* @description
	* set doctype
	*	
	* @input-optional
	* @param $doctype 	:string   
	*
	* @return this
	*
	* @access public
	*/
	public function setDoctype($doctype){
		if(!is_string($doctype)){
			throw new JVM_Zend_View_Helper_Exception('doctype must be type of string');	
		}
		$this->doctype = $doctype;
	return $this;	
	}
	
	/**
	* @description
	* set charset
	*	
	* @input-optional
	* @param $charset 	:string   
	*
	* @return this
	*
	* @access public
	*/
	public function setCharset($charset){
		if(!is_string($charset)){
			throw new JVM_Zend_View_Helper_Exception('charset must be type of string');	
		}
		$this->encoding = $charset;
	return $this;	
	}
	
	/**
	* @description
	* set _defaults
	*	
	* @input-optional
	* @param $_defaults 	:array   
	*
	* @return this
	*
	* @access public
	*/
	public function setDefaults(array $_defaults){
		foreach($_defaults as $name => $value){
			$this->_defaults[$name] = $value;
		}
	return $this;	
	}
	
	/**
	* @description
	* set _active Page
	*	
	* @input-optional
	* @param $_defaults 	:array   
	*
	* @return this
	*
	* @access public
	*/
	public function setActivePath(array $_options){
		if(is_array(self::$_activePath)){
			foreach($_options as $name => $value){
				self::$_activePath[$name] = $value;
			}
		}
	return $this;	
	}
		
	/**
	* @notice Zend_View_Helper
	* Zend_Layout::getMvcInstance()->getView()->registerHelper(new Plugin_Navigation_Helper(), 'link');
	*
	* @desc
	* returns a rendered naviagtion link (byid)
	* returns an empty string in case of error/exception
	*
	* @dependencies
	* JVM_Helper_Html
	* JVM_Http_Uri
	*
	* @input-required:
	* @param -> $id				:string int
	*
	* @input-optional:
	* @param -> $_options		:array
	*
	* @dependencies
	* @import: JVM_Helper_Html
	* @import: JVM_Http_Uri
	*
	* @return :string 
	*
	* @access public static
	*/
	public static function link($id, array $_options = array()){
		//empty array as default
		if($_options == false || $_options == NULL){
			$_options = array();	
		}
		//htmlifyflag
		if((isset($_options['htmlify']) && is_bool($_options['htmlify']))){
			self::$htmlify = $_options['htmlify'];	
		}
		//language flag
		if(isset($_options['lang']) && is_bool($_options['lang'])){
			self::$addLanguage = $_options['lang'];
		}
		try{
			if(!is_string($id) && is_int($id)){
				throw new JVM_Zend_View_Helper_Exception('id must be type of string or integer', 1000);	
			}
			//try to load node (Zend_Navigation_Page_Mvc)
			$node = self::getNodeById($id);
			//if node found and valid
			if($node instanceof Zend_Navigation_Page_Mvc){
				//--------------------------------------
				//custom html features
				if(isset($node->customHtmlAttribs)){
					foreach($node->customHtmlAttribs as $name => $value){
						if(is_string($value)){
							$_options[$name] = $value;	
						}
					}
				}
				//--------------------------------------
				//set defaults from active node 
				if(!isset($_options['html'])){
					$_options['html']  = $node->label;
				}
				if(!isset($_options['title'])){
					$_options['title'] = $node->label;
				}
				if(!isset($_options['class']) && isset($node->class)){
					$_options['class'] = $node->class;
				}
				//--------------------------------------
				//empty array as default (params -> query string)
				if(!isset($_options['params'])){
					$_options['params'] = array();	
				}
				//--------------------------------------
				//prepend domain (for absolute links only) 
				$domain = '';
				if(isset($_options['domain'])){
					//--------------------------------------
					//prepend scheme (for absolute links only) 
					$protocol = 'http://';
					if(isset($_options['ssl']) && $_options['ssl'] === true){
						$protocol = 'https://';
					}
					if($_options['domain'] === true && defined('APPLICATION_URI')){
						$domain = $protocol.APPLICATION_URI;		
					}
					elseif($_options['domain'] === true){
						$domain = $protocol.$_SERVER['HTTP_HOST'];		
					}
					elseif(is_string($_options['domain'])){
						$domain = $_options['domain'];	
					}
				}
				//--------------------------------------
				//possibility to prepend language route (ex. doman.de/en/)
				$lang = '';
				if(self::$addLanguage === true && Zend_Registry::get('Zend_Locale')){
					$lang = '/'.Zend_Registry::get('Zend_Locale')->getLanguage();
				}
				//--------------------------------------
				//possibility to append fragment
				$fragment ='';
				if(isset($_options['fragment']) && is_string($_options['fragment'])){
					$fragment = (!strstr($_options['fragment'][0], '#') ? '#' : '').$_options['fragment'];			
				}
				//--------------------------------------
				//possibility to append string to path
				$append ='';
				if(isset($_options['append']) && is_string($_options['append'])){
					$append = $_options['append'];
				}
				//--------------------------------------
				//handle external links (links must be valid)
				if(isset($node->uri)){
					$link = $node->uri;
				}
				//handle internal links
				else{
					$link = $domain . $lang . $node->getHref() . $append . $fragment;
				}
				//--------------------------------------
				//build link
				$uri = new JVM_Http_Uri($link, $_options['params']);
				$_options['href'] = $uri->getUrl();
				//--------------------------------------
				//return the link only no html
				if(self::$htmlify === false){
					return $uri;
				}
				//--------------------------------------
				//render html
				return ((string) new JVM_Helper_Html('a', $_options));
			}
		}
		catch(Exception $e){
			return '';
		}
	}
		
	/**
	* @desc
	* rentuns found node or null
	*
	* @input-required:
	* @param -> $id				:string
	*
	* @return :Zend_Navigation_Page_Mvc || NULL
	*
	* @access public static 
	*/
	public static function getNodeById($id){
		try{
			$node = Zend_Controller_Action_HelperBroker::getExistingHelper('ViewRenderer')->view->navigation()->findOneById($id);	
			if($node instanceof Zend_Navigation_Page_Mvc){
				return $node;	
			}
		}
		catch(Exception $e){
			return NULL; //if not found / no object but NULL be returned 
		}
	}
	
	/**
	* @desc
	* rentuns found node (optional an nodeindex)
	*
	* @input-required:
	* @param -> $id				:string
	*
	* @input-optional:
	* @param -> $index			:string
	*
	* @return :Zend_Navigation_Page_Mvc || NULL
	*
	* @access public static 
	*/
	public static function navigationNode($id, $index){
		$node = self::getNodeById($id);
		if($node!= NULL && isset($node->$index)){
			return $node->$index;		
		}
	return '';
	}
	
	/**
	* @desc
	* returns active node or null
	*
	* @void
	*
	* @return :Zend_Navigation_Page_Mvc || NULL
	*
	* @access public static 
	*/
	public static function getActiveNode(){
		try{
			//get view
			$view = Zend_Controller_Action_HelperBroker::getExistingHelper('ViewRenderer')->view;
			//try to match active node
			$node = $view->navigation()->findOneBy('active', true);		
			//if not found try to find by Route		
			if(!$node instanceof Zend_Navigation_Page_Mvc){
				$node = $view->navigation()->findOneByRoute(
					str_replace('_lang', '', Zend_Controller_Front::getInstance()->getRouter()->getCurrentRouteName())
				); 
			}
			if($node instanceof Zend_Navigation_Page_Mvc){
				return $node;	
			}
		}
		catch(Exception $e){
			return NULL; //if not found / no object but NULL will be returned 
		}
	}
	
	/**
	* @desc
	* returns boolean if page id is active
	*
	* @input-required:
	* @param -> $id :string (or int)
	*
	* @return :boolean
	*
	* @access public static 
	*/
	public static function isActivePage($id){
		$node = self::getActiveNode();
		if(isset($node->id) && $node->id === $id){
			return true;	
		}
	return false;
	}
	
	/**
	* @autocalled by callstack in Zend_Controller_Plugin_Abstract
	*
	* @desc
	* renders global page title, meta, tracking vars and more
	* NOTICE! does ssl switch if index "ssl" set to true in navigation config
	*
	* @input-required:
	* @param -> $request :Zend_Controller_Request_Abstract
	*
	* @dependencies
	* @import: JVM_Http_Request
	* @import: JVM_Http_Response
	*	
	* @return this
	*
	* @access public
	*/
    public function preDispatch(Zend_Controller_Request_Abstract $request){
        try{
			//-------------------------------------------------------------
			//get view
			$view = Zend_Controller_Action_HelperBroker::getExistingHelper('ViewRenderer')->view;
			//-------------------------------------------------------------
			//find active page
			$activePage = $view->navigation()->findOneBy('active', true);
			//-------------------------------------------------------------
			//woraround for regex routes (router)
			if($activePage == NULL && Zend_Controller_Front::getInstance()->getRouter()->getCurrentRouteName() != 'default'){
				$activePage = $view->navigation()->findOneByRoute(
					str_replace('_lang','', Zend_Controller_Front::getInstance()->getRouter()->getCurrentRouteName())
				);
			}
			//-------------------------------------------------------------
			//switch protocols to https if defined in navigation-node (ssl = true) 
			if(APPLICATION_ENV === 'production' && isset($activePage->ssl) && $activePage->ssl === true && !JVM_Http_Request::isSSL()){
				JVM_Http_Response::forwardSsl();
			}
			//---------------------------------------------------------
			//setdoctype
			$view->doctype($this->doctype);
			//---------------------------------------------------------
			//set charset vs httpequiv
			if($this->doctype === 'HTML5'){
				$view->headMeta()->setCharset($this->charset);
			}
			else{
				$view->headMeta()->setHttpEquiv('Content-Type', 'text/html;charset='.strtolower($this->charset));	
			}
			//-------------------------------------------------------------
			if($activePage instanceof Zend_Navigation_Page_Mvc){
				//---------------------------------------------------------
				//setting up page title / tracking / meta
				$view->activePage = self::$_activePath = $activePage->toArray();
				$view->headline = $activePage->label;
				$view->headTitle($activePage->title, 'SET');
				//---------------------------------------------------------
				//keywords
				if(isset($activePage->keywords) && !empty($activePage->keywords)){
					$view->headMeta()->setName('keywords', $activePage->keywords);	
				}
				//---------------------------------------------------------
				//desc
				if(isset($activePage->desc) && !empty($activePage->desc)){
					$view->headMeta()->setName('description', $activePage->desc);	
				}
				//----------------------------------------------------------
				//add (https) to title if develserver has no ssl just for informational usage
				if(APPLICATION_ENV !== 'production' && isset($activePage->ssl) && $activePage->ssl === true && !JVM_Http_Request::isSSL()){
					$view->headTitle('(https)', 'PREPEND')->setSeparator(' - ');
				}
				//---------------------------------------------------------
			}
			else{
				$this->setPageDefaults();
			}
		}
		catch(Exception $e){
			$this->setPageDefaults();	
		}   	
    }
		
	/**
	* @desc
	* renders global page title, meta, tracking vars and more form defaults
	*
	* @input-required:
	* @param -> $request 	:Zend_Controller_Request_Abstract
	*	
	* @return this
	*
	* @access public
	*/
	private function setPageDefaults(){
		//get view
		$view = Zend_Controller_Action_HelperBroker::getExistingHelper('ViewRenderer')->view;
		//using the defaults	
		self::$_activePath = $this->_defaults;
		$view->activePage = $this->_defaults;
		$view->doctype($this->doctype);
		$view->headTitle($this->_defaults['title'], 'SET');
		$view->headMeta()->setHttpEquiv('expires', 'Wed, 26 Feb 1997 08:21:57 GMT')
						 ->setHttpEquiv('pragma', 'no-cache')
						 ->setHttpEquiv('Cache-Control', 'no-cache')
						 ->setName('keywords', $this->_defaults['keywords'])
						 ->setName('description',  $this->_defaults['desc']);
	}
		
	/**
    * @desc 
    * returns index if found or default (NULL)
    *
	* @input-required:
	* @param -> $name 	:string
	*
	* @input-optional:
	* @param -> $default :string (returned in case of null) 	
    * 
 	* @access public
    */		
	public function page($name, $default = NULL){
		//in case of error return default
		$result = $default;
		if(empty(self::$_activePath)){
			$node = $this->getActiveNode();
			if($node instanceof Zend_Navigation_Page_Mvc){
				self::$_activePath = $node->toArray();
			}
		}
		if((array_key_exists($name, self::$_activePath))){
			$result = self::$_activePath[$name];
		}
	return $result;
	}
	
	/**
    * @description   
    * overwrite specific page-params (active page)
	* use within controller
    *
    * @input-optional:
    * @param -> $name	:mixed
	* @param -> $value	:mixed
    *
    * @return :none
    *
    * @access public 
    */
	public static function setPageParam($name, $value, $overwriteActivePage = true){
		self::$_activePath[$name] = $value;
		//overwrite active (navigation-array-based) node
		if($overwriteActivePage === true){
			$view = Zend_Controller_Action_HelperBroker::getExistingHelper('ViewRenderer')->view;
			$view->activePage = self::$_activePath;	
		}
	return self::$_activePath;
	}
	
	/**
    * @description   
    * overwrite specific page-params (active page)
	* use within controller
    *
    * @input-optional:
    * @param -> $name	:mixed
	* @param -> $value	:mixed
    *
    * @return :none
    *
    * @access public 
    */
	public static function getPageParam($name){
		if(isset(self::$_activePath[$name])){
			return self::$_activePath[$name];
		}
	return '';
	}
	
	/**
    * @description   
    * delivers a random string for given len parameter
	* works as pageid for jQMobile
    *
    * @input-optional:
    * @param -> $len	:int   length of random string
    *
    * @return :string
    *
    * @access public 
    */
	public function getUid($len = 32){
		$string = md5(microtime().uniqid());
		while(strlen($string) < $len){
			 $string .= md5($string.microtime());
		}
	return substr($string, 0, $len);
	}
	
	/**
    * @desc 
    * allow chain-access
    * 
	* @input-required:
	* @param -> $name  :string (parameter name)
    * 
 	* @access public
    */	
 	public function __get($name){
		return $this->page($name);
    }	

}