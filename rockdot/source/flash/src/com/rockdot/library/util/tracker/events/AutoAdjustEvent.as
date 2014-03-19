/**
* ...
* @author Default
* @version 0.1
*/

package com.rockdot.library.util.tracker.events {
	import flash.events.Event;
	

	public class AutoAdjustEvent extends Event {
		
		public static const ADJUST:String = "adjust";
		
		public function AutoAdjustEvent( type:String=ADJUST ) {
			super( type );
		}
		
	}
	
}
