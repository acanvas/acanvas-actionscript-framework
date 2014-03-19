package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCVideoItemVO extends RockdotVO {
		public var id:int;
		public var w:int;
		public var h:int;
		public var length:int;
		
		public var url:String;
		public var url_thumb:String;
		public var timestamp:String;
		
		public function UGCVideoItemVO(obj : Object = null) {
			super(obj);
		}
	}
}

