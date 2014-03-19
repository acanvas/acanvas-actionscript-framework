/**
 * automatically adjusts tracker settings according to histogram values
 * 
 * @author Benjamin Bojko
 * @version 0.1
 */

package com.rockdot.library.util.tracker.utils {
	import com.rockdot.library.util.tracker.AbstractColorTracker;
	import com.rockdot.library.util.tracker.events.AutoAdjustEvent;
	import com.rockdot.library.util.tracker.histogramm.AbstractHistogramm;

	import flash.events.EventDispatcher;

	

	public class AutoColorAdjuster extends EventDispatcher {
		
		private var tracker:AbstractColorTracker;
		private var histogram:AbstractHistogramm;
		
		public function AutoColorAdjuster( tracker:AbstractColorTracker, histogram:AbstractHistogramm ) {
			this.tracker = tracker;
			this.histogram = histogram;
		}
		
		public function update():void {
			var offset:Number = (histogram.median/127) - 1;
			
			tracker.tolerance = 8 - 5*(offset+0.5);
			tracker.minPixelsFound = 12 + 10*offset;
			
			dispatchEvent( new AutoAdjustEvent() );
		}
		
	}
	
}
