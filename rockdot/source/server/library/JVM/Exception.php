<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2010, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * JVM_Exception abstract
 * 
 * @author 			joerg.diterlizzi
 * @version 	
 * @revision:		
 * @lastmodified:	
 * @import: 
 */
abstract class JVM_Exception extends Exception{
/*  +-----------------------------------------------------------------------------------+
	| 	class member-vars
	+-----------------------------------------------------------------------------------+  */
   	/**
	* User-defined exception message
	* @var  string
	*/
    protected $message = 'Unknown exception';
   	
	/**
	* User-defined exception code
	* @var  int
	*/	
    protected $code    = '';
    
	/**
	* Source filepath/name of exception
	* @var  string
	*/
    protected $file;

	/**
	* Source line of exception
	* @var  string
	*/	
    protected $line;
	
	/**
	* TraceContainer of exception
	* @var  string
	*/		
    protected $trace;

	/**
	* ClassName of thrown exception
	* @var  string
	*/		
	protected $exceptionClass;
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @description
	* class constructor	set init-parameters
	*
	* @input-optional:
	* @param -> $message		:string  User-defined exception message	
	* @param -> $code			:code  User-defined exception code
	* @param -> $_additional	:array or string  additional thrown infos										
	*
	* @access public
	*/ 
    public function __construct($message = '', $code = 0, $prevoius = NULL){
        $this->exceptionClass = get_class($this);
		//throws default exception if no message submitted
		if($message == ''){
           //throw new $this(, $code, $prevoius);
		   $message = 'Unknown Exception in class: '.$this->exceptionClass;
        }
		//call SPL Exception (parent) constructor
		if(phpversion() >= '5.3.0'){
			parent::__construct($message, $code, $prevoius);
		}
		else{
			parent::__construct($message, $code);	
		}
    }
/*	+-----------------------------------------------------------------------------------+
	| 	additional functions
	+-----------------------------------------------------------------------------------+  */	
	/**
	* @description
	* delivers thrown exception formated as plain text string
	*
	* @void	
	*
	* @return :string 	
	*	
	* @access public
	*/	
	public function getInfo(){
		$info  = 'Exception >> '.$this->exceptionClass. ' >> '.$this->code.PHP_EOL;
		$info .= 'Message: '.$this->message.PHP_EOL;
 		$info .= 'Line: '.$this->line.PHP_EOL;
		$info .= 'File: '.$this->file.PHP_EOL;
		if(isset($_SERVER['REQUEST_URI'])){
			$info .= 'Url: '.$_SERVER['REQUEST_URI'].PHP_EOL;
		}
		$info .= $this->traceStack().PHP_EOL;
	return ($info);
	}
	
