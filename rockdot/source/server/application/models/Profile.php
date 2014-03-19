<?php
/*	
+---------------------------------------------------------------------------------------+
| Copyright (c) 2013, Joerg Di Terlizzi													|
| All rights reserved.																	|
| Author: Joerg Di Terlizzi <joerg.diterlizzi@jvm.de>									|
+---------------------------------------------------------------------------------------+ 
 *
 * @desc DB-Table Model
 * 
 * @author_________joerg.diterlizzi
 * @version________1.0        
 * @lastmodified___$Date: $ 
 * @revision_______$Revision: $ 
 * @copyright______Copyright (c) Jung von Matt / Neckar
 * @package________JVM_Model
 *
 * @dependencies
 * @import: JVM_Zend_Db_Table	 
 */
require_once('JVM/Zend/Db/Table.php');

class JVM_Model_Profile extends JVM_Zend_Db_Table{
/*	+-----------------------------------------------------------------------------------+
	| 	member vars
	+-----------------------------------------------------------------------------------+  */
	/**
	* tablename
	* @var  :string
	*/
    protected $_name = 'profile';
	
	/**
	* primary key
	* @var  :string
	*/
    protected $_primary = 'id';
	
	/**
	* user can take part in 5 profiles (1 himself + 4 partner)
	* @var  :int
	*/
	private $maxProfilesLimit = 5; //(5)
		
	/**
	* valid shirttypes + contrary
	* @var  :array
	*/
	private static $_shirtTypeMap = array(
		'mb' => 'fb',
		'mw' => 'fw',
		'fb' => 'mb',
		'fw' => 'mw'
	);
	
	/**
	* valid shirttypes + contrary
	* @var  :array
	*/
	private static $_shirtTypes = array(
		'mb' => 'male black',
		'mw' => 'male white',
		'fb' => 'female black',
		'fw' => 'female white'
	);
	
	/**
	* valid profilepicture sizes
	* @var  :array
	*/
	private static $_picSizes = array(
		'l' => '244',
		'm' => '224',
		's' => '174'
	);
	
	/**
	* valid orderby-fields
	* @var  :array
	*/
	private $_validOrderField = array(
		'RAND()',
		'score'	,
		'username',
		'id'
	);	
/*	+-----------------------------------------------------------------------------------+
	| 	methods
	+-----------------------------------------------------------------------------------+  */
	/**
	* @desc
	* sets the max-profile values
	* ( user can take part in 'value' profiles )
	*
	* @input-required
	* @param $id :string
	*	
	* @return :this
	*
	* @access public
	*/
	public function setMaxProfileLimit($maxProfilesLimit){
        if(!is_int($maxProfilesLimit)){
			throw new Zend_Db_Table_Exception('maxProfilesLimit must be typeof of integer', 1001 );		
		}
		$this->maxProfilesLimit = $maxProfilesLimit;
	return $this;
    }
	
	/**
	* @desc delivers aws path-array by userid
	*
	* @input-required
	* @param $id :string
	*	
	* @return :array
	*
	* @access public static
	*/
	public static function getProfilePath($id){
		$_path = array(
			'aws' => array()
		);
		//profile-pic
		$picName = 'profile-pic-%s.jpg';
		//configurate-array
		$_path['aws']['baseurl'] = Zend_Registry::get('Application_Config')->service->amazon->baseUrl;
		$_path['aws']['bucket'] = Zend_Registry::get('Application_Config')->service->amazon->buckets->profiles;
		$_path['aws']['object_folder'] = $id;
		$_path['aws']['profile_path'] = ((string) 
			DIRECTORY_SEPARATOR . 
		   	$id .
		   	DIRECTORY_SEPARATOR
		);
		foreach(self::$_picSizes as $sizeLc => $size){
			$_path['aws']['pictures'][$sizeLc] = ((string) 
				'https://' .
				$_path['aws']['baseurl'] . 
				$_path['aws']['profile_path'] . 
				sprintf($picName,$sizeLc)
			);
		}
	return $_path;
	}
	
	/**
	* @desc delivers path to fb-profile-pic
	*
	* @input-required
	* @param $id :string
	*	
	* @return :string
	*
	* @access public static
	*/
	public static function getFacebookProfilePic($fbid){
		return 'https://graph.facebook.com/'.$fbid.'/picture?redirect=false&type=small';
	}
		
