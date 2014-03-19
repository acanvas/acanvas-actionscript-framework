/*
 * Copyright 2007-2008 (c) Benjamin Bojko, bbojko.de
 *
 * This Code may be used under the conditions of the Creative
 * Commons Public License "Attribution-NonCommercial 3.0 Unported"
 * and thereby may be used, modified and extended for non
 * commercial purposes.
 * 
 * More information at:
 * http://creativecommons.org/licenses/by-nc/3.0/legalcode
 * 
 */

package com.rockdot.library.util.tracker.histogramm {
	import flash.display.BitmapData;
	

	public class ChannelHistogramm extends AbstractHistogramm {
		
		//==================================================================
		public static const CHANNEL_ALPHA:int = 24;
		public static const CHANNEL_RED:int = 16;
		public static const CHANNEL_GREEN:int = 8;
		public static const CHANNEL_BLUE:int = 0;
		
		//==================================================================
		protected var _channel:int;
		protected var _mask:int;
		
		//==================================================================
		/**
		 * 
		 * @param	bmd
		 * @param	channel
		 * @param	ommitMax
		 */
		public function ChannelHistogramm( bmd:BitmapData, channel:int=0, ommitMax:Boolean=false ) {
			super( bmd, 256, ommitMax );
			
			_channel = channel;
			_mask = 0xFF << _channel;
		}
		
		override protected function updateValues():void {
			var index:int;
			var w:int = _bmd.width;
			var h:int = _bmd.height;
			
			for(var y:int=0; y<h; y++) {
				for(var x:int=0; x<w; x++) {
					index = (_bmd.getPixel32(x,y) & _mask) >> _channel;
					_values[index]++;
				}
			}
		}
		
		//==================================================================
		public function get channel():int	{		return _channel;	}
		public function set channel( c:int ):void	{	_channel=c;		}
		
		//==================================================================
		override public function toString():String {
			return "[ BmdChannelHistogramm ]";
		}
	}
}