<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2011, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc JVM_Data implements ArrayAccess, RecursiveIterator , Serializable, Countable
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 * @package________JVM_Data
 *
 * @dependencies
 * @import: JVM_Data_Exception	 
 */
require_once('JVM/Data/Exception.php');
 
class JVM_Data implements ArrayAccess, RecursiveIterator, Serializable, Countable{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */
	/**
	* datacontainer
	* @var  :array
	*/
	protected $_data = array();	
	
	/**
	* current position
	* @var  mixed
	*/
	protected $position = 0;
	
   /**
	* lazy access separator
	* @var  mixed
	*/
	protected $separator = ',';	
	
  	/**
	* lazy access separator
	* @var  mixed
	*/
	protected $allowChanges = true;						
/*	+-----------------------------------------------------------------------------------+
	| 	contruct and init functionallity
	+-----------------------------------------------------------------------------------+  */
   /**
    * @desc 
    * initialize the data
    * 
	* @input-required:
	* @param -> $_data  			:array
    * 
 	* @access public
    */
    public function __construct($_data = array(), $allowChanges = true){
		if(!is_array($_data)){
			throw new JVM_Data_Exception('1st parameter must be type of array', 1001);	
		}
		//set Modificationflag
		$this->setAllowChanges($allowChanges);
		$this->_data = array();
        foreach($_data as $name => $value){
			if(property_exists($this, $name)){
				$this->$name = $value;	
			}
			else{
				if(is_array($value)){
					$this->_data[$name] = new self($value, $allowChanges);
				} 
				else{
					$this->_data[$name] = $value;
				}
			}
		}
    }
	
	/**
	* @description
	* sets overwrite
	*
	* @input-required:
	* @param -> $allowChanges		:boolean
	*	
	* @return :this			
	*
	* @access public
	*/
	final public function setAllowChanges($allowChanges){
		if(!is_bool($allowChanges)){
			throw new JVM_Model_Exception('allowChanges must be type of boolean', 1005);
		}
		$this->allowChanges = $allowChanges;
		foreach($this->_data as $item){
			if(is_object($item) && property_exists($item, 'allowChanges')){ 
				$item->allowChanges = $allowChanges;
			}
		}
	return $this;
	}
/*	+-----------------------------------------------------------------------------------+
	| 	access helper
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* set a splitvarable for easyaccess-params
	* notice:
	* your keynames should not contain the separatorchar
	*
	* @input-optional:
	* @param -> $separator 	:char
	*	
	* @return this
	*
	* @access public
	*/	
	public function setSeparator($separator){
		$_separators = array(',', ';', '/', ':', '.', '+');
		if(!in_array($separator, $_separators)){
			throw new JVM_Data_Exception('separator should not corrupt the parameternames. use valid separators instead: ('.implode(' ', $_separators).')', 1004);		
		}
		$this->separator = $separator;
	return $this;
	}
	
	/**
	* @desc
	* easy access / lazy access / path access
	* function follows a separated (separator) string or an array
	* test if passed path exists (ex.: 'a,0,4' or array('a', 0, 1))
	* Notice: does not handle exceptions if parameternames are corrupted
	*         by using a split-char that could exist within the parametername
	*
	* @input-required:
	* @param -> $path			:mixed (array/string)
	* @param -> $_inputArray	:specified superglobal array
	*
	* @input-optional:
	* @param -> $separator		:char
	*	
	* @return none
	*
	* @access public
	*/	
	//-----------------------------------------recursive---------------------------------//
	public static function getValueByPath($path, array $_inputArray, $separator = '.'){
		if(is_string($path)){
			//single path value
			if(isset($_inputArray[$path])){
				return 	$_inputArray[$path];
			}
			//try to find separator
			if(!strstr($path, $separator)){
				return NULL;	
			}
			$_path 	= preg_split('/\\'.$separator.'/', $path, NULL, PREG_SPLIT_NO_EMPTY);
		}
		elseif(is_array($path)){
			$_path 	= $path;
		}
		if(is_array($_path)){	
			if(count($_path) == 1 && is_array($_inputArray) && isset($_inputArray[$_path[0]])){
				return($_inputArray[$_path[0]]);
			}
			elseif(count($_path) == 1 && (!is_array($_inputArray) || !isset($_inputArray[$_path[0]]))){
				return(NULL);
			}
			foreach($_path as $value){
				if(is_scalar($value) && isset($_inputArray[$value]) && is_array($_inputArray[$value])){
					array_shift($_path);
					return(self::getValueByPath($_path , $_inputArray[$value], $separator)); 	
				}
			}
		}
	return NULL;
	}
	
