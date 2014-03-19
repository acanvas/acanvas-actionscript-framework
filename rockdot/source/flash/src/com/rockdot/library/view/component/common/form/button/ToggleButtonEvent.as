package com.rockdot.library.view.component.common.form.button {
	import flash.events.Event;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ToggleButtonEvent extends Event {
		public static const TOGGLE : String = "ToggleButtonEvent.TOGGLE";

		public function ToggleButtonEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}


		override public function clone() : Event {
			return new ToggleButtonEvent(type, bubbles, cancelable);
		}
	}
}
