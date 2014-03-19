package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCItemContainerVO extends RockdotVO {
		public var id : int;
		public var parent_container_id : int;
		public var privacy_level : int;
		
		public var creator_uid : String;
		// assembled in AMF Endpoint via uid relation
		public var creator : UGCUserVO;
		public var title : String;
		public var description : String;
		public var like_count : Number = 0;
		public var complain_count : int = 0;
		public var flag : int = 0;
		// 0: not blocked, 1: blocked
		// calculated extras (calculated in SQL query)
		public var rowindex : int;
		public var totalrows : String;
		// (assembled in AMF Endpoint via container_id relation in itemcontainer_roles table)
		public var roles : Array;
		// (assembled in AMF Endpoint via container_id relation in items table)
		public var items : Array;
		// (assembled in AMF Endpoint via task_id relation in itemcontainer_tasks crosstable)
		public var task : UGCTaskVO;

		public function UGCItemContainerVO(obj : Object = null) {
			if (obj.creator) {
				creator = new UGCUserVO(obj.creator);
				delete obj.creator;
			}

			if (obj.task) {
				task = new UGCTaskVO(obj.task);
				delete obj.task;
			}
			
			super(obj);

			var prop : String;
			if (roles) {
				for (    prop in  roles) {
					roles[prop] = new UGCItemContainerRoleVO(roles[prop]);
				}
			}

			if (items) {
				for (prop  in  items) {
					items[prop] = new UGCItemVO(items[prop]);
				}
			}
		}
	}
}

