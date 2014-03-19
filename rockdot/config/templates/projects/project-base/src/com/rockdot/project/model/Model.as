package com.rockdot.project.model {
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class Model {
		private var _state : String;
		private var _currentUGCItem : UGCItemVO;
		
		public function Model() {
		}


		public function set state(newState : String) : void {
			_state = newState;
		}

		public function get state() : String {
			return _state;
		}

		public function get currentUGCItem() : UGCItemVO {
			return _currentUGCItem;
		}

		public function set currentUGCItem(currentUGCItem : UGCItemVO) : void {
			_currentUGCItem = currentUGCItem;
		}
	}
}
