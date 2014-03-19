package com.rockdot.plugin.ugc.model {
	import com.rockdot.plugin.ugc.model.vo.UGCItemContainerVO;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;
	import com.rockdot.plugin.ugc.model.vo.UGCUserExtendedVO;
	import com.rockdot.plugin.ugc.model.vo.UGCUserVO;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class UGCModel {	
			
		protected var log : ILogger = getLogger(UGCModel);		

		private var _userDAO : UGCUserVO;
		private var _userSweepstakeDAO : UGCUserExtendedVO;

		private var _taskCategories : Array;
		private var _hasUserExtendedDAO : Boolean;
		public function set taskCategories(newTaskCategories : Array) : void {
			_taskCategories = newTaskCategories;
		}
		public function get taskCategories() : Array {
			return _taskCategories;
		}

		private var _loadedTasks : Array;
		public function set loadedTasks(loadedTasks : Array) : void {
			_loadedTasks = loadedTasks;
		}
		public function get loadedTasks() : Array {
			return _loadedTasks;
		}

		private var _ownContainers : Array;
		public function set ownContainers(newOwnContainers : Array) : void {
			_ownContainers = newOwnContainers;
		}
		public function get ownContainers() : Array {
			return _ownContainers;
		}
		private var _followContainers : Array;
		public function set followContainers(newContainers : Array) : void {
			_followContainers = newContainers;
		}
		public function get followContainers() : Array {
			return _followContainers;
		}
		private var _participantContainers : Array;
		public function set participantContainers(newContainers : Array) : void {
			_participantContainers = newContainers;
		}
		public function get participantContainers() : Array {
			return _participantContainers;
		}
		
		//these are detailed DB reads
		private var _currentItemDAO : UGCItemVO;
		
		private var _friendsWithPhotosUIDs : Array;
		private var _initialized : Boolean;
		private var _alternateLogin : Boolean;


		/***********************************************************************
		 * Gaming Model
		 ***********************************************************************/

		private var _gaming : UGCGamingModel;
		
		public function get gaming() : UGCGamingModel {
			return _gaming;
		}

		public function set gaming(gaming : UGCGamingModel) : void {
			_gaming = gaming;
		}

		/***********************************************************************
		 * UserDAO
		 ***********************************************************************/

		public function get userDAO() : UGCUserVO {
			return _userDAO;
		}

		public function set userDAO(userDAO : UGCUserVO) : void {
			_userDAO = userDAO;
		}
		
		public function get userExtendedDAO() : UGCUserExtendedVO {
			return _userSweepstakeDAO;
		}

		public function set userExtendedDAO(userSweepstakeDAO : UGCUserExtendedVO) : void {
			_userSweepstakeDAO = userSweepstakeDAO;
		}

		
		/***********************************************************************
		 * GALLERY - DAO
		 ***********************************************************************/

		public function get currentItemDAO() : UGCItemVO {
			return _currentItemDAO;
		}

		public function set currentItemDAO(currentItemDAO : UGCItemVO) : void {
			_currentItemDAO = currentItemDAO;
		}
		
		
		public function get friendsWithUGCItems() : Array {
			return _friendsWithPhotosUIDs;
		}
		
		public function set friendsWithUGCItems(galleryFriendArray : Array) : void {
			_friendsWithPhotosUIDs = galleryFriendArray;
		}
		
		public function get initialized() : Boolean {
			return _initialized;
		}
		
		public function set initialized(initialized : Boolean) : void {
			_initialized = initialized;
		}
		
		public function get alternateLogin() : Boolean {
			return _alternateLogin;
		}
		
		public function set alternateLogin(alternateLogin : Boolean) : void {
			_alternateLogin = alternateLogin;
		}
		
		protected var _service : *;
		public function set service(service : *) : void {
			_service = service;
		}
		public function get service() : * {
			return _service;
		}

		public function UGCModel() {
			gaming = new UGCGamingModel();
		}

		
		protected function _convertDateTime(entries : Array) : Array {
			for (var i : int = 0;i < entries.length;i++) {
				var vo : Object = entries[i];
				
				if(!vo.datetime) return entries;

				var datetime : Array = vo.datetime.split(" ");
				var date : Array = datetime[0].split("-");
				var time : Array = datetime[1].split(":");
				entries[i].date = date[2];
				entries[i].month = date[1];
				entries[i].year = date[0];
				entries[i].time = time[0] + ":" + time[1];
				
			}
			
			return entries;
		}

		
		private var _currentItemContainerDAO : UGCItemContainerVO;
		public function get currentItemContainerDAO() : UGCItemContainerVO {
			return _currentItemContainerDAO;
		}

		public function set currentItemContainerDAO(currentItemContainerDAO : UGCItemContainerVO) : void {
			_currentItemContainerDAO = currentItemContainerDAO;
		}

		private var _loadedItemContainerDAO : UGCItemContainerVO;
		public function get loadedItemContainerDAO() : UGCItemContainerVO {
			return _loadedItemContainerDAO;
		}

		public function set loadedItemContainerDAO(loadedItemContainerDAO : UGCItemContainerVO) : void {
			_loadedItemContainerDAO = loadedItemContainerDAO;
		}

		public function get hasUserExtendedDAO() : Boolean {
			return _hasUserExtendedDAO;
		}

		public function set hasUserExtendedDAO(hasUserExtendedDAO : Boolean) : void {
			_hasUserExtendedDAO = hasUserExtendedDAO;
		}

		

		

		

		
		
	}
}
