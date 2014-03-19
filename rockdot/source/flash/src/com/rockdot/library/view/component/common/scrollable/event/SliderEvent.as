package com.rockdot.library.view.component.common.scrollable.event {
	import flash.events.Event;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class SliderEvent extends Event {
		public static const VALUE_CHANGE : String = "SliderEvent.VALUE_CHANGE";
		public static const CHANGE_START : String = "SliderEvent.CHANGE_START";
		public static const CHANGE_END : String = "SliderEvent.CHANGE_END";
		//
		public static const INTERACTION_START : String = "SliderEvent.INTERACTION_START";
		public static const INTERACTION_END : String = "SliderEvent.INTERACTION_END";
		public static const MOMENTUM_START : String = "SliderEvent.MOMENTUM_START";
		public static const MOMENTUM_END : String = "SliderEvent.MOMENTUM_END";
		public var value : Number;

		public function SliderEvent(type : String, value : Number, bubbles : Boolean = false, cancelable : Boolean = false) {
			this.value = value;
			super(type, bubbles, cancelable);
		}


		override public function clone() : Event {
			return new SliderEvent(type, value, bubbles, cancelable);
		}
	}
}
