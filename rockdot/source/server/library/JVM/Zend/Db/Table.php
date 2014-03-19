<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2011, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc Zend_Db_Table wrapper-class provides additional functions 
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 * @package________JVM_Zend_Db
 *
 * @dependencies
 * @import: Zend_Db_Table
 * @import: Zend_Db_Table_Exception	 
 */
require_once('Zend/Db/Table.php');
require_once('Zend/Db/Table/Exception.php');
 
class JVM_Zend_Db_Table extends Zend_Db_Table_Abstract{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */
	/**
	* default limit
	* @var  :string
	*/
	protected $limit = 10;
	
	/**
	* default sortorder
	* @var  :string
	*/
	protected $sortOrder = 'ASC';
/*	+-----------------------------------------------------------------------------------+
	| 	functions
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* returns the table-name
	*
	* @void	
	*	
	* @return :string
	*
	* @access public
	*/
	public function getName(){
        return $this->_name;
    }
		
	/**
	* @desc
	* sets the standard used limit
	*
	* @input-required
	* @param $limit :integer
	*	
	* @return :this
	*
	* @access public
	*/
	public function setLimit($limit = 10){
        if(is_int($limit)){
			//only setting the limit if value is valid
			$this->limit = (int) $limit;
		}
	return $this;
    }
	
	/**
	* @desc
	* returns the current limit
	*
	* @void	
	*	
	* @return :integer
	*
	* @access public
	*/
	public function getLimit(){
        return $this->limit;
    }
		
	/**
	* @desc
	* sets the standard used limit
	*
	* @input-required
	* @param $sortOrder :atring
	*	
	* @return :this
	*
	* @access public
	*/
	public function setSortOrder($sortOrder){
		$sortOrder = strtoupper($sortOrder);
		//only setting the sortorder if valid
        if($sortOrder === 'ASC' || $sortOrder === 'DESC'){
			$this->sortOrder = (string) strtoupper($sortOrder);	
		}
	return $this;
    }
	
	
	
	/**
	* @desc
	* returns the current sortorder
	*
	* @void	
	*	
	* @return :string
	*
	* @access public
	*/
	public function getSortOrder(){
        return $this->sortOrder;
    }
	
	/**
	* @desc
	* get table columns (with or without prefix)
	* 
	* @notice! they could be cached
	*	
	* @input-required
	* @param $prefix :string|NULL
	*
	* @input-optional
	* @param $_excludes :array
	*
	* @return :array
	*
	* @access public
	*/
	public function getCols($prefix = NULL, $_excludes = array()){
		//------------------------------
		if(!is_string($prefix) && $prefix != NULL){
			throw new Zend_Db_Table_Exception('prefix must be typeof string or NULL if not used', 1001 );		
		}
		if(!is_array($_excludes)){
			throw new Zend_Db_Table_Exception('_exlcudes must be typeof of array', 1001 );		
		}
		//------------------------------
		$_cols = array();
		//fetch columns from table 
		$_metaCols = $this->_getCols();
		//add prefix to each column
		if($prefix !== NULL){
			foreach($_metaCols as $colname){
				if(!in_array($colname, $_excludes)){
					$_cols[(string) $prefix.$colname] = $colname;
				}
			}
			return $_cols;
		}
	//------------------------------
	//no prefix
	return $_metaCols;
	}
		
	/**
	* @desc
	* quote helper (supports multi-quotes)
	* concat = AND
	*	
	* @input-required
	* @param $expression :string|array
	* @param $value :string (is required when expression not an array)
	*
	* @return :string
	*
	* @access public
	*/
	public function quote($expression, $value = NULL){
		//------------------------------
		//multi-quote
		if(is_array($expression) && $value == NULL){
			$_parts = array();
			foreach($expression as $expr => $val){
				$_parts[] = $this->getAdapter()->quoteInto($expr, $val);
			}
			return implode(' AND ', $_parts);
		}
		if(!is_string($expression) && !is_string($value)){
			throw new Zend_Db_Table_Exception('expression and value must be typeof string if not using array-structure', 1001 );			
		}
	//------------------------------
	//single-quote
	return $this->getAdapter()->quoteInto($expression, $value);	
	}
	
	/**
	* @desc
	* check specific field / or primary-key if unique or existing
	* if values is a string check runs against primary-key
	*	
	* @input-required
	* @param $values :array|string (where value(s)
	*
	* @input-optional
	* @param $additionalWhere :string
	*
	* @return :boolean
	*
	* @access public
	*/
    public function exists($values, $additionalWhere = NULL){
		//------------------------------
		//handle input errors
		if(!is_string($values) && !is_array($values)){
			throw new Zend_Db_Table_Exception('value must be typeof string or a field/value structured array', 1001 );		
		}
		//------------------------------
		//build select
		$select = $this->select()->from($this->getName(), $this->_primary)->limit(1);
		//------------------------------
		//build where (single value tests primary)
		if(is_array($values)){
			foreach($values as $field => $value){
				$select = $select->where($field.'=?', $value);
			}
		}
		else{
			$select = $select->where(
				$this->getAdapter()->quoteIdentifier($this->_primary).'=?', 
				$values
			);	
		}
		//------------------------------
		//additional where
		if($additionalWhere != NULL){
			$select = $select->where($additionalWhere);		
		}
		//------------------------------
		//test result 
		if($this->getAdapter()->fetchOne($select)){
			return true;
		}
		//------------------------------
    return false; 
    }
	
	/**
	* @desc
	* counts row in last select based on SQL_CALC_FOUND_ROWS
	*	
	* @void
	*
	* @return :integer
	*
	* @access public
	*/
	public function getRowCount(){
		$_result = $this->getAdapter()->fetchAll(
			'SELECT FOUND_ROWS() AS count;'
		);
		if(isset($_result[0]['count'])){
			return $_result[0]['count'];
		}
	return 0;
	}
		
	/**
	* @desc
	* counts row in table
	*	
	* @input-optional
	* @param $additionalWhere :string (should be quoted when used)
	*
	* @return :integer
	*
	* @access public
	*/
    public function count($additionalWhere = NULL){
		//------------------------------
		//additional where
		$select = $this->select()
				 	   ->from(
					   		$this->getName(), 
							array('count' => $this->quote('COUNT(?)', $this->_primary)) 
						)
				 	   ->limit(1);
		//------------------------------
		//additional where
		if($additionalWhere != NULL){
			$select = $select->where($additionalWhere);		
		}
		//------------------------------
		//return scalar
		return (int) $this->getAdapter()->fetchOne(
			$select	
		);				
	}
	
	/**
    * @description   
    * delivers a unique random string for given len parameter
	* works as pageid for jQMobile
    *
    * @input-optional:
    * @param -> $len	:int   length of random string
    *
    * @return :string
    *
    * @access public static 
    */
	public static function createUid($len = 32){
		$string = md5(microtime().uniqid());
		while(strlen($string) < $len){
			 $string .= md5($string.microtime());
		}
	return substr($string, 0, $len);
	}
	
}