package com.rockdot.plugin.facebook.model.vo {	import com.rockdot.core.RockdotVO;	public class FBUserVO extends RockdotVO	{		public var id : String;		public var uid : String;		public var name:String;		public var first_name:String;		public var last_name:String;		public var is_app_user : Boolean;
		public var pic_square : String;
		public var locale : String;		public var email : String;		public var hometown_location : String;		public var birthday_date : String;		public function FBUserVO(obj:Object = null) {			 super(obj); 			 if(id=="" && uid!=""){			 	id = uid;
			 }			 if(uid=="" && id!=""){			 	uid = id;
			 }		}
	}}