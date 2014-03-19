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
 * abstract class adding color related members
 * 
 * @author Benjamin Bojko
 * @version 0.1
 */

package com.rockdot.library.util.tracker {
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	
	public class AbstractColorTracker extends AbstractTracker {
		
		//==================================================================
		protected var _color:int=0;
		protected var colorR:int,	colorG:int,		colorB:int;
		protected var /*colorY:int,*/	colorCb:int,	colorCr:int;
		
		protected var _maxWidth:int = 128;
		protected var _maxHeight:int = 128;
		
		protected var _minPixelsFound:int = 8;
		
		//==================================================================
		public function AbstractColorTracker( bmd:BitmapData ) {
			super(bmd);
		}
		
		//==================================================================
		/**
		 * tracks color at the giben position
		 * @param	pos
		 * @param	color
		 */
		public function trackColor( pos:Point, color:int ):void {
			super.track(pos);
			this.color = color;
		}
		/**
		 * tracks color at the given position
		 * @param	pos
		 */
		override public function track( pos:Point ):void {
			trackColor(pos, _bmd.getPixel(pos.x, pos.y) );
		}
		/**
		 * tracks average of all colors within radius
		 * @param	pos
		 * @param	radius
		 */
		override public function trackArea( pos:Point, radius:uint=3 ):void {
			super.trackArea(pos, radius);
			
			var c:uint, r:uint=0, g:uint=0, b:uint=0;
			var dx:Number, dy:Number, dSq:Number;
			var pxFound:uint=0;
			
			var radiusSq:uint = radius*radius;
			
			var w:uint = radius << 1;
			var h:uint = radius << 1;
			
			for( var y:int=0; y<h; y++ ){
				for( var x:int=0; x<w; x++ ){
					dx = x-radius;
					dy = y-radius;
					dSq = dx*dx + dy*dy;
					
					if(dSq > radiusSq) continue;
					
					c = _bmd.getPixel32( pos.x+x, pos.y+y );
					r += (0xFF0000 & c) >> 16;
					g += (0xFF00 & c) >> 8;
					b += (0xFF & c);
					
					pxFound++;
				}
			}
			
			r /= pxFound;
			g /= pxFound;
			b /= pxFound;
			
			_color = 0xFF<<24 | r<<16 | g<<8 | b;
		}
		
		//==================================================================
		public function get color():int		{	return _color;			}
		public function get maxWidth():int {	return _maxWidth;		}
		public function get maxHeight():int {	return _maxHeight;		}
		public function get minPixelsFound():int {	return _minPixelsFound;		}
		
		public function set maxWidth( _maxWidth:int ):void	{	this._maxWidth = _maxWidth;		}
		public function set maxHeight( _maxHeight:int ):void	{	this._maxHeight = _maxHeight;		}
		public function set minPixelsFound( _minPixelsFound:int ):void	{	this._minPixelsFound = _minPixelsFound;		}
		public function set color( c:int ):void	{
			_color = c;
			colorR = (c & 0xFF0000) >> 16;
			colorG = (c & 0x00FF00) >> 8;
			colorB = c & 0x0000FF;
			
			colorCb = -0.168736*colorR - 0.331264*colorG + 0.5*colorB;
			colorCr = 0.5*colorR - 0.418688*colorG - 0.081312*colorB;
		}
		
		//==================================================================
		public override function toString():String {
			return "[ AbstractColorTracker ]";
		}
	}
	
}