	/**
	* @description
	* delivers thrown exception formated as html text string
	*
	* @void	
	*
	* @return :string 	
	*	
	* @access public
	*/	
	public function getInfoHtml(){
		$info  = '<p style="margin:5px; border:1px solid #9818db; font-size: 14px; padding:5px; color:#000; background:#FFF">';
		$info .= '<span style="color:#9818db; font-weight:bold; font-size: 16px;">Exception >> '.$this->exceptionClass. ' >> '.$this->code.'</span><br />';
		$info .= '<strong>Message:</strong> '.$this->getMessage().'<br />';
		$info .= '<strong>Line:</strong> '.$this->getLine().'<br />';
		$info .= '<strong>File:</strong> '.$this->getFile().'<br />';
		$info .= '<strong>Url:</strong> '.$_SERVER['REQUEST_URI'].'<br />';
		if(count($this->getTrace()) >= 1){
			$info .= '<br/><strong>Trace: </strong><br/>';
			foreach($this->getTrace() as $num => $_trace){
				$info .= "&nbsp;&nbsp;&nbsp;&nbsp;<strong>Function</strong>: ".$_trace['function']."(".(isset($_trace['args']) ? self::traceArgs($_trace['args']) : '' ).')<br />';
				if(isset($_trace['file']) && isset($_trace['line'])){
					$info .= "&nbsp;&nbsp;&nbsp;&nbsp;<strong>File</strong>: ".$_trace['file']." <strong>(".$_trace['line'].")</strong><br />";
				}
				$info .= "&nbsp;&nbsp;&nbsp;&nbsp;<strong>Arguments</strong>:<br />".self::traceArgs($_trace['args'], '<br />', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;')."<br />";
			}
		}		
		$info .= '</p><br style="clear:both;" />';
	return($info);
	}
	
	/**
	* @description
	* returns stack-trace as string
	*
	* @void
	*
	* @return :string 
	*
	* @access private
	*/
	private function traceStack(){
		//get trace from spl
		$stack = '';
		if(count($this->getTrace()) >= 1){
			$stack = 'Trace:'.PHP_EOL;
			foreach($this->getTrace() as $type => $_trace){
				$stack .= "->Function: ".$_trace['function']."(".(isset($_trace['args']) ? self::traceArgs($_trace['args']) : '').")".PHP_EOL;
				if(isset($_trace['file']) && isset($_trace['line'])){
					$stack .= "->File: ".$_trace['file']." (".$_trace['line'].")".PHP_EOL;
				}
				if(isset($_trace['args'])){
					$stack .= "->Arguments: ".self::traceArgs($_trace['args']).PHP_EOL;
				}
			}
		}
	return ($stack);
	}
	
	/**
	* @description
	* returns args as string
	*
	* @void
	*
	* @return :string 
	*
	* @access private static
	*/
	private static function traceArgs($_args, $eol = '', $prepend = ''){
		//get trace from spl
		$args = '';
		if(count($_args) >= 1){
			foreach($_args as $idx => $arg){
				$add = ', '.$eol;
				if((count($_args)-1) === $idx){
					$add = ''.$eol;
				}
				if(is_object($arg)){
					$args .= $prepend.'"object('.get_class($arg).')"'.$add;	
				}
				elseif(is_resource($arg)){
					$args .= $prepend.'"resource('.get_resource_type($arg).')"'.$add;	
				}
				elseif(is_array($arg)){
					$args .= $prepend.'array('.( empty($arg) ? 'empty' : count($arg) ).')'.$add;	
				}				
				elseif(is_bool($arg)){
					$arg = (($arg === true) ? 'true' : 'false');
					$args .= $prepend.$arg.$add;	
				}
				elseif(is_int($arg) || is_float($arg) || is_double($arg)){
					$args .= $prepend.$arg.$add;	
				}												
				else{
					$args .= $prepend.'"'.(string) substr($arg, 0, 200).'"'.$add;
				}
			}
		}
	return ($args);
	}
/*	+-----------------------------------------------------------------------------------+
	| 	Exception helper
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* delivers passed exception formated as html text string 
	* useful in debug mode only 
	*
	* @input-required:
	* @param -> $e	:Exception
	*
	* @return :string 	
	*	
	* @access public from all scopes
	*/	
	public static function getExceptionInfoHtml(Exception $e){
		$info  = '<p style="margin:5px; border:1px solid #9818db; font-size: 14px; padding:5px; color:#000; background:#FFF">';
		$info .= '<span style="color:#9818db; font-weight:bold; font-size: 16px;">Exception >> '.get_class($e). ' >> '.$e->getCode().'</span><br />';
		$info .= '<strong>Message:</strong> '.$e->getMessage().'<br />';
		$info .= '<strong>Line:</strong> '.$e->getLine().'<br />';
		$info .= '<strong>File:</strong> '.$e->getFile().'<br />';
		if(count($e->getTrace()) >= 1){
			$info .= '<br/><strong>Trace: </strong><br/>';
			foreach($e->getTrace() as $num => $_trace){
				$info .= "&nbsp;&nbsp;&nbsp;&nbsp;<strong>Function</strong>: ".$_trace['function']."(".(isset($_trace['args']) ? self::traceArgs($_trace['args']) : '' ).')<br />';
				$info .= "&nbsp;&nbsp;&nbsp;&nbsp;<strong>File</strong>: ".$_trace['file']." <strong>(".$_trace['line'].")</strong><br />";
			}
		}		
		$info .= '</p><br style="clear:both;" />';
	return($info);
	}

	/**
	* @desc
	* delivers passed exception formated as plain text string
	* useful in debug mode only 
	*
	* @input-required:
	* @param -> $e	:Exception
	*
	* @return :string 	
	*	
	* @access public from all scopes
	*/	
	public static function getExceptionInfo(Exception $e){
		$info = '';
		$info .= 'Exception >> '.get_class($e). ' >> '.$e->getCode().PHP_EOL;
		$info .= 'Message: '.$e->getMessage().PHP_EOL;
		$info .= 'Line: '.$e->getLine().PHP_EOL;
		$info .= 'File: '.$e->getFile().PHP_EOL;
		if(count($e->getTrace()) >= 1){
			$info .= 'Trace:'.PHP_EOL;
			foreach($e->getTrace() as $num => $_trace){
				$info .= "->Function: ".$_trace['function']."(".(isset($_trace['args']) ? self::traceArgs($_trace['args']) : '' ).')'.PHP_EOL;
				$info .= "->File: ".$_trace['file']." (".$_trace['line'].")".PHP_EOL;
			}
		}		
	return($info);
	}	
	
	/**
	* @desc
	* sets custom exception handler for uncaught exceptions
	* i.e function($e){echo "Uncaught exception: ".$e->getMessage(); }
	*
	* @input-required:
	* @param -> $callback
	*
	* @return :none 	
	*	
	* @access public from all scopes
	*/
	public static function setHandler($callback){
		set_exception_handler( $callback );
	}
	
	/**
	* @desc
	* restores the exception handler
	*
	* @void
	*
	* @return :none 	
	*	
	* @access public static
	*/
	public static function restoreHandler(){
		restore_exception_handler();
	}
	
	/**
	* @desc
	* restores the exception handler
	*
	* @void
	*
	* @return :none 	
	*	
	* @access public static
	*/
	public static function restoreErrorHandler(){
		restore_error_handler();	
	}
	
	/**
	* @desc
	* sets custom error handler for warnings (php internal functions)
	*
	* @input-required:
	* @param -> $callback
	*
	* @return :none 	
	*	
	* @access public from all scopes
	*/
	public static function setErrorHandler($callback = array('JVM_Exception', 'phpWarningsToException')){
		set_error_handler($callback);
	}
	
	/**
	* @desc
	* sets custom exception handler for uncaught exceptions
	* i.e function($e){echo "Uncaught exception: ".$e->getMessage(); }
	*
	* @input-required:
	* @param -> $callback
	* @param -> $error
	* @param -> $file
	* @param -> $line
	*
	* @return :none 	
	*	
	* @access public from all scopes
	*/	
	public static function phpWarningsToException($code, $error, $file, $line){
		throw new ErrorException($error, $code, 0, $file, $line);
	}

	/**
	* @description
	* implements magic method __toString()
	* in case of direct output of exception $e
	*
	* @void
	*
	* @return :string 
	*
	* @access public
	*/
	public function __toString(){
		return($this->getInfo());
    }
		
}