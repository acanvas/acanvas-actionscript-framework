package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCAudioItemVO extends RockdotVO {
		public var id:int;
		public var url:String;
		public var length:int;

		public function UGCAudioItemVO(obj : Object = null) {
			super(obj);
		}
	}
}

