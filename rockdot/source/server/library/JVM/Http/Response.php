<?php
/*	
+-----------------------------------------------------------------------------------+
| Copyright (c) 2010, Joerg Di Terlizzi												|
| All rights reserved.																|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>								|
+-----------------------------------------------------------------------------------+ 
*/
/**
 * @desc JVM_Http_Response sends response according to request
 * @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
 * 
 * @author joerg.diterlizzi
 * @version 
 * @lastmodified:
 *
 * @dependencies:	 
 * @import: JVM_Http_Exception
 * @import: JVM_Http_Uri
 * @import: JVM_Http_Request
 */
require_once('JVM/Http/Exception.php');

class JVM_Http_Response{
/*  +-----------------------------------------------------------------------------------+
	| 	class member-vars
	+-----------------------------------------------------------------------------------+  */		
	/**
	* headers
	* @var :array
	*/
	protected $_header = array();
	
	/**
	* response body
	* @var :string
	*/
	protected $body	= '';	
	
	/**
	* status string built with statusCode and statusMsg
	* @var :string
	*/
	protected $status = NULL;	

	/**
	* code state of response
	* @var :int
	*/
	protected $statusCode = NULL;	

	/**
	* flag state of response
	* @var :int
	*/
	protected $statusFlag = NULL;		
	
	/**
	* text state of response
	* @var :string
	*/
	protected $statusMsg = NULL;	
	
    /**
     * @desc
	 * list of all known HTTP response codes to
     * translate numeric codes to messages.
	 *
	 * @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
	 * 
     * @var :array
     */
    protected static $_responseStatus = array(
        //Informational 1**
        100 => 'Continue',
        101 => 'Switching Protocols',
        //Success 2**
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        203 => 'Non-Authoritative Information',
        204 => 'No Content',
        205 => 'Reset Content',
        206 => 'Partial Content',
        //Redirection 3**
        300 => 'Multiple Choices',
        301 => 'Moved Permanently',
        302 => 'Found',  // 1.1
        303 => 'See Other',
        304 => 'Not Modified',
        305 => 'Use Proxy',
        //306 deprecated but reserved
        307 => 'Temporary Redirect',
        //Client Error 4**
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Request Entity Too Large',
        414 => 'Request-URI Too Long',
        415 => 'Unsupported Media Type',
        416 => 'Requested Range Not Satisfiable',
        417 => 'Expectation Failed',
        //Server Error 5**
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        505 => 'HTTP Version Not Supported',
        509 => 'Bandwidth Limit Exceeded'
    );	
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor/destructo - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @description
	* disallow multiple instances
	* no new instance with new or clone 	
	*	
	* @input-optional:
	* @param -> $status		:string/int 
	* @param -> $_header	:array
	* @param -> $content	:string  
	*
	* @access public
	*/
	public function __construct($status = 200, $_header = array(), $content = ''){
		$this->setStatus($status);
		$this->setHeader($_header);
		$this->setContent($content);
	}
/*	+-----------------------------------------------------------------------------------+
	| 	Response
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @description
	* returns current status message  
	*
	* @void
	*
	* @access public
	*/
	public function getStatusMsg(){
	return $this->statusMsg;
	}
	
	/**
	* @description
	* returns array of valid status codes
	*
	* @void
	*
	* @access public
	*/
	public function getStatusMsgArray(){
	return self::$_responseStatus;
	}
	
	/**
	* @description
	* returns current status string
	*
	* @void
	*
	* @access public
	*/
	public function getStatus(){
	return $this->status;
	}
	
	/**
	* @description
	* returns current status flag (first char of status code)
	*
	* @void
	*
	* @access public
	*/
	public function getStatusFlag(){
	return $this->statusFlag;
	}
	
	/**
	* @description
	* returns current status code
	*
	* @void
	*
	* @access public
	*/
	public function getStatusCode(){
	return $this->statusCode;
	}	

	/**
	* @description
	* sets status of response header
	*
	* @input-required:
	* @param -> $status		:string (Status example 200 404) see _response_msgs array for details
	*
	* @access public
	*/
	public function setStatus($statusCode){
		if((!is_int($statusCode) && !is_string($statusCode)) || !isset(self::$_responseStatus[$statusCode])){
			throw new JVM_Http_Exception("could not set status - invalid or unsupported status code submitted", 1001);	
		}
		//setup the status header
		$this->statusCode 	= (int) $statusCode;
		$this->statusMsg 	= (string) self::$_responseStatus[$statusCode];
		$this->status 		= (string) $this->statusCode.' '.$this->statusMsg;
		$this->statusFlag	= (int) substr((string) $this->statusCode, 0, 1);
	return $this;
	}

