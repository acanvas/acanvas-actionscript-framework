package com.rockdot.library.view.component.common.form.list {
	import com.rockdot.library.view.component.common.form.button.Button;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Cell extends Button {
		public var id : int;
		protected var _data : Object;
		protected var _isSelected : Boolean;
		protected var _isMultiselection : Boolean;

		public function Cell() {
			super();
		}


		public function get data() : Object {
			return _data;
		}


		public function set data(data : Object) : void {
			_data = data;
		}

		public function select() : void {
			if (!_isSelected) {
				_isSelected = true;
				render();
				submitCallbackParams = [this];
				_onClick();
			}
		}


		public function deselect() : void {
			if (_isSelected) {
				_isSelected = false;
				render();
			}
		}


		public function get isSelected() : Boolean {
			return _isSelected;
		}

		public function get isMultiselection() : Boolean {
			return _isMultiselection;
		}

		public function set isMultiselection(isMultiselection : Boolean) : void {
			_isMultiselection = isMultiselection;
		}
	}
}