	/**
	* @desc
	* returns contrary shirtType (2 lettercode)
	*	
	* @input-required
	* @param $shirtType :string
	*
	* @return :string
	*
	* @access private static
	*/
	private static function getContraryShirtType($shirtType){
		if(!is_string($shirtType)){
			throw new Zend_Db_Table_Exception('shirtType must be typeof string.', 1001);	
		}
		if(!isset(self::$_shirtTypeMap[$shirtType])){
			throw new Zend_Db_Table_Exception(' get contrary-shirt failed. shirtType '.$shirtType.' not available.', 1001);	
		}
	return self::$_shirtTypeMap[$shirtType];
	}
	
	/**
	* @desc
	* returns contrary shirtType (2 lettercode)
	*	
	* @input-required
	* @param $shirtType :string
	*
	* @return :string
	*
	* @access private static
	*/
	private static function getShirtTypeByLc($shirtType){
		if(!isset(self::$_shirtTypes[$shirtType])){
			throw new Zend_Db_Table_Exception('get full-shirt-name failed. shirtType '.$shirtType.' not available.', 1001);	
		}
	return self::$_shirtTypes[$shirtType];
	}
	
	/**
	* @desc
	* returns valid picsizes
	*	
	* @void
	*
	* @return :array
	*
	* @access public static
	*/
	public static function getPicSizes(){
	return self::$_picSizes;
	}
	
	/**
	* @desc
	* returns a subset of related partnerids
	*	
	* @input-required
	* @param $id :string
	*
	* @return :array
	*
	* @access public
	*/
	public function getRelatedIds($id){
		//---------------------------
		//validate input
		if(!is_string($id)){
			throw new Zend_Db_Table_Exception('id must be typeof string', 1001 );			
		}
		//---------------------------
		//joins must use the default adapter istead of tabele-select
		$adapter = $this->getDefaultAdapter();
		//fetch profile (save to 
	 	return $adapter->fetchAll(
			$adapter->select()
					//------------------------------
				 	//table definitions
				 	->from('couples', 'id')
					//------------------------------
					//add couple_id
				 	->where('couples.partner_id = ?', $id)
		);	
	}
		
	/**
	* @desc
	* retuns single profile by id
	*	
	* @input-required
	* @param $id :string
	*
	* @return :array
	*
	* @access public
	*/
	public function getProfileById($id, $regardFlags = true){
		//---------------------------
		//validate input
		if(!is_string($id) && !is_array($id)){
			throw new Zend_Db_Table_Exception('id must be typeof string or an array-list of ids', 1001 );			
		}
		//---------------------------
		//joins must use the default adapter istead of tabele-select
		$adapter = $this->getDefaultAdapter();
		//build select
		$select = $adapter->select()
						  //------------------------------
						  //table definitions
						  ->from(
								'profile',
								array(
									'*',
									'profiles' => new Zend_Db_Expr('(SELECT COUNT(couples.couple_id) FROM couples WHERE couples.id = profile.id)')
								)
						  )
						  //------------------------------
						  //add couple_id
						  ->joinleft(
						  		array('c' => 'couples'), 
								'c.id = profile.id', 
								array(
									'couple_id',
									'partner_id'
								)
							)
						  //------------------------------
						  //user must be active and confirmed
						  ->joinLeft(
							  'user', 
							  'user.id = profile.id', 
							  array(
								  'is_active', 
								  'has_profile',
								  'optin_confirmed',
								  'external_id',
								  'source'
							  )
						  );
						  //------------------------------
						  //add profile-counter
						  /*->joinLeft(
						  	  'couples', 
							  '(couples.partner_id = profile.id) AND couples.is_active = 1', 
							  array(
							  	'profiles' => 'COUNT(couples.couple_id)'
							  )
						  );*/
		//------------------------------						
		//regard multi requests
		if(is_array($id)){
			$select = $select->where('profile.id IN(?)', $id)->group('profile.id')->limit(5);
			//get more than one result-row
			$singleRow = false;	
		}
		else{
			$select = $select->where('profile.id = ?', $id)->limit(1);
			//get one result-row
			$singleRow = true;	
		}
		//------------------------------
		//regarding flags (non-admin mode)
		if($regardFlags === true){
			$select = $select->having('user.is_active = 1')
						     ->having('user.optin_confirmed = 1');
		}
		//------------------------------
		//fetch profile
	 	return $this->restructure(
			$adapter->fetchAll(
				$select	
			),
			$singleRow
		);
	}
	
