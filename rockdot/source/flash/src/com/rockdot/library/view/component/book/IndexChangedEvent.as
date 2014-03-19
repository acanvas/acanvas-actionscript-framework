package com.rockdot.library.view.component.book {
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * @author nilsdoehring
	 */
	public class IndexChangedEvent extends Event{
		public static const CHANGE : String = "IndexChangeEvent.CHANGE";
		public var oldIndex : uint;
		public var newIndex : uint;
		public var relatedObject : Sprite;

		public function IndexChangedEvent(change : String) {
			super(change);
		}
	}
}
