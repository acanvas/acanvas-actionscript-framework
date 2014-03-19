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

/**
 * actual tracker. uses 2D matrix of color values (tracking area)
 * to determine in which direction the tracked object is moving
 * 
 * @author Benjamin Bojko
 * @version 0.1
 */

package com.rockdot.library.util.tracker {
	import com.rockdot.library.util.tracker.vo.Preset;

	import flash.display.BitmapData;
	import flash.geom.Point;

	
	
	public class MeanshiftTracker extends AbstractColorTracker {
		
		//==================================================================
		protected var oldPos:Point;
		protected var _motionPrediction:Boolean = true;
		
		//==================================================================
		/**
		 * color tracker with meanshift-based algorithm using
		 * chrominances in the YCbCr color space
		 * @param	bmd
		 */
		public function MeanshiftTracker( bmd:BitmapData, p : Preset = null ) {
			super(bmd);
			if(p){
				width = p.trackerSize || 64;
				height = p.trackerSize || 64;
				maxWidth = 4*bmd.width;
				maxHeight = 4*bmd.height;
				tolerance = p.tolerance;
				minPixelsFound = p.minPixelsFound;
				color = p.color || 0xBD907D;
			}
		}
		
		//==================================================================
		/**
		 * stores position and uses color of that pixel
		 * @param	pos
		 */
		override public function track(pos:Point):void {
			super.track(pos);
			oldPos = pos.clone();
		}
		
		//==================================================================
		/**
		 * modifies position relative to colors inside the tracking area
		 */
		override public function update():void {
			super.update();
			
			_status = STATUS_OK;
			
			// start values - either predicted or not
			var startX:int = (_motionPrediction) ? 2*_pos.x - oldPos.x : _pos.x;
			var startY:int = (_motionPrediction) ? 2*_pos.y - oldPos.y : _pos.y;
			
			// shift values
			var shiftX:int = 0;
			var shiftY:int = 0;
			
			//helpers
			var numPixelsFound:int = 0;
			var toleranceSq:int = _tolerance*_tolerance;
			var r:int,		g:int,		b:int,		c:int;	// red, green, blue
			var Y:Number,	Cb:Number,	Cr:Number;			// luminance, chrominance1, chrominance2
			var /*dY:Number,*/	dCb:Number,	dCr:Number;		// differences of tracker and pixel chrominances
			var dColorSq:Number;							// square distance in 2d chrominance color space
			
			// temporary tracker size (resized after each run)
			var w:int = _width;
			var h:int = _height;
			
			// keep resizing tracker until minimun px found
			while(numPixelsFound < _minPixelsFound){
			
				// border
				var top:int = startY - h*0.5;
				var bottom:int = startY + h *0.5;
				var left:int = startX - w*0.5;
				var right:int = startX + w*0.5;
				
				// stay inside bmd borders
				if(top<0) top=0;
				if(bottom>_bmd.height) bottom=_bmd.height;
				if(left<0) left=0;
				if(right>_bmd.width) right=_bmd.width;
				
				// compute pixels in tracker region
				for (var y:int=top; y<=bottom; y++) {
					for (var x:int=left; x<=right; x++) {
						
						// get rgb values
						c = _bmd.getPixel(x, y);
						r = (c & 0xFF0000) >> 16;
						g = (c & 0x00FF00) >> 8;
						b = c & 0x0000FF;
						
						// transform RGB to YCbCr to seperate chrominance and luminance
						Y = 0.299*r + 0.587*g + 0.114*b;
						Cb = -0.168736*r - 0.331264*g + 0.5*b;
						Cr = 0.5*r - 0.418688*g - 0.081312*b;
						
						// compare tracker chrominance with pixel chrominance
						dCb = colorCb-Cb;
						dCr = colorCr-Cr;
						dColorSq = dCb*dCb + dCr*dCr;
						
						// store distance from current tracker position to similar pixels
						if(dColorSq <= toleranceSq){
							shiftX += (x-_pos.x);
							shiftY += (y-_pos.y);
							
							numPixelsFound++;
						}
					}
				}
				
				//dispatchEvent( new TrackerEvent( TrackerEvent.ON_RESIZE_EVENT, w, h ) );
				
				// enlarge tracker region for next run, if not enough pixels found
				w *= 4;
				h *= 4;
				
				// stop searching when size limit reached
				if(w > _maxWidth && h > _maxHeight) {
					_status = STATUS_NOTHING_FOUND;
					break;
				}
				
			}
			
			// remember last position for motion prediction
			oldPos.x = _pos.x;
			oldPos.y = _pos.y;
			
			// add relativized sum of shift values
			if(numPixelsFound > 0) {
				_pos.x += shiftX/numPixelsFound;
				_pos.y += shiftY/numPixelsFound;
			}
			
			// stay inside bmd borders
			if(_pos.x>_bmd.width) _pos.x=_bmd.width; if(_pos.x<0) _pos.x=0;
			if(_pos.y>_bmd.height) _pos.y=_bmd.height; if(_pos.y<0) _pos.y=0;
		}
		
		//==================================================================
		public function set motionPrediction( b:Boolean ):void {	_motionPrediction=b;	}
		public function get motionPrediction():Boolean {	return _motionPrediction;	}
		
		//==================================================================
		override public function toString():String {
			return "[ MeanshiftTracker ]";
		}
	}
	
}