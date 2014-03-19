package com.rockdot.plugin.ugc.command.event {

	/**
	 * @author nilsdoehring
	 */
	public class UGCEvents {
		
		//expects nothing, returns nothing
		public static const INIT : String		 				= "UGCEvents.INIT";
		public static const TEST : String		 				= "UGCEvents.TEST";
		
		//expects DAOUGCCRUD, returns OperationEvent with result = id of inserted row
		public static const CREATE_ITEM : String 				= "UGCEvents.CREATE_ITEM";

		//expects DAOUGCCRUD, returns OperationEvent with result = Array<UGCItemDAO>
		public static const READ_ITEM : String 				= "UGCEvents.READ_ITEMS";
		

		//expects DAOUGCCRUD, returns OperationEvent with result = id of inserted row
		public static const CREATE_ITEM_CONTAINER : String 				= "UGCEvents.CREATE_ITEM_CONTAINER";

		//expects DAOUGCCRUD, returns OperationEvent with result = Array<UGCItemDAO>
		public static const READ_ITEM_CONTAINER : String 				= "UGCEvents.READ_ITEM_CONTAINER";
		public static const READ_ITEM_CONTAINERS_UID : String 			= "UGCEvents.READ_ITEM_CONTAINERS_UID";
		
		
		//expects nothing, uses _ugcModel.userDAO or creates new User (from FB data!), returns UserDAO
		public static const USER_REGISTER : String 				= "UGCEvents.USER_REGISTER";

		//expects nothing, uses _ugcModel.userDAO or creates new User (from FB data!), returns UserDAO, sets _ugcModel.userDAO
		public static const USER_REGISTER_EXTENDED : String 	= "UGCEvents.USER_REGISTER_EXTENDED";

		//expects nothing, uses .properties and _ugcModel.userSweepstakeDAO.email
		public static const USER_MAIL_SEND : String 			= "UGCEvents.USER_MAIL_SEND";

		//expects DAOUGCFilter, supports following DAOUGCFilter.conditions :
		//DAOUGCFilter.CONDITION_FRIENDS: filter by facebook friends that also participated with an upload
		//DAOUGCFilter.CONDITION_ME: filter by my own uploads
		//DAOUGCFilter.CONDITION_UGC_ID: filter by an Item's ID
		//DAOUGCFilter.CONDITION_ALL: no filter (you can still arrange by date or likes)
		//DAOUGCFilter.CONDITION_UID: filter by a uid
		public static const ITEMS_FILTER : String 				= "UGCEvents.ITEMS_FILTER";

		//DAOUGCFilter, sets/returns _ugcModel.currentItemDAO.likers (Array<UGCUserDAO>)
		public static const ITEM_LIKERS_GET : String 			= "UGCEvents.ITEM_LIKERS_GET";
		
		//expects int (item id), uses _ugcModel.userDAO.uid, returns nothing
		public static const ITEM_LIKE : String 					= "UGCEvents.ITEM_LIKE";
		
		//expects int (item id), uses _ugcModel.userDAO.uid, returns nothing
		public static const ITEM_UNLIKE : String 				= "UGCEvents.ITEM_UNLIKE";
		
		//expects DAOUGCItem, using DAOUGCItem.di, DAOUGCItem.rating, _ugcModel.userDAO.uid, returns nothing
		public static const ITEM_RATE : String 					= "UGCEvents.ITEM_RATE";

		//expects DAOUGCItem, using DAOUGCItem.id, DAOUGCItem.rating, _ugcModel.userDAO.uid, returns nothing
		public static const ITEM_COMPLAIN : String 				= "UGCEvents.ITEM_COMPLAIN";

		//expects nothing, uses _ugcModel.currentItemDAO.id, returns nothing
		public static const ITEM_DELETE : String = "UGCEvents.ITEM_DELETE";
		
		//UGCFriendsReadCommand, uses _modelFB.friendsWhoAreAppUsers, sets/returns _ugcModel.friendsWithUGCItems (Array<UGCUserDAO>)
		public static const ITEMS_FRIENDS_GET : String = "UGCEvents.ITEMS_FRIENDS_GET";
		
		//{uid:"", request_id:"", data:"", to:ids:""}
		public static const TRACK_INVITE : String = "UGCEvents.TRACK_INVITE";

		//TASK: Get Category List
		public static const TASK_GET_CATEGORIES : String = "UGCEvents.TASK_GET_CATEGORIES";

		//TASK: Get Tasks by Category
		public static const TASK_GET_TASK_BY_CATEGORY : String = "UGCEvents.TASK_GET_TASK_BY_CATEGORY";
	
		//TASK: Assign Task to Itemcontainer
		public static const TASK_ASSIGN_TO_CONTAINER : String = "UGCEvents.TASK_ASSIGN_TO_CONTAINER";
		public static const USER_HAS_EXTENDED : String = "UGCEvents.USER_READ_EXTENDED";
		public static const USER_HAS_EXTENDED_TODAY : String = "UGCEvents.USER_HAS_EXTENDED_TODAY";
		
	}
}
