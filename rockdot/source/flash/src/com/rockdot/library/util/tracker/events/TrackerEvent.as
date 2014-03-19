package com.rockdot.library.util.tracker.events {
	import flash.events.Event;
	
	public class TrackerEvent extends Event {
		
		public static const ON_RESIZE_EVENT:String = "onResizeEvent";
		
		public var width:int;
		public var height:int;
		
		public function TrackerEvent(type:String, width:int=0, height:int=0 ) {
			super(type);
			this.width = width;
			this.height = height;
		}
		
	}
	
}