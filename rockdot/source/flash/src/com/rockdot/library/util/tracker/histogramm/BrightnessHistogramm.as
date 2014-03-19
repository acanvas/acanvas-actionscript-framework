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
	

	public class BrightnessHistogramm extends AbstractHistogramm {
		
		//==================================================================
		/**
		 * 
		 * @param	bmd
		 * @param	channel
		 * @param	ommitMax
		 */
		public function BrightnessHistogramm( bmd:BitmapData, ommitMax:Boolean=false ) {
			super( bmd, 256, ommitMax );
			
			/*var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(256,1);
			s.graphics.beginGradientFill(GradientType.LINEAR, [0,0xffffff],[100,100], [0,255], m);
			s.graphics.drawRect( 0,0, 256,1 );
			
			_bmd = new BitmapData(256,1);
			_bmd.draw(s);*/
		}
		//==================================================================
		override protected function updateValues():void {
			var c:int, r:int, g:int, b:int;
			var index:int;
			var w:int = _bmd.width;
			var h:int = _bmd.height;
			
			for(var y:int=0; y<h; y++) {
				for(var x:int=0; x<w; x++) {
					c = _bmd.getPixel32(x,y);
					r = (c & 0xFF0000)>>16;
					g = (c & 0xFF00)>>8;
					b = (c & 0xFF);
					
					index = (r + (g<<1) + b) >> 2;	// ==> (1*r + 2*g + 1*b) / 4
					//index = (r+g+b)/3;
					_values[index]++;
				}
			}
		}
		//==================================================================
		override public function toString():String {
			return "[ BrightnessHistogramm ]";
		}
	}
}