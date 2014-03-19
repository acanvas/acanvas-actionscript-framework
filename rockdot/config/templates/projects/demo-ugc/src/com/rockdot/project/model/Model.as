package com.rockdot.project.model {
	import com.rockdot.plugin.ugc.model.vo.UGCItemContainerVO;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;
	import com.rockdot.project.view.element.editor.IAMLogoEditor;

	import flash.display.Bitmap;



	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class Model  {
		private var _ownAlbum : UGCItemContainerVO;
		private var _loadedAlbum : UGCItemContainerVO;
		private var _state : String;
		private var _newTaskID : int;
		
		private var _currentUGCItem : UGCItemVO;

		public var iamtype : int;
		public var iamline : String;
		public var quote : IAMLogoEditor;
		
		public function Model() {
		}

		private var _image : Bitmap;
		public function get image() : Bitmap {
			return _image;
		}
		public function set image(image : Bitmap) : void {
			_image = image;
		}

		public function set state(newState : String) : void {
			_state = newState;
		}

		public function get newMission() : UGCItemContainerVO {
			return _ownAlbum;
		}

		public function set newMission(newMission : UGCItemContainerVO) : void {
			_ownAlbum = newMission;
		}

		public function get loadedMission() : UGCItemContainerVO {
			return _loadedAlbum;
		}

		public function set loadedMission(loadedAlbum : UGCItemContainerVO) : void {
			_loadedAlbum = loadedAlbum;
		}

		public function get state() : String {
			return _state;
		}

		public function set newTaskID(newNewTaskID : int) : void {
			_newTaskID = newNewTaskID;
		}

		public function get newTaskID() : int {
			return _newTaskID;
		}

		public function get currentUGCItem() : UGCItemVO {
			return _currentUGCItem;
		}

		public function set currentUGCItem(currentUGCItem : UGCItemVO) : void {
			_currentUGCItem = currentUGCItem;
		}


	}
}