	/**
	* @desc
	* sets given array to end and delivers true or false if given key is last array-index
	*
	* @input-required:
	* @param -> $key	:int/:string
	* @param -> $_array	:array
	*
	* @return :boolean
	*
	* @access public
	*/
	public static function isLastKey($key, array $_array){
		if(!is_string($key) && !is_int($key)){
			throw new JVM_Data_Exception('key must be type of string or integer', 1002);	
		}
		if($key === @end(@array_keys($_array))){
			return true;
		}
	return false;
	}
	
	/**
    * @description   
    * delivers a keyName for given pos
    *
    * @input-required:
    * @param -> $position   :int        
	* @param -> $_a    		:array        the array	
    *
    * @return :string       $encrypted
    *
    * @access public static
    */
	public static function getKeyByPosition($position, array $_array) {
		$_temp = array_slice($_array, $position, 1, true);
	return key($_temp);
	}		
	
 	/**
    * @description   
    * delivers a key for a requested value
	* !IMPORTANT doesnt care about doubled values (delivers first found match)
    *
    * @input-required:
    * @param -> $_a    	 :array        		the array
    * @param -> $value   :string|int        value	
    *
    * @return :string       mixed :string or false
    *
    * @access public static
    */
	//-----------------------------------------recursive---------------------------------//
	public static function searchKeyByValue($value, array $_array, $strict = false){
		$return = array_search($value, $_array, $strict);
		if($return === false){
			foreach($_array as $_sub){
				if(is_array($_sub)){
					$return = array_search($value, $_sub, $strict);
					if($return === false){
						$return = self::searchKeyByValue($value, $_sub, $strict);
					}
					else{
						return $return;	
					}
				}	
			}
		}
	return $return;
	}	
	
 	/**
    * @description   
    * delivers a value for a requested key
	* !IMPORTANT doesnt care about doubled keys (subkeys) (delivers first found match)	
    *
    * @input-required:
    * @param -> $_a	   :array        the array
    * @param -> $key   :array        the array	
    *
    * @return :string       mixed :string or false
    *
    * @access public static
    */
	//-----------------------------------------recursive---------------------------------//
	public static function searchValueByKey($key, array $_array){
		$return = NULL;
		if(array_key_exists($key, $_array)){
			return($_array[$key]);
		}
		else{
			foreach($_array as $idx => $_value){
				if(is_array($_value)){
					if(array_key_exists($key, $_value)){
						return($_value[$key]);
					}
					else{
						$return = self::searchValueByKey($key, $_value);	
					}
				}	
			}
		}
	return $return;
	}
		
   /**
    * @desc 
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
			else{
                $_result[$key] = $value;
            }
        }
    return $_result;
    }
	
	/**
	* @description
	* returns count if index exists
	*
	* @input-required:
	* @param -> $name	:string	
	*	
	* @return :int	
	*
	* @access public
	*/
	public function getCount($name){
		if($this->getParam($name) !== NULL){
			return count($this->getParam($name));
		}
	return NULL;
	}
	
	/**
	* @description
	* checks if parameter exists
	*
	* @input-required:
	* @param -> $name	:string	
	*	
	* @return :boolean	
	*
	* @access public
	*/
	public function issetParam($name){
		if($this->getParam($name) !== NULL){
			return true;
		}
	return false;
	}
	
	/**
	* @desc
	* returns requested bparameter from _data
	* or null if not found
	*
	* @input-required:
	* @param -> $name	:string	
	*	
	* @return :mixed
	*
	* @access public
	*/		
	public function getParam($name){
        if(is_string($name) && isset($this->_data[$name])){
            return($this->_data[$name]);
        }
		elseif(is_string($name) && property_exists($this, $name)){
			return $this->$name;	
		}
		elseif(is_array($name) || strstr($name, $this->separator)){
			if($value = $this->getValueByPath($name, $this->toArray(), $this->separator)){
				return $value; 
			}
		}
	return NULL;
	}		

