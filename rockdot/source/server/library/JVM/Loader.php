<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2010, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * JVM_Loader loads classes or files from includepath / registers autoloader 
 *
 * @pattern/scope   singleton 
 * @author          joerg.diterlizzi
 * @version         
 * @lastmodified:   
 * @copyright       Copyright (c) Jung von Matt / Neckar
 * @package         JVM_Loader
 *
 * @dependencies
 * @import: JVM_Loader_Exception	
 */
require_once('JVM/Loader/Exception.php');
 
class JVM_Loader{	
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */  	
	/**
	* this object instance
	* @var  self::object
	*/
	private static $selfInstance;
	
	/**
    * @var    :string static
    * @access :self
    */		
	private static $includePath = NULL;
	
	/**
    * @var    :string
    * @access :private static
    */		
	private static $throwExceptions = false;			
	
	/**
	* @desc   :defines the load-machanism-flags
    * @var    :constant string
    * @access :self
    */
	const JVM_LOADER_REQUIRE 		= 'require';
	const JVM_LOADER_REQUIRE_ONCE 	= 'require_once';
	const JVM_LOADER_INCLUDE 		= 'include';
	const JVM_LOADER_INCLUDE_ONCE 	= 'include_once';
/*	+-----------------------------------------------------------------------------------+
	| 	contruct and init functionallity
	+-----------------------------------------------------------------------------------+  */
   /**
    * @desc 
    * include a file
    * 
    * @input-optional:
	* @param -> $throwExceptions	:boolean
    * 
 	* @access protected
    */
	protected function __construct($throwExceptions){
		$this->setThrowExceptions($throwExceptions);
	}
	
	/**
	* @desc
	* disallow cloning of obj
	* @access private	
	*/
	private function __clone(){} 
	
	/**
	* @desc
	* singleton method delivers single instance
	* 
    * @input-optional:
	* @param -> $throwExceptions	:boolean	
	*
	* @return :instance self this
	*
	* @access public
	*/  	
	public static function getInstance($throwExceptions = false){
		if(self::$selfInstance == null){
			self::$selfInstance = new self($throwExceptions);
		}
	return (self::$selfInstance);
	}
	
	/**
    * @desc 
    * set to old include path a file
    * 
    * @params void()
    * 
 	* @access public
    */
	public function __destruct(){
		if(self::$includePath !== NULL){
			self::setPath(self::$includePath);
		}
	}
	
	/**
    * @desc 
    * sets flag if autoloader throws exceptions in case of FNF
    * 
    * @input-required:
	* @param -> $throwExceptions	:boolean
    * 
 	* @access public static
    */
	public static function setThrowExceptions($throwExceptions){
		if(!is_bool($throwExceptions)){
			throw new JVM_Loader_Exception('throwExceptions parameter must be type of boolean', 1001);		
		}
		self::$throwExceptions = $throwExceptions;
	}
			
	/**
	* @desc
	* load a file by classname or given path (notice path requires extension) 
	* sets given include path but writes back the former known	
	* 
	* @input-required:
	* @param -> $fileOrClassName	:string or filename
	* 
	* @input-optional:
	* @param -> $typeFlag			:string mode include once... (default: include)
	* @param -> $includePath		:string the include path you want to use
	* 	
	* @return : boolean
	*
	* @access public static
	*/		
	public static function load($fileOrClassName, $includePath = NULL, $typeFlag = self::JVM_LOADER_INCLUDE_ONCE){
		//overwrite current include path and store current include_paths in static var
		if($includePath !== NULL){
			self::getPath();
			self::setPath(
				$includePath
			);
		}
		if(!is_array($fileOrClassName)){
			$fileOrClassName = array($fileOrClassName);
		}
		foreach($fileOrClassName as $file){
			//class already loaded loader has nothing to do
			if (class_exists($file, false) || interface_exists($file, false)){
				break;
			}
			//build filename an test existance
			if(!preg_match('/[\/|(\.(?:php))][1-5]{0,1}$/', $file)){
				$file = str_replace('_', DIRECTORY_SEPARATOR, $file) . '.php';
			}
			//test path existance and imply the file (fullpath | includepath)
			if( (self::isFile($file) && $includePath === NULL) || (self::isInIncludePath($file)) ){
				self::import($file, $typeFlag); //include / require / once
			}
			elseif(self::$throwExceptions === true){
				throw new JVM_Loader_Exception('file: ('.$file.') not found! check includepaths: '.get_include_path(), 1002);	
			}
		}
		//reset the previous include_paths
		if(self::$includePath  !== NULL){
			self::setPath(
				self::$includePath
			);
		}
	return true;
	}
	