	/**
	* @desc
	* delivers matching profiles
	*
	* @notice $_user is not validated 
	* (user is loggedin, data fetched with Zend_Auth::getInstance()->getStorage())
	*	
	* @input-required
	* @param $_user :array|JVM_Data (loggedin user)
	*
	* @input-optional
	* @param $page :int (offset calculated internally)
	* @param $orderBy :string
	*
	* @return :array
	*
	* @access public
	*/
	public function getMatchingProfiles($_user, $page = 0, $orderBy = 'score'){
		//---------------------------
		//validate input
		if((!is_array($_user) && !is_object($_user)) || empty($_user)){
			throw new Zend_Db_Table_Exception('no user submitted', 1001 );			
		}
		if(is_array($_user)){
			$_user = new JVM_Data($_user);	
		}
		if(!is_int($page) || $page < 0){
			$page = 0;			
		}
		if(!in_array($orderBy, $this->_validOrderField)){
			$orderBy = 'score';
		}
		//---------------------------
		try{
			//---------------------------
			//joins must use the default adapter istead of table-select
			$adapter = $this->getAdapter();
			//---------------------------
			//build subselect to calculate distance profile (bound params) //6370.7061896 vs 6380
			$sub_select = $this->select()
						  ->from(
								array('p' => 'profile'), 
								array(
									'pid' => 'id', 
									'distance' => 'ROUND((ACOS(
											SIN(RADIANS(`p`.`lat`) ) * SIN( RADIANS(:latitude)) +
											COS(RADIANS(`p`.`lat`) ) * COS( RADIANS(:latitude)) *
											COS(RADIANS(`p`.`lng`) - RADIANS(:longitude))
									) * 3959),0 )', //) * 6372 )* 0.62137 ,0)'
									'profiles' => new Zend_Db_Expr('(SELECT COUNT(couples.couple_id) FROM couples WHERE couples.id = p.id)')
								)
						  );
			//build select
			$select = $adapter->select()
					//------------------------------
					//table definitions
					->from(
						'profile', 
						array(
							new Zend_Db_Expr('SQL_CALC_FOUND_ROWS profile.id'), 'username', 'shirt_type', 'has_shirt', 'country', 'city',
							//matching-score 
							'score' => '100-ROUND((ABS(profile.match_01-:input_match_01)+ABS(profile.match_02-:input_match_02)+ABS(profile.match_03-:input_match_03)+ABS(profile.match_04-:input_match_04)+ABS(profile.match_05-:input_match_05)),0)',
							'id',
							'match_01',
							'match_02',
							'match_03',
							'match_04',
							'match_05'
						)
					)
					//------------------------------
					//add distance 
					->joinLeft(
						array('p' => $sub_select), 
						'p.pid = profile.id'
					)
					//------------------------------
					//user must be active and confirmed
					->joinLeft(
						'user', 
						'user.id = profile.id', 
						array(
							'is_active', 
							'optin_confirmed',
							'external_id',
							'source'
						)
					)
					//------------------------------
					//add profile-counter
					/*->joinLeft(
						'couples', 
						'(couples.partner_id = profile.id OR couples.id = profile.id) AND couples.is_active = 1', 
						array(
							'profiles' => 'COUNT(couples.couple_id)'
						)
					)*/
					//------------------------------
					//max 4 partner-profiles each user
					->having('profiles <= ?', $this->maxProfilesLimit)
					//search in depending countries only
					->having('profile.country IN(?)', JVM_Model_Geo::getCountryMap($_user->country))
					//must have flags
					->having('user.is_active = 1')
					->having('user.optin_confirmed = 1')
					//------------------------------
					//search for conrtary shirt_type
					->where('profile.shirt_type = ?',  $this->getContraryShirtType($_user->shirt_type))
					//------------------------------
					//group by profile.id
					->group('profile.id')
					//------------------------------
					//orderby(default: score DESC)
					->order($orderBy.' '.$this->sortOrder)
					//------------------------------
					//set limit (paged)
					->limit($this->limit, ((int) $page) * $this->limit)
					//------------------------------
					//set bound params
					->bind(
						array(
							':longitude' => (float) $_user->lng,
							':latitude' => (float) $_user->lat,
							':input_match_01' => (int) $_user->match_01,
							':input_match_02' => (int) $_user->match_02,
							':input_match_03' => (int) $_user->match_03,
							':input_match_04' => (int) $_user->match_04,
							':input_match_05' => (int) $_user->match_05
						)
					);
			//---------------------------				  		
			//fetch profile
			return $this->restructure(
				$adapter->fetchAll(
					$select
				)
			);
		}
		catch(Exception $e){
			echo $e->getMessage();
			//return empty array in case of error
			return array();	
		}
	}
	
	/**
	* @desc
	* delivers profiles (admin-controller)
	*
	* @notice $_user is not validated 
	* (user is loggedin, data fetched with Zend_Auth::getInstance()->getStorage())
	*
	* @input-optional
	* @param $offset :int
	* @param $orderBy :string
	* @param $sortOrder :string (ASC,DESC)	
	*
	* @return :array
	*
	* @access public
	*/
	public function getProfiles($offset = 0, $orderBy = 'date'){
		//---------------------------
		//validate input
		if(!is_numeric($offset)){
			throw new Zend_Db_Table_Exception('offset must be typeof integer', 1001 );			
		}
		if(!is_string($orderBy)){
			throw new Zend_Db_Table_Exception('orderBy must be a valid string', 1001 );			
		}
		//---------------------------
		try{
			//---------------------------
			//joins must use the default adapter istead of table-select
			$adapter = $this->getAdapter();
			//build select
			$select = $adapter->select()
					//------------------------------
					//table definitions
					->from('profile', array(new Zend_Db_Expr('SQL_CALC_FOUND_ROWS profile.id'), '*'))
					//------------------------------
					//user must be active and confirmed
					->joinLeft(
						'user', 
						'user.id = profile.id', 
						array(
							'is_active', 
							'optin_confirmed',
							'id', 
							'date_formatted' => "DATE_FORMAT(`user`.`date`, '%d.%m.%y')"
						)
					)
					//------------------------------
					//add profile-counter
					->joinLeft(
						'couples', 
						'(couples.partner_id = profile.id OR couples.id = profile.id) AND couples.is_active = 1', 
						array(
							'profiles' => 'COUNT(couples.couple_id)'
						)
					)
					->where('user.id IS NOT NULL')
					//------------------------------
					//group by profile.id
					->group('profile.id')
					//------------------------------
					//orderby(default: score DESC)
					->order('UPPER('.$orderBy.') '.$this->sortOrder)
					//------------------------------
					//set limit (paged)
					->limit($this->limit, ((int) $offset) * $this->limit);
			//---------------------------				  		
			//fetch profile
			return $this->restructure(
				$adapter->fetchAll(
					$select
				)
			);
		}
		catch(Exception $e){
			echo $e->getMessage();
			//return empty array in case of error
			return array();	
		}
	}
	
	/**
	* @desc
	* restructure input data (cleanup returned data)
	*	
	* @input-required
	* @param $_data :array (query-result)
	*
	* @input-optional
	* @param $singleRow :boolean
	*
	* @return :array
	*
	* @access public
	*/
	private function restructure($_data, $singleRow = false){
		//fetch countries from geo-model
		$_countries = JVM_Model_Geo::getValidCountries();
		//return unstructured empty
		if(!empty($_data) && is_array($_data)){
			foreach($_data as $idx => $_row){
				foreach($_row as $name => $value){
					//add formatted values
					if($name === 'id'){
						$_data[$idx]['assets'] = self::getProfilePath($value);
					}
					if($name === 'external_id' && $_row['source'] === 'facebook'){
						$_data[$idx]['assets']['facebook']['picture'] = self::getFacebookProfilePic($value);	
					}
					if($name === 'country' && isset($_countries[$value])){
						$_data[$idx]['country_formatted'] = $_countries[$value];
					}	
					if($name === 'shirt_type' && isset(self::$_shirtTypes[$value])){
						$_data[$idx]['shirt_type_formatted'] = self::$_shirtTypes[$value];
					}	
				}				
			}
		}
		if($singleRow === true && isset($_data[0]['id']) && count($_data) == 1){
			return $_data[0];		
		}
	return $_data;	
	}
		
}