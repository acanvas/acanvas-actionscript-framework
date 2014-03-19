package com.rockdot.library.util.tracker.ui {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	//==================================================================
	public class ColorSelector extends Sprite {
		
		//==================================================================
		public static const DEBUG:Boolean = true;
		
		private var bmd:BitmapData;
		private var bmp:Bitmap;
		
		//==================================================================
		public function ColorSelector( width:int=128, height:int=128, thickness:Number=24 ) {
			
			var shadowStrength:int=8;
			bmd = new BitmapData( width + shadowStrength*2, height + shadowStrength*2, true, 0);
			
			var d:Number, dx:Number, dy:Number;
			var cx:int = width*0.5;
			var cy:int = height*0.5;
			
			for(var y:int=0; y<bmd.height; y++){
				for(var x:int=0; x<bmd.width; x++) {
					
					dx = x-cx;
					dy = y-cy;
					d = Math.sqrt( dx*dx + dy*dy );
					if(d<cx)	bmd.setPixel32( shadowStrength+x, shadowStrength+y, getColorAt(x,y) );
				}
			}
			
			var rect:Rectangle = bmd.rect;
			var tl:Point = rect.topLeft;
			bmd.applyFilter( bmd, rect, tl, new GlowFilter(0xFFFFFF,2,4,4,5,2, true) );
			bmd.applyFilter( bmd, rect, tl, new DropShadowFilter(4,45,0,1, 8, 8, 1, 2) );
			
			bmp = new Bitmap( bmd, PixelSnapping.AUTO, true );
			addChild( bmp );
		}
		
		public function getColorAt( x:int, y:int ):int {
			var Y:Number=127;
			var Cb:Number, Cr:Number;
			var r:int, g:int, b:int;
			
			var d:Number, dx:Number, dy:Number;
			
			var cx:int = bmd.width*0.5;
			var cy:int = bmd.height*0.5;
			
			dx = x-cx;
			dy = y-cy;
			d = Math.sqrt( dx*dx + dy*dy );
			
			Cb = 255*dx/cx;
			Cr = 255*dy/cy;
			
			r = Y + 1.402*Cr;
			g = Y - 0.3441*Cb - 0.7141*Cr;
			b = Y + 1.772*Cb;
			
			if(r>255) r=255; if(r<0) r=0;
			if(g>255) g=255; if(g<0) g=0;
			if(b>255) b=255; if(b<0) b=0;
			
			return (0xff<<24) | (r<<16) | (g<<8) | b;
		}
		
		//==================================================================
		override public function toString():String {
			return "[ ColorSelector ]";
		}
		private function log( msg:Object ):void {
			if(DEBUG) trace(this+"\t"+msg);
		}
		
	}
	
}