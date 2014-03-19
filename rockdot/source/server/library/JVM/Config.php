<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2011, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc extends JVM_Data for object an array-access
 * loads php / array-based config files or uses array 
 * @convention an array-based configuration-file must return itself by convention
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 * @package________JVM_Config
 *
 * @dependencies
 * @import: JVM_Config_Exception	
 * @import: JVM_Loader	
 * @import: JVM_Data
 * @import: JVM_Filter_ObjectToArray		 
 */
require_once('JVM/Config/Exception.php');
require_once('JVM/Loader.php');
require_once('JVM/Data.php');
require_once('JVM/Filter/ObjectToArray.php');
 
class JVM_Config extends JVM_Data{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */		
    /**
    * @desc   predefined doc-block varables 
    * @var    :array
    * @access :private
    */
	private $_docBlock = array(
		'desc'		=> 'generated array-based configuration-files must return itself by convention',
		'generator' => 'JVM_Config',
		'version'   => '1.0',
		'creation'	=> '',
		'file'		=> '',
		'line'		=> '',
		'author'	=> 'script',
		'copyright' => 'Copyright (c) Jung von Matt / Neckar'
	);
   
   /**
    * @var    :string filepath
    * @access :private
    */
	private $filePath = NULL;
	
	 /**
    * @var    :string extension / type
    * @access :private
    */
	private $fileType = NULL;
	
	/**
    * @var    :string section
    * @access :private
    */
	private $section = NULL;
	
	/**
	* allowChanges
	* @var  :boolean
	*/	
	protected $allowChanges = false;	
	
	/**
	* datacontainer
	* @var  :array
	*/
	protected $_data = array();	
/*	+-----------------------------------------------------------------------------------+
	| 	class constructor - set init-parameters
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* load config/text into array (including file must return its value)
	*	
	* @input-optional:
	* @param -> $file 	:string  //filepath
	*
	* @access public
	*/
	public function __construct($_fileOrArray = array(), $section = NULL, $allowChanges = false){
		//array based
		if(!is_array($_fileOrArray) && !is_string($_fileOrArray)){
			throw new JVM_Config_Exception('Configuration seems invalid');	
		}
		//file based
		elseif(is_string($_fileOrArray)){
			$this->filePath = $_fileOrArray;
			$_fileOrArray = $this->load($_fileOrArray);
		}
		if(!is_array($_fileOrArray)){
			throw new JVM_Config_Exception('Configuration is invalid', 2000);	
		}
		//call data array set section
		if($section && isset($_fileOrArray[$section])){
			$_fileOrArray = $_fileOrArray[$section];	
		}
		//set ini values
		if(isset($_fileOrArray['phpsettings'])){
			$this->setIni($_fileOrArray['phpsettings']);	
		}
		//set modification-flag (is read only)
		$this->setAllowChanges($allowChanges);
		//create conf object with parent
		parent::__construct($_fileOrArray, $allowChanges);
	}
	
	/**
    * @desc 
	* overwrites parent because config should not save objects (__set_state)
    * returns this object as array
	* no recursion assigned object delivered as is
    * 
	* @void
	*
	* @return this
    * 
 	* @access public
    */
    public function toArray(){
        $_result = array();
		$_data = $this->_data;
        foreach($_data as $key => $value){
            if($value instanceof JVM_Data){
                $_result[$key] = $value->toArray();
            }
			elseif(is_object($value)){
				$filter = new JVM_Filter_ObjectToArray();
				$_result[$key] = $filter->filter($value);	
			}
			else{
                $_result[$key] = $value;
            }
        }
    return $_result;
    }

	/**
    * @desc 
    * get a text by its name (lazy access / object access supported) 
    *
	* @input-required:
	* @param -> $name 	:string
	*
	* @input-optional:
	* @param -> $default :string (returned in case of null) 	
    * 
 	* @access public
    */		
	public function get($name, $default = NULL){
		$param = $this->getParam($name);
        if($param !== NULL){
            return($param);
        }
	return $default;
	}
	
	/**
    * @desc 
    * get a text by its name 
    *
	* @input-required:
	* @param -> $name 		:string
	* @param -> $value 		:string
    * 
 	* @access public
    */		
	public function set($name, $value, $overwrite = false){
		if($overwrite === true || $this->allowChanges == true){
            $this->setParam($name, $value, $overwrite);
        }
		else{
        	throw new JVM_Config_Exception('Configuration-File is not writable. Modifications are not allowed. Use Flag to allow Changes');
        }
	return $this;
	}
	
	/**
    * @desc 
    * delete a index from array 
    *
	* @input-required:
	* @param -> $name 		:string
	*
	* @input-optional:
	* @param -> $overwrite		:boolean
    * 
 	* @access public
    */		
	public function delete($name, $overwrite = false){
		if($overwrite === true || $this->allowChanges === true){
			$this->unsetParam($name, $overwrite);
		} 
		else{
            throw new JVM_Config_Exception('Configuration-File is not writable. Modifications are not allowed. Use Flag to allow Changes');
        }
	return $this;
	}
		
