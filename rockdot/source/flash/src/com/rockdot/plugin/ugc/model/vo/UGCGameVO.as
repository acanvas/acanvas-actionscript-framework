package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCGameVO extends RockdotVO {
		public var uid:String;
		public var level : int;
		public var score : Number;
		public var control : String;
		public var timestamp : String;

		public function UGCGameVO(obj : Object = null) {
			super(obj);
		}
	}
}
