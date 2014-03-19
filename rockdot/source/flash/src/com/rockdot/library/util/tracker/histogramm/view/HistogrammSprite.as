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

package com.rockdot.library.util.tracker.histogramm.view {
	import com.rockdot.library.util.tracker.histogramm.AbstractHistogramm;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	

	public class HistogrammSprite extends Sprite {
		
		//==================================================================
		
		//==================================================================
		private var histogramm:AbstractHistogramm;
		private var bmd:BitmapData;
		private var bmp:Bitmap;
		private var disabledBmp:Bitmap;
		
		//==================================================================
		public function HistogrammSprite( histogramm:AbstractHistogramm, width:int=256, height:int=128 ) {
			this.histogramm = histogramm;
			bmd = new BitmapData(width, height, false);
			bmp = new Bitmap( bmd );
			
			disabledBmp = new Bitmap( new BitmapData(width,height,true,0x99DDDDDD));
			enabled = true;
			
			addChild(bmp);
			addChild(disabledBmp);
		}
		
		public function update():void {
			if(!enabled) return;
			
			var xMultiplier:Number = histogramm.resolution / bmd.width;
			var yMultiplier:Number = bmd.height / histogramm.maxValue;
			
			var pos:int;
			var rect:Rectangle = new Rectangle(0,0,1,0);
			
			bmd.lock();
			
			bmd.fillRect( bmd.rect, 0xFFFFFF );
			
			for(var i:int=0; i<bmd.width; i++) {
				pos = Math.floor( i * xMultiplier );
				
				rect.height = histogramm.values[ pos ] * yMultiplier;
				rect.x = i;
				rect.y = bmd.height - rect.height;
				
				bmd.fillRect( rect, 0x000000 );
			}
			
			bmd.unlock();
		}
		
		public function set enabled( b:Boolean ):void {
			disabledBmp.visible = !b;
			update();
		}
		public function get enabled():Boolean {
			return !disabledBmp.visible;
		}
		
		//==================================================================
		
		//==================================================================
		public override function toString():String {
			return "[ HistogrammSprite ]";
		}
		
		//==================================================================
	}
	
}