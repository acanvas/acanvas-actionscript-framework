package com.rockdot.library.view.component.common.form.button {
	import flash.events.MouseEvent;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ToggleButton extends Button {
		protected var _isToggled : Boolean;

		public function ToggleButton() {
			super();
		}


		override protected function _onClick(event : MouseEvent) : void {
			isToggled = !_isToggled;
			super._onClick(event);
		}


		public function get isToggled() : Boolean {
			return _isToggled;
		}


		public function set isToggled(value : Boolean) : void {
			_isToggled = value;
			dispatchEvent(new ToggleButtonEvent(ToggleButtonEvent.TOGGLE, _isToggled));
		}
	}
}