	/**
	* @desc
	* load a file / depenings on passed flag 
	* default: include
	* 
	* @input-required:
	* @param -> $file				:string path
	* 
	* @input-optional:
	* @param -> $typeFlag			:string mode include once or more
	* 	
	* @return : none
	*
	* @access public static
	*/		
	public static function import($file, $typeFlag = self::JVM_LOADER_INCLUDE){
		if(!self::isFile($file) && !self::isInIncludePath($file) ){
			throw new JVM_Loader_Exception('the file('.$file.') you try to load does not exist', 1003); 		
		}
		switch(strtolower($typeFlag)){
			case (self::JVM_LOADER_INCLUDE):
				return(include($file));
			break;	
			case (self::JVM_LOADER_INCLUDE_ONCE):
				return(include_once($file));
			break;	
			case (self::JVM_LOADER_REQUIRE):
				return(require($file));
			break;	
			case (self::JVM_LOADER_REQUIRE_ONCE):
				return(require_once($file));
			break;	
			default:
				throw new JVM_Loader_Exception("import type not supported", 1004);	
			break;
		}
	}
	
	/**
	* @desc
	* registers autoload fuctionality with all passed includepaths sets internal
	* autoloader function (autoInclude) on top of stack
	* combined with JVM_Loader::auto_include
	* 
	* @input-required:
	* @param -> $_includePaths	:array/string
	* 
	* @input-optional:
	* @param -> $extensions		:string
	* 	
	* @return : boolean
	*
	* @access public static
	*/		
	public static function autoload($_includePaths = NULL, $doPrepend = false, $extensions = '.php'){
		//handle include path
		if($_includePaths !== NULL){
			self::addPath($_includePaths);
		}
		//register autoload with passed include paths
		spl_autoload_extensions($extensions);
		spl_autoload_register(array(__CLASS__, 'autoloader'), true, $doPrepend);
	return(self::getInstance());
	}
	
	/**
	* @desc
	* registers extensions to autoloder
	* 
	* @input-required:
	* @param -> $extensions	:string
	* 	
	* @return : none
	*
	* @access public static
	*/		
	public static function registerExtensions($extensions){
		spl_autoload_extensions($extensions);
	return(self::getInstance());
	}
	
	/**
	* @desc
	* registers a autoloader function or class
	* 
	* @input-required:
	* @param -> $callback	:mixed (array(class, function) | string function)
	* 
	* @input-optional:
	* @param -> $doPrepend	:boolean
	* 	
	* @return : none
	*
	* @access public static
	*/		
	public static function register($callback, $doPrepend = false){
		if(!is_callable($callback)){
			throw new JVM_Loader_Exception('invalid autoloader callback! not callable', 1001);	
		}
		spl_autoload_register($callback, true, $doPrepend);
	return(self::getInstance());
	}
	
	/**
	* @desc
	* unregisters a autoloader function or class
	* 
	* @input-required:
	* @param -> $callback	:mixed (array(class, function) | string function)
	* 	
	* @return : none
	*
	* @access public static
	*/	
	public static function unregister($callback){
		spl_autoload_unregister($callback);
	return(self::getInstance());
	}
	
	/**
	* @desc
	* retuns the autoloader stack /all registered autoloaders
	* 
	* @void
	* 	
	* @return : array
	*
	* @access public static
	*/
	public static function getStack(){
		return(spl_autoload_functions());
	}	
	
	/**
	* @desc
	* registered autoload fuction
	* 
	* @input-required:
	* @param -> $class	:string (path filename)
	* 	
	* @return : spl_autoload
	*
	* @access private static
	*/	
	private static function autoloader($class){ 
		//build path
		$filePath = trim( str_replace('_', DIRECTORY_SEPARATOR, $class) );
		//class or interface already loaded ?
		if(
			class_exists($class, false) || 
			interface_exists($class, false) || 
			in_array($class, get_declared_classes())
		){
			return(true);
    	}
		//check existance
		if(!self::isInIncludePath($filePath.'.php') && self::$throwExceptions === true){
			throw new JVM_Loader_Exception('autoload failed! could not load file! check classname: '.((string) $class).' and includepath(s): '.get_include_path(), 1001);
		}
		//include the file
		#spl_autoload( include_once( $filePath.'.php' ) );//extension
		#spl_autoload($filePath); //no extension function will LOWERCASE the class names
	return(@include($filePath.'.php'));  //extension
	} 

	/**
	* @desc
	* writes current used path in a static var 
	* 
	* @void
	* 	
	* @return : string
	*
	* @access public static
	*/		
	public static function getPath(){
		self::$includePath = get_include_path();
	return(self::$includePath);
	}
	
	/**
	* @desc
	* get declared classes
	* 
	* @input-optional:
	* @param -> $prefix	:string
	* 	
	* @return : array
	*
	* @access private static
	*/	
	public static function getDeclaredClasses($prefix = NULL){
		if($prefix === NULL){
			return(get_declared_classes());	
		}
		$_declared = array();
		foreach(get_declared_classes() as $class){
			if(strstr($class, $prefix)){
				$_declared[] = $class;
			}
		}
	return($_declared);
	} 
	
