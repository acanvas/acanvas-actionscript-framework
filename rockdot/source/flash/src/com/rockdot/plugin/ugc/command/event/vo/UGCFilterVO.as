package com.rockdot.plugin.ugc.command.event.vo {

	/**
	 * @author nilsdoehring
	 */
	public class UGCFilterVO {

		public static const CONDITION_ALL : String = "CONDITION_ALL";
		public static const CONDITION_ME : String = "CONDITION_ME";
		public static const CONDITION_FRIENDS : String = "CONDITION_FRIENDS";
		public static const CONDITION_UID : String = "CONDITION_UID";
		public static const CONDITION_UGC_ID : String = "CONDITION_UGC_ID";
		
		public static const ORDER_DATE_DESC : String = "timestamp DESC";
		public static const ORDER_LIKES_DESC : String = "like_count DESC";

		public var condition : String;
		public var order : String;
		public var limit : Number;
		public var limitindex : Number;
		
		//ONE (and only one) of these needs to be set
		public var creator_uids : Array; //CONDITION_FRIENDS
		public var creator_uid : String; //CONDITION_ME, CONDITION_UID
		public var item_id : int; //CONDITION_UGC_ID

		public function UGCFilterVO(condition : String, order : String, limit : Number) {
			this.condition = condition;
			this.order = order;
			this.limit = limit;
			limitindex = 0;
		}
	}
}
