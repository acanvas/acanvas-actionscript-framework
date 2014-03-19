package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCItemContainerRoleVO extends RockdotVO {
		public var id:int;
		public var container_id:int;
		public var uid:String;
		public var role:int; //0:owner, 1:participant, 2:follower
		public var timestamp:String;

		public function UGCItemContainerRoleVO(obj : Object = null) {
			super(obj);
		}
	}
}