	/**
	* @description
	* adds a header to the current set of headers
	*
	* @input-required:
	* @param -> $name		:string header desriptor
	* @param -> $value		:string value of descriptor	
	*
	* @input-optional:
	* @param -> $replace	:boolean overwrite (default: false)
	*
	* @access public
	*/
	public function addHeader($name, $value, $replace = false){
		$index = (count($this->_header) +1);
		$this->_header[$index]['name']    = (string) trim(str_replace(':', '', $name));
		$this->_header[$index]['value']   = (string) $value;
		$this->_header[$index]['replace'] = (is_bool($replace) ? $replace : false);
	return $this;
	}
	
	/**
	* @description
	* sets a set of headers
	*
	* @input-required:
	* @param -> $_header	:array ('name' => array(value, replace) 
	*
	* @input-optional:
	* @param -> $reset	:boolean reset
	*
	* @access public
	*/
	public function setHeader($_header, $reset = true){
		//reset headers
		if($reset === true){
			$this->_header = array();
		}
		foreach($_header as $headerName => $headerValue){
			$replace = false;
			if(is_string($headerValue)){
				$value = $headerValue;
			}
			elseif(is_array($headerValue)){
				if(isset($headerValue[0])){
					$value = $headerValue[0];
				}
				if(isset($headerValue[1])){
					$replace = $headerValue[1];
				}
			}
			$this->addHeader($headerName, $value, $replace);
		}
	return $this;
	}	
		
	/**
	* @description
	* get (internal) response header (if set)
	*
	* @input-optional:
	* @param -> $name	:string 
	* 
	* @return array	
	*
	* @access public
	*/
	public function getHeader($name = NULL){
		if(is_string($name)  && $name !== NULL){
			$_header = NULL;
			foreach($this->_header as $idx => $header){
				if(	$header['name'] === $name){
					$_header[] = $header; 
				}
			}
			return $_header;
		}
	return $this->_header;
	}
	
	/**
	* @description
	* clears headers
	*
	* @void
	*
	* @access public
	*/
	public function resetHeader(){
		$this->_header = array();
	return $this;
	}	

	/**
	* @description
	* adds data to body/content
	*
	* @input-required:
	* @param -> $data :string
	*
	* @access public
	*/
	public function addContent($data){
		if(!is_string($data)){
			throw new JVM_Http_Exception('body/content must be type of string', 1001);	
		}
		$this->body .= $data;
	return $this;
	}

	/**
	* @description
	* sets the body/content
	*
	* @input-required:
	* @param -> $data :string
	*
	* @access public
	*/
	public function setContent($data){
		if(!is_string($data)){
			throw new JVM_Http_Exception('body/content must be type of string', 1001);	
		}
		$this->body = $data;
	return $this;
	}	
	
	/**
	* @description
	* returns the body/content
	*
	* @void
	*
	* @access public
	*/
	public function getContent(){
	return $this->body;
	}

	/**
	* @description
	* clears body
	*
	* @void
	*
	* @access public
	*/
	public function resetContent(){
		$this->body = '';
	return $this;
	}	

	/**
	* @description
	* tries to redirect into the given location 
	*
	* @input-required:
	* @param -> $url			:string  //redirect directory or website
	*
	* @input-optional:
	* @param -> $statusCode		:int code 
	*
	* @access public
	*/
	public static function redirect($url, $statusCode = 301){
		require_once('JVM/Http/Uri.php');
		if(!JVM_Http_Uri::isValid($url)){
			throw new JVM_Http_Exception("submitted uri($url) is invalid ", 1002);
		}
		if(headers_sent()){
			if(@ob_get_length()){
				@ob_end_clean();
			}
		}
		if(isset(self::$_responseStatus[$statusCode])){
			header("HTTP/1.0 ".$statusCode.' '.self::$_responseStatus[$statusCode]);	
		}
		header('Location: '.$url);
		exit();
	}	
	
	/**
	* @description
	* tries to redirect into the given location 
	*
	* @input-required:
	* @param -> $url			:string  //redirect directory or website
	*
	* @input-optional:
	* @param -> $statusCode		:int code 
	*
	* @access public
	*/
	public static function forwardSsl(){
		include_once('JVM/Http/Request.php');
		if(headers_sent()){
			if(@ob_get_length()){
				@ob_end_clean();
			}
		}
		header('HTTP/1.0 301 Moved Permanently');	
		header('Location: '.JVM_Http_Request::getUrl(true));
		exit();
	}
	
	/**
	* @description
	* sets status of response header
	*
	* @void
	*
	* @access public
	*/
	public function flush($doExit = false){
		if(headers_sent()){
			if(@ob_get_length()){
				@ob_end_clean();
			}
		}
		header("HTTP/1.0 ".$this->status);
		foreach($this->_header as $header){
			header($header['name'].': '.$header['value'], $header['replace']);
		}
		echo $this->body;
		//reset 
		$this->setStatus(200);
		$this->resetContent();
		$this->resetHeader();
		//exit if true
		if($doExit === true){
			exit();
		}
	}	
	
	/**
    * @desc 
	* __ magic method __
    * flushs the response
    * 
	* @void
    * 
 	* @access public
    */	
	public function __toString(){
		$this->flush();
	return '';
	}	

}