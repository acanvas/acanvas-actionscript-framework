package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCImageItemVO extends RockdotVO {
		public var id:int;
		public var w:int;
		public var h:int;
		
		public var url_big:String;
		public var url_thumb:String;
		public var timestamp:String;

		public function UGCImageItemVO(obj : Object = null) {
			super(obj);
		}
	}
}