	/**
	* @desc
	* returns complete _data
	*
	* @void
	*	
	* @return :array
	*
	* @access public
	*/		
	public function getParams(){
	return $this->_data;		
	}	

	/**
	* @description
	* sets a property
	*
	* @input-required:
	* @param -> $name			:string
	* @param -> $value			:mixed
	*
	* @input-optional:
	* @param -> $overwrite		:boolean
	*	
	* @return :this			
	*
	* @access public
	*/
	public function setParam($name, $value, $overwrite = false){
		if($this->issetParam($name) && ($overwrite === false && $this->allowChanges === false)){
			throw new JVM_Model_Exception('set third argument overwrite to true if you want to allow overwriting parameters or use setAllowChanges() to allow allways', 1004);
		}
		if(property_exists($this, $name)){
			$this->$name = $value;	
		}
		else{
			if(is_array($value)){
				$this->_data[$name] = new self($value);
			}
			else{
				$this->_data[$name] = $value;
			}
		}
	return $this;
	}
	
	/**
	* @description
	* unsets a property
	*
	* @input-required:
	* @param -> $name			:string
	*
	* @input-optional:
	* @param -> $overwrite		:boolean
	*	
	* @return :this			
	*
	* @access public
	*/
	public function unsetParam($name, $overwrite = false){
		if($overwrite === false && $this->allowChanges === false){
			throw new JVM_Model_Exception('set 2nd argument overwrite to true if you want to allow deleting parameters or use setAllowChanges() to allow allways', 1004);
		}
		if((array_key_exists($name, $this->_data))){
            unset($this->_data[$name]);
        }
		elseif(property_exists($this, $name)){
			unset($this->$name);		
		}
	return $this;
	}
	
	/**
	* @desc
	* replaces key (if found) with the value
	*
	* @input-required
	* @param  $string	:string
	*
	* @return :string 
	*
	* @access public 
	*/	
	public function replace($string){
		return(
			str_replace(
				array_keys($this->_data), //aka replace
				$this->_data, //(convention: assotiative key = search, value = replace)			
				$string
			)
		);	
	}	
/*	+-----------------------------------------------------------------------------------+
	| 	must implement methods defined by impelemented interfaces
	|   @see ArrayAccess, Iterator, Serializable, Countable
	+-----------------------------------------------------------------------------------+  */	
   /**
    * @see http://www.php.net/manual/en/class.arrayaccess.php
	*
    * @desc 
	* defined by ArrayAcces interface, sets an offset 
    * 
	* @input-required:
	* @param -> $offset  	:string/:int
	* @param -> $value  	:mixed
    * 
 	* @access public
    */	
	public function offsetSet($offset, $data){
		if (is_array($data)){
			$data = new self($data);
		}
		if ($offset === null){
			$this->_data[] = $data;
		} 
		else{
			$this->_data[$offset] = $data;
		}
    }
  
   /**
    * @see http://www.php.net/manual/en/class.arrayaccess.php
    *
    * @desc 
    * defined by ArrayAcces interface, tests if offset exists
    * 
	* @input-required:
	* @param -> $offset  	:string/:int
    * 
 	* @access public
    */		
    public function offsetExists($offset){
        return (isset($this->_data[$offset]));
    }

   /**
    * @see http://www.php.net/manual/en/class.arrayaccess.php
    * 
    * @desc 
    * defined by ArrayAcces interface, unsets an offset
    * 
	* @input-required:
	* @param -> $offset  	:string/:int
    * 
 	* @access public
    */		
    public function offsetUnset($offset){
        unset($this->_data[$offset]);
    }
   
   /**
    * @see http://www.php.net/manual/en/class.arrayaccess.php
    * 
    * @desc 
    * defined by ArrayAcces interface, delivers requested offset or NULL
    * 
	* @input-required:
	* @param -> $offset  	:string/:int
    * 
 	* @access public
    */	
    public function offsetGet($offset){
		if($this->offsetExists($offset)){
			return($this->_data[$offset]);
		}
    return(NULL);
    }
	
