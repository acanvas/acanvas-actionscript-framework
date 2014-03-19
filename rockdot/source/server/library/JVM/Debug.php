<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2009, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 * JVM_Debug uses outputbuffer to dump vars
 * 
 * @author 			joerg.diterlizzi
 * @version 		1.0			
 * @lastmodified:   	
 */
class JVM_Debug{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */
	/**
	 * container for debugging output
	 * @var array
	 * @access private static
	 */	
	private static $_outputBuffer = array();
	
	/**
	 * container for debugging output
	 * @var array
	 * @access private static
	 */	
	private static $_options = array(
		'enableDebug' 	=> true, //enable debugging (on/off)
		'enableBuffer' 	=> false, //enable write into buffer
		'enableEcho' 	=> true  //enable direct output
	);
	
	/**
	* @desc
	* sets options
	* 
	* @input-required:
	* @param -> $input	:mixed var for output		
	* 
	* @return none		
	*	
	* @access public from all scopes
	*/ 
	public static function setOptions(array $_options){
		foreach($_options as $name => $option){
			if(array_key_exists($name, self::$_options)){
				self::$_options[$name] = $option;
			}
		}
	}
/*	+-----------------------------------------------------------------------------------+
	| 	debugging functions
	+-----------------------------------------------------------------------------------+  */		
	/**
	* @desc
	* dumps mixed vars using internal response function
	* 
	* @input-required:
	* @param -> $input	:mixed var for output		
	* 
	* @input-optional:
	* @param -> $label	:string headline for output		
	*	
	* @access public from all scopes
	*/ 
	public static function dump($input, $label='', $doEcho = true, $doBuffer = true){
		self::response($input, self::getLabel($label, debug_backtrace()), $doEcho);	
	}
	
	/**
	* @desc
	* dumps mixed vars and exits the script using internal response function
	* 
	* @input-required:
	* @param -> $input	:mixed var for output		
	* 
	* @input-optional:
	* @param -> $label	:string headline for output		
	*	
	* @access public from all scopes
	*/ 
	public static function dumpX($input, $label='', $doEcho = true, $doBuffer = true){
		self::response($input, self::getLabel($label, debug_backtrace()), $doEcho);
		exit();	
	}
			
	/**
	* @desc
	* returns static output buffer
	* 
	* @input-optional:
	* @param -> $hidden	:boolean 		
	*
	* @return: array
	*
	* @access public from all scopes
	*/ 
	public static function getBufferString($hidden = false){
		if($hidden === true){
			return('<div style="display:none">'.implode('', self::$_outputBuffer).'</div>'.PHP_EOL);
		}
		else{
			return(implode('', self::$_outputBuffer));
		}
	}
	
	/**
	* @desc
	* returns static output buffer
	* 
	* @void	
	*
	* @return: array
	*	
	* @access public from all scopes
	*/ 
	public static function getBuffer(){
		return(self::$_outputBuffer);
	}
	
	/**
	* @desc
	* resets static output buffer
	* 
	* @void	
	*	
	* @access public from all scopes
	*/ 
	public static function resetBuffer(){
		self::$_outputBuffer = array();
	}		
	
	/**
	* @desc
	* formats and dumps mixed vars used by all dump functions	
	* 
	* @input-required:
	* @param -> $input	:mixed var for output		
	* 
	* @input-optional:
	* @param -> $label	:string headline for output		
	*	
	* @access private static
	*/
	private static function response($input, $label, $doEcho = true, $doBuffer = true){
		//if dump called from console
		if(php_sapi_name() == 'cli' && isset($_SERVER['SHELL'])){
			self::consoleDump($input, $label);	
		}
		elseif(self::$_options['enableDebug'] === true){	
			//start output buffering
			ob_start();
			var_dump($input);
			$output = ob_get_clean();
			
			//decode html
			$output = htmlspecialchars_decode($output);
			//replacing previous preformat-tag
			$output = preg_replace("(<pre>|<\/pre>)", '', $output);// /(.*)<pre>(.*)<\/pre>(.*)/
			//replace newlines and indents
			$output = preg_replace("/\]\=\>\n(\s+)/m", "] => ", $output);
			//prepare html
			$output = htmlspecialchars($output, ENT_QUOTES);#, 'UTF-8', false);
			//prepare the output			
			$output =  	'<pre>' .
						PHP_EOL .
						"| BO |  --------------------------------------- $label ---------------------------------------" .
						PHP_EOL .
						$output .
						"| EO |  --------------------------------------- $label ---------------------------------------" .
						PHP_EOL .
						PHP_EOL .
						'</pre>';
			//write into buffer
			if($doBuffer === true && self::$_options['enableBuffer']){
				self::$_outputBuffer[] = $output;
			}
			//echo output 
			if($doEcho === true && self::$_options['enableEcho']){
				echo $output;
			}
		}
	}
	
	/**
	* @desc
	* formats and dumps mixed vars used by all dump functions	
	* 
	* @input-required:
	* @param -> $input	:mixed var for output		
	* 
	* @input-optional:
	* @param -> $label	:string headline for output		
	*	
	* @access public from all scopes
	*/
	private static function consoleDump($input, $label = ''){
		if(self::$_options['enableDebug']){	
			//start output buffering
			ob_start();
			var_dump($input);
			$output = ob_get_clean();
			if(self::$_options['enableEcho']){			
				echo (
					PHP_EOL . '| BO | ------------------------------------------------- | BO |' . PHP_EOL .
					//self::getLabel('', debug_backtrace()).':' . PHP_EOL .
					(($label != '') ? self::getLabel($label, false).':' . PHP_EOL  : '' ).
					$output . 
					'| EO | ------------------------------------------------- | EO |'. PHP_EOL . PHP_EOL
				);
			}
		}
	}
			
	/**
	* @desc
	* if label empty function creates it and returns labelstring
	* 
	* @input-required:
	* @param -> $label	:string	
	* @param -> $_trace	:array	
	*	
	* @access private
	*/ 
	private static function getLabel($label, $_trace = false){
		if(!is_scalar($label)){
			$label = gettype($label);	
		}
		if($label == '' && is_array($_trace)){
			$_trace = array_shift($_trace);
			$label = (isset($_trace['file']) && isset($_trace['line']) ?  'file: '.$_trace['file'].' | line: '.$_trace['line'].' | function: '.$_trace['function'].'()' : 'Ausgabe');
		}
	return $label = filter_var(trim($label), FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_LOW);
	}
	
	/**
    * @desc 
	* __ magic method __
    * send buffer to browser
    * 
	* @void
    * 
 	* @access public
    */		
	public function __toString(){
		return(self::getBufferString());
	}		
		
}