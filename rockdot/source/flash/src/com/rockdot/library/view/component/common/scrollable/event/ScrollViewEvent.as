package com.rockdot.library.view.component.common.scrollable.event {
	import flash.events.Event;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ScrollViewEvent extends Event {
		public static const CHANGE_START : String = "ScrollViewEvent.CHANGE_START";
		public static const CHANGE_END : String = "ScrollViewEvent.CHANGE_END";
		public static const INTERACTION_START : String = "ScrollViewEvent.INTERACTION_START";
		public static const INTERACTION_END : String = "ScrollViewEvent.INTERACTION_END";

		public function ScrollViewEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}


		override public function clone() : Event {
			return new ScrollViewEvent(type, bubbles, cancelable);
		}
	}
}
