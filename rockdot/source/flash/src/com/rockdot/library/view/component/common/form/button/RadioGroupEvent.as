package com.rockdot.library.view.component.common.form.button {
	import flash.events.Event;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class RadioGroupEvent extends Event {
		public static const BUTTON_SELECTED : String = "RadioGroupEvent.BUTTON_SELECTED";
		public var index : uint;

		public function RadioGroupEvent(type : String, index : uint, bubbles : Boolean = false, cancelable : Boolean = false) {
			this.index = index;
			super(type, bubbles, cancelable);
		}

		
		override public function clone() : Event {
			return new RadioGroupEvent(type, index, bubbles, cancelable);
		}
	}
}
