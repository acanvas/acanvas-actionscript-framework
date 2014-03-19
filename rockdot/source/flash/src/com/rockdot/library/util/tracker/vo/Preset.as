/**
* @author Benjamin Bojko
* @version 0.1
*/

package com.rockdot.library.util.tracker.vo {

	public class Preset {
		
		//==================================================================
		public static const PRESETS:Array = [
			new Preset("Really Dark Lighting", 9, 20, 0x564252),
			new Preset("Dark Lighting", 15, 8, 0x52322C),
			new Preset("Medium Lighting", 5, 24, 0x5C4F4B, 16),
			new Preset("Daylight", 5, 24, 0xBD907D),
			new Preset("Kinect Depth Blue Channel", 2, 24, 0x0000fb, 8)
		];
		public static const DEFAULT_ID:uint = 3;
		
		private static var numPresets:int=0;
		
		//==================================================================
		public var label:String;
		public var data:Object;
		public var icon:Object;
		
		public var trackerSize:int;
		public var tolerance:int;
		public var minPixelsFound:int;
		
		public var color:int;
		
		//==================================================================
		public function Preset( label:String=null, tolerance:int=15, minPixelsFound:int=4, color:int=0x52322C, trackerSize:int=64 ) {
			if(label==null) label = "Preset "+numPresets;
			numPresets++;
			
			this.label = label;
			this.tolerance = tolerance;
			this.minPixelsFound = minPixelsFound;
			this.color = color;
			this.trackerSize = trackerSize;
		}
		
		public function toString():String {
			return label;
		}
	}
	
}
