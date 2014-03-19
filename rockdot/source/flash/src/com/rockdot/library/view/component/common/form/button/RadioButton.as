package com.rockdot.library.view.component.common.form.button {
	import flash.events.MouseEvent;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class RadioButton extends ToggleButton {
		public function RadioButton() {
			super();
		}


		override protected function _onClick(event : MouseEvent) : void {
			dispatchEvent(new ToggleButtonEvent(ToggleButtonEvent.TOGGLE));
		}


		override public function set isToggled(value : Boolean) : void {
			_isToggled = value;
		}
	}
}
