package com.rockdot.plugin.ugc.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author nilsdoehring
	 */
	public class UGCItemVO extends RockdotVO {
		public static const TYPE_TEXT : int = 0;
		public static const TYPE_IMAGE : int = 1;
		public static const TYPE_VIDEO : int = 2;
		public static const TYPE_AUDIO : int = 3;
		public static const TYPE_LINK : int = 4;
		public var id : int;
		public var container_id : int;
		public var creator_uid : String;
		// assembled in AMF Endpoint via uid relation
		public var creator : UGCUserVO;
		public var title : String;
		public var description : String;
		public var like_count : Number = 0;
		public var complain_count : int = 0;
		public var flag : int = 0;
		// 0: not blocked, 1: blocked
		public var timestamp : String;
		public var type : int;
		// 0:text, 1:image, 2:video, 3:audio, 4:link
		public var type_id : int;
		// assembled in AMF Endpoint via type_id relation
		public var type_dao : RockdotVO;
		// assembled in AMF Endpoint by counting array index
		public var rowindex : int;
		// assembled in AMF Endpoint via supersmart extra query
		public var totalrows : String;
		// optionally loaded via command
		public var likers : Array;

		public function UGCItemVO(obj : Object = null) {
			if (obj && obj.creator) {
				creator = new UGCUserVO(obj.creator);
				delete obj.creator;
			}

			super(obj);

			if (type_id) {
				switch(type) {
					case 0:
						type_dao = new UGCTextItemVO(obj);
						break;
					case 1:
						type_dao = new UGCImageItemVO(obj);
						break;
					case 2:
						type_dao = new UGCVideoItemVO(obj);
						break;
					case 3:
						type_dao = new UGCAudioItemVO(obj);
						break;
					case 4:
						// type_dao = obj;
						break;
				}
			}
			var prop : String;
			if (likers) {
				for (prop  in  likers) {
					likers[prop] = new UGCUserVO(likers[prop]);
				}
			}
		}
	}
}