	/**
	* @see http://www.php.net/manual/de/class.recursiveiterator.php
    * @see http://www.php.net/manual/en/class.iterator.php
    * 
    * @desc 
    * defined by RecursiveIterator interface, rewinds this->_data
    * 
	* @void
    * 
 	* @access public
    */	
	public function rewind(){
		$this->position = 0;
        reset($this->_data);
    }
	
	/**
	* @see http://www.php.net/manual/de/class.recursiveiterator.php
    * @see http://www.php.net/manual/en/class.iterator.php
    * 
    * @desc 
    * defined by RecursiveIterator interface, delivers current pos of this->_data
    * 
	* @void
    * 
 	* @access public
    */
    public function current(){
        return current($this->_data);
    }
	
	/**
	* @see http://www.php.net/manual/de/class.recursiveiterator.php
    * @see http://www.php.net/manual/en/class.iterator.php
    * 
    * @desc 
    * defined by RecursiveIterator interface, delivers key of this->_data
    * 
	* @void
    * 
 	* @access public
    */
    public function key(){
        return key($this->_data);
    }

	/**
	* @see http://www.php.net/manual/de/class.recursiveiterator.php
    * @see http://www.php.net/manual/en/class.iterator.php
    * 
    * @desc 
    * defined by RecursiveIterator interface, nexts pointer
    * 
	* @void
    * 
 	* @access public
    */
    public function next(){
		$this->position++;
        return next($this->_data);
    }
    
	/**
	* @see http://www.php.net/manual/de/class.recursiveiterator.php
    * @see http://www.php.net/manual/en/class.iterator.php
    * 
    * @desc 
    * defined by RecursiveIterator interface, retuns true if pointer valid
    * 
	* @void
    * 
 	* @access public
    */
    public function valid(){
		return ($this->position < $this->count());
    }  
	
	/**
	* @see http://www.php.net/manual/de/class.recursiveiterator.php
	*
    * @desc 
    * extends RecursiveIterator for recursive access
    * 
	* @void
    * 
 	* @access public
    */
	public function hasChildren(){
		if( 
			is_array($this->current()) ||
			is_object($this->current()) 
		){
			return(true);	
		}
	return(false);	
	} 
	
	/**
	* @see http://www.php.net/manual/de/class.recursiveiterator.php
	*
    * @desc 
    * extends RecursiveIterator for recursive access
    * 
	* @void
    * 
 	* @access public
    */
	public function getChildren(){
	return($this->current());	
	}
	
	/**
    * @see http://php.net/manual/de/class.countable.php
    * 
    * @desc 
    * defined by Countable interface, retuns int
    * 
	* @void
    * 
 	* @access public
    */
    public function count(){
     	return count($this->_data);
    }
	
	/**
    * @see http://www.php.net/manual/en/class.serializable.php
    * 
    * @desc 
    * defined by Serializable interface, returns serialized data
    * 
	* @void
    * 
 	* @access public
    */
	public function serialize(){
        return serialize($this->_data);
    }
	
	/**
    * @see http://www.php.net/manual/en/class.serializable.php
    * 
    * @desc 
    * defined by Serializable interface, serializes the data
	*  
	* @input-required:
	* @param -> $_data :array	
    * 
	* @void
    * 
 	* @access public
    */	
    public function unserialize($_data) {
        $this->_data = unserialize($_data);
    }			
/*	+-----------------------------------------------------------------------------------+
	| 	magic access methods
	+-----------------------------------------------------------------------------------+  */		
	/**
    * @desc 
    * allow var_export
    * 
	* @input-required:
	* @param -> $_data :array
    * 
 	* @access public
    */	
	public static function __set_state($_data){
		return(new self($_data));
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
 	public function __unset($name){
       $this->unsetParam($name);
    }
	
	/**
	* @desc
	* tests if value has been set
	*
	* @input-required:
	* @param -> $name :mixed	
	*	
	* @return :boolean
	*
	* @access public
	*/	
    public function __isset($name){
        return(isset($this->_data[$name]));
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
		return $this->getParam($name);
    }
	
	/**
    * @desc 
    * allow chain-access
    * 
	* @input-required:
	* @param -> $name :string (parameter name)
	* @param -> $value :mixed (parameter value)
    * 
 	* @access public
    */	
 	public function __set($name, $value){
		$this->setParam($name, $value);
    }				
			
}