package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCUserExtendedVO extends RockdotVO {
		public var uid:String;
		public var hash:String;

		public var birthday_date:String;
		public var hometown_location:String;
	
		public var title:String;
		
		public var firstname:String;
		public var lastname:String;
		public var street:String;
		public var additional:String;
		public var city:String;
		public var county:String;
		public var country:String;
		
		public var email:String;
		public var email_confirmed:int = 0;
		
		public var score:Number = 0;
		
		public var newsletter:int = 0;
		public var rules:int = 0;
		
		public var timestamp : String;
		
		public function UGCUserExtendedVO(obj : Object = null) {
			super(obj);
		}

	}
}