	/**
	* @desc
	* Gets the names of all files that have been included  PHP 5:
	* using include(), include_once(), require() or require_once(). 
	* 
	* @void
	* 	
	* @return : array
	*
	* @access private static
	*/	
	public static function getIncludes(){
	return(get_included_files());
	}
	
	/**
	* @desc
	* ststrs the passed path to all included file
	* 
	* @input-optional:
	* @param -> $prefix	:string
	* 	
	* @return : array
	*
	* @access private static
	*/	
	public static function isIncluded($searchedFile){
		$_included = get_included_files();
		if(!empty($_included)){
			foreach($_included as $include){
				if(strstr($include, $searchedFile)){
					return(true);		
				}
			}
		}
	return(false);
	}
	
	/**
	* @desc
	* add passed includepaths
	* 
	* @input-required:
	* @param -> $_includePaths	:string|array
	* 	
	* @return : boolean
	*
	* @access private static
	*/	
	public static function addPath($_includePaths){
		//handle include path
		if(empty($_includePaths)){
			throw new JVM_Loader_Exception("no paths have been submitted.", 1000);
		}
		//if includepath is a string -> wrap it in as array
		if(!is_array($_includePaths) && is_string($_includePaths)){
			$_includePaths = array($_includePaths);
		}
		$_currentIncludePaths = explode(PATH_SEPARATOR, get_include_path());
		foreach($_includePaths as $path){
			if(!in_array($path, $_currentIncludePaths)){
				$_currentIncludePaths[] = $path;	
			}	
		}
		if(!empty($_includePaths)){
			set_include_path(
				implode(PATH_SEPARATOR, $_currentIncludePaths)
			);
		}
	return(self::getInstance());
	}
	
	/**
	* @desc
	* add passed includepaths
	* 
	* @input-required:
	* @param -> $_includePaths	:string|array
	* 	
	* @return : bollean
	*
	* @access private static
	*/	
	public static function removePath($_includePaths){
		//handle include path
		if(empty($_includePaths)){
			throw new JVM_Loader_Exception('no paths have been submitted.', 1000);
		}
		if(!is_array($_includePaths) && is_string($_includePaths)){
			$_includePaths = array($_includePaths);
		}
		//str match the path that was passed an try to remove it from current include path
		$_currentIncludePaths = explode(PATH_SEPARATOR, get_include_path());
		if(count($_currentIncludePaths) == 1){
			throw new JVM_Loader_Exception('cannot remove the only includepath', 1000);	
		}
		foreach($_currentIncludePaths as $idx => $path){
			if(in_array($path, $_includePaths)){
				unset($_currentIncludePaths[$idx]);	
			}		
		}
		set_include_path(
			implode(PATH_SEPARATOR, $_currentIncludePaths)
		);
	return(self::getInstance());
	}
	
	/**
	* @desc
	* sets passed include path(s)
	* NOTICE: Overwrites existing includepath
	* 
	* @input-required:
	* @param -> $_includePaths	:string|array
	* 	
	* @return : bollean
	*
	* @access private static
	*/	
	public static function setPath($_includePaths){
		//handle include path
		if(empty($_includePaths)){
			throw new JVM_Loader_Exception("no paths have been submitted.", 1000);
		}
		//if includepath is a string -> wrap it in as array
		if(!is_array($_includePaths) && is_string($_includePaths)){
			$_includePaths = array($_includePaths);
		}
		//set path(s) and overwrite existing paths
		set_include_path(
			implode(PATH_SEPARATOR, $_includePaths)
		);
	return(self::getInstance());
	}
	
	/**
	* @desc
	* delivers File - Extension from string 
	* (does not have to be an existsing file)
	*
	* @input-required:	
	* @param -> $fileName	:string	 ($filename/path)
	*	
	* @return :string 
	*
	* @access public static
	*/
	public static function getExtension($fileName){
		return pathinfo($fileName, PATHINFO_EXTENSION);	
	}
	
	/**
	* @desc
	* check if passed file exists in current include_path(s)
	* 
	* @input-required:
	* @param -> $filePath	:string
	* 	
	* @return : boolean
	*
	* @access public static
	*/	
	public static function isInIncludePath($filePath){
		$_paths = preg_split('/'.PATH_SEPARATOR.'/', get_include_path(), -1, PREG_SPLIT_NO_EMPTY);
		foreach($_paths as $path){
			if(is_file($path.$filePath)){
				return true;
			}
		}
	return false;
	}
	
	/**
	* @desc
	* checks if given path is a file 
	*
	* @input-required:
	* @param -> $path	string		filepath
	*	
	* @return :boolean
	*
	* @access public static
	*/
 	public static function isFile($path){
		if(!is_string($path)){
			throw new JVM_Loader_Exception("argument 1 (filepath) must be type of string", 1001);
		}
		if(is_file($path)){
			return true;
		}
	return false;
	}	
		
}