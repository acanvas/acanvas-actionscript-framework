package com.rockdot.library.util.tracker.events {
	import flash.events.Event;
	
	public class ColorPanelEvent extends Event {
		
		public static const COLOR_SELECTED:String = "colorSelected";
		
		public var color:int;
		
		public function ColorPanelEvent(type:String = "colorSelected", color:int=0 ) {
			super(type);
			this.color = color;
		}
		
	}
	
}