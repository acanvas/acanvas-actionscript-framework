package com.rockdot.plugin.ugc.model.vo {

	/**
	 * @author nilsdoehring
	 */
	public class UGCTaskVO extends UGCItemContainerVO {
		
		public var category_id:int;
		public var task_key:String;
		
		//type: 0:text, 1:image, 2:video, 3:audio, 4:link
		public var type:int;
		
		//extras (assembled in AMF Endpoint via category_id relation)
		public var category_key:String;

		public function UGCTaskVO(obj : Object = null) {
			super(obj);
		}
	}
}

