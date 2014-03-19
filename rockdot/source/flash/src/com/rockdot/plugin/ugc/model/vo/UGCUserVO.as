package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCUserVO extends RockdotVO {
		public static const NETWORK_FACEBOOK : String = "facebook";
		public static const NETWORK_INPUTFORM : String = "input form";
		
		
		public var uid:String;
		public var locale : String;
		public var network:String;
		public var device:String;
		public var name:String;
		public var pic:String;
		public var login_count:int;
		public var timestamp_registered:String;
		public var timestamp_lastlogin:String;

		public function UGCUserVO(obj : Object = null) {
			super(obj);
		}
	}
}
