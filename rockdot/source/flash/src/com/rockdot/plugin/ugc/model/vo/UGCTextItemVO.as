package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCTextItemVO extends RockdotVO {
		public var id:int;
		public var text:String;

		public function UGCTextItemVO(obj : Object = null) {
			super(obj);
		}
	}
}

