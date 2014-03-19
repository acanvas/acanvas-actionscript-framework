<?
class JVM_DBTable extends JVM_Zend_Db_Table {

	public $adapter;
	protected $sql_table_prefix;
	
	public function init() {
		$this->adapter = $this->getAdapter();
		
		$properties = Zend_Registry::get('Application_Config');
		$this->sql_table_prefix = $properties->db->prefix;
	}

	public function _asObj($result) {
		$obj = new stdClass ( );
		foreach ( $result as $key => $value )
		{
			$obj->$key = $value;
		}
		return $obj;
	}


	/**
	 * internal function
	 */
	public function create($tablename, $asDAO) {
		//return $this->_object2array($asDAO);
		//return $this->adapter->insert($this->sql_table_prefix . '_' . $tablename, $this->_object2array($asDAO));
		//$this->adapter->lastInsertId();
		try {
			return $this->adapter->insert($this->sql_table_prefix . '_' . $tablename, $this->_object2array($asDAO));
		} catch (Zend_Db_Exception $e) {
			if(strstr($e->getMessage(), '1062 Duplicate')) {
				// duplicate
				return 0;
			} else {
				// general error

			}
		}
	}

	private function _object2array($object) {
		if (is_object($object)) {
			foreach ($object as $key => $value) {
				if(!empty($value)){
					$array[$key] = $value;
				}
			}
		}
		else {
			$array = $object;
		}
		return $array;
	}


	/**
	 * internal function
	 */
	public function read($tablename, $asDAO, $join, $limit, $limitindex, $order = "") {

		$arr = array();

		if($asDAO){
			foreach ($asDAO as $key => $value){
				if(!empty($value)){
					$arr[$this->sql_table_prefix . '_' . $tablename . "." . $key] = $value;
				}
			}
		}

		$select = $this->adapter->select();
		$select->from($this->sql_table_prefix . '_' . $tablename);

		if(sizeof($arr)>0){
			foreach ($arr as $key => $value){
				if(is_array($value)){
					$select->where($key . " IN (?)", $value);
				}
				else{
					$select->where($key . " = ?", $value);
				}
			}
		}

		if(sizeof($join)>0){
			$select->joinleft($this->sql_table_prefix . '_' . $join[0], $this->sql_table_prefix . '_' . $tablename . "." . $join[1] . '=' . $this->sql_table_prefix . '_' . $join[0] . "." . $join[2]);
		}

		if($limit!=0){
			$select->limit($limit, $limitindex);
		}

		if(!empty($order)){
			$select->order($this->sql_table_prefix . '_' . $tablename . '.' . $order);
		}

		//		return $select->__toString();
		$rows = $this->adapter->fetchAll(
				$select
		);

		return $this->readPostProcess($rows, $tablename, $arr);

	}

	private function readPostProcess($rows, $tablename, $condition){
		$ret = array();
		$idx = 0;
		foreach ($rows as $row){

			$row["rowindex"] = $idx;

			if(!empty($row["creator_uid"])){

				$fetch = $this->adapter->fetchAll(
						$this->adapter->select()
						->from($this->sql_table_prefix . '_users')
						->where('uid = ?', $row["creator_uid"])
				);
				$row["creator"] = $fetch[0];
			}

			array_push ( $ret, $row);
			$idx++;
		}
		if(sizeof($ret)>0){
			$numrows = $this->numrows($tablename, $condition);
			$ret[0]["totalrows"] = $numrows;
			return $ret;
		} else {
			return array();
		}
	}

	/**
	 * internal function
	 */
	public function _update($tablename, $asDAO, $where) {
		$data = array();

		if($asDAO){
			foreach ($asDAO as $key => $value){
				if(!empty($value)){
					$data[$this->sql_table_prefix . '_' . $tablename . "." . $key] = $value;
				}
			}
		}

			
		$result = $this->adapter->update($this->sql_table_prefix . "_users", $data, $where);
		return $result;
	}



	/**
	 * internal function
	 */
	public function _delete($tablename, $asDAO) {
		$data = array();

		if($asDAO){
			foreach ($asDAO as $key => $value){
				if(!empty($value)){
					$data[$this->sql_table_prefix . '_' . $tablename . "." . $key] = $value;
				}
			}
		}

			
		$this->adapter->delete($this->sql_table_prefix . '_' . $tablename, $data);
		return $this->adapter->getAffectedRows();

	}

	/**
	 * internal function
	 */
	public function numrows($tablename, $condition) {
		if($tablename == "users"){
			$select = $this->adapter->select()
			->from($this->sql_table_prefix . '_' . $tablename, array('COUNT(uid) AS count'));
		}
		else{
			$select = $this->adapter->select()
			->from($this->sql_table_prefix . '_' . $tablename, array('COUNT(id) AS count'));
		}
			
		foreach ($condition as $key => $value){
			if(is_array($value)){
				$select->where($key . " IN (?)", $value);
			}
			else{
				$select->where($key . " = ?", $value);
			}
		}
		$fetch = $this->adapter->fetchAll(
				$select
		);
			
		return $fetch[0]["count"];
	}
	
	/**
	 * @desc delivers path to fb-profile-pic. Internal!
	 *
	 * @input-required
	 * @param $id :string
	 *
	 * @return :string
	 *
	 * @access public static
	 */
	public static function getFacebookProfilePic($fbid){
		return 'https://graph.facebook.com/'.$fbid.'/picture?redirect=true&type=square';
	}
	
	

}
?>