   /**
    * @desc 
    * loads a config file the returnvalue (by convention) is an array always
	* based on JVM_Loader
    *
	* @input-required:
	* @param -> $file 	:string
	*
	* @return : array
    * 
 	* @access private
    */		
	private function load($file){
		if(JVM_Loader::isFile($file) || JVM_Loader::isInIncludePath($file) ){
			//load by type
			$this->fileType = JVM_Loader::getExtension($file);
			switch($this->fileType){
				case('php'):
					return(include($file));
				break;
				case('ini'):
					return(parse_ini_file($file, true));
				break;
				case('xml'):
					$xml 	 = new SimpleXMLElement($file, NULL, false);
					$filter  = new JVM_Filter_ObjectToArray();
					return($filter->filter($xml));
				break;
				default:
					throw new JVM_Config_Exception('config file-type not supported', 1001);
				break;
			}
		}
		else{
			throw new JVM_Config_Exception('config not found check passed path or|and include_path', 1002); 	
		}
		throw new JVM_Config_Exception('unknown error', 1003);
	}

 	/**
    * @desc 
    * saves the current-config-array as excecutable php into file
    *
	* @input-optional:
	* @param -> $overwrite 	:boolean
	*
	* @return :none
    * 
 	* @access public
    */
	//todo see write 	
	public function save($filePath = NULL, $overwrite = false){
		if($filePath !== NULL){
			$this->filePath = $filePath;
			$this->fileType = JVM_Loader::getExtension($filePath);
		}
		if($this->filePath === NULL){
			throw new JVM_Config_Exception('no filname subitted', 1001); 	
		}
		//forbid overwrite
		if((JVM_Loader::isFile($this->filePath) || JVM_Loader::isInIncludePath($this->filePath)) && $overwrite === false){
			throw new JVM_Config_Exception('the file you tried to write to is locked use 1st parameter overwrite to overwrite file', 1001); 	
		}
		try{
			//open file writable 
			$fileObj = new SplFileObject($this->filePath,  "wb", (JVM_Loader::isFile($this->filePath) ? false : true)  );
			if($fileObj->flock(LOCK_EX)){ // exclusive lock
				//beautify content and write it into file
				$_search  = array('=> '.PHP_EOL, '   array (', 'array (', '=>     ', '=>   ');
				$_replace = array('=> ', ' array(', 'array(', '=> ', '=> ');
				$fileObj->fwrite(
					'<?php'.PHP_EOL.$this->getDocBlock().'return '.str_replace($_search, $_replace, var_export($this->toArray(), true)).';'.PHP_EOL 
				);
				$fileObj->flock(LOCK_UN);
			}
			else{
				throw new JVM_Config_Exception('could not get the lock please try again', 1001);		
			}
		}
		catch(Exception $e){
			throw new JVM_Config_Exception('write to file failed with message('.$e->getMessage().')', $e->getCode()); 
		}
	return $this;	
	}
	
	/**
	* @desc
	* generates doc block for generated configuration files 
	*
	* @void
	*	
	* @return none
	*
	* @access private
	*/		
	private function getDocBlock(){
		$_trace = debug_backtrace();
		array_shift($_trace); //2 line caused by strict standards
		if(isset($_trace[0]['file']) ){
			$this->_docBlock['file'] = $_trace[0]['file'];
		}
		if(isset($_trace[0]['line']) ){
			$this->_docBlock['line'] = $_trace[0]['line'];
		}
		$this->_docBlock['creation'] = date('d.m.Y H:i:s');
		$header = '/'.str_pad('', 120, '*').PHP_EOL;
		foreach($this->_docBlock as $head => $copy){
			$header .= ' * @'.trim($head).': '.trim($copy).PHP_EOL;
		}
		$header .= str_pad('', 120, '*').'/'.PHP_EOL;
	return $header;
	}
		
	/**
	* @desc
	* sets php-ini values (phpsettings)
	*
	* @input-required:
	* @param -> $_settings 	:array
	*	
	* @return this
	*
	* @access public static
	*/
	public static function setIni(array $_settings){
		if(is_array($_settings)){
			foreach($_settings as $name => $value){
				if(!ini_set($name, $value)){
					//ini_set returns false if value could not be set
				}
			}
		}	
	}
	
	/**
	* @desc
	* gets all php-ini values (phpsettings)
	* or single value for passed name (or false in case of error)
	*
	* @void
	*	
	* @return array
	*
	* @access public static
	*/
	public static function getIni($name = NULL){
		if($name != NULL){
			return(ini_get($name));	
		}
	return(ini_get_all());	
	}
			
}