package com.rockdot.library.view.component.common.form.button {
	import com.rockdot.library.view.component.common.box.VBox;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class RadioGroupV extends VBox {
		protected var _orientation : String;
		protected var _selectedButtonIndex : uint;

		public function RadioGroupV(padding : uint = 0) {
			super(padding);
			addEventListener(ToggleButtonEvent.TOGGLE, _onBtnToggle, true, 0, true);
		}


		public function selectButton(index : uint) : void {
			RadioButton(getChildAt(_selectedButtonIndex)).isToggled = false;
			RadioButton(getChildAt(index)).isToggled = true;
			_selectedButtonIndex = index;
			dispatchEvent(new RadioGroupEvent(RadioGroupEvent.BUTTON_SELECTED, index));
		}


		private function _onBtnToggle(event : ToggleButtonEvent) : void {
			var btn : RadioButton = RadioButton(event.target);
			if (!btn.isToggled) selectButton(getChildIndex(btn));
		}


		public function get selectedButtonIndex() : uint {
			return _selectedButtonIndex;
		}


		override public function destroy() : void {
			removeEventListener(ToggleButtonEvent.TOGGLE, _onBtnToggle);
			super.destroy();
		}
	}
}
