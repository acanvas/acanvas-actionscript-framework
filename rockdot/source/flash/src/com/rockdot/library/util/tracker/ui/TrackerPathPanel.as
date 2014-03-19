/**
* ...
* @author Default
* @version 0.1
*/

package com.rockdot.library.util.tracker.ui {
	import fl.controls.CheckBox;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	

	public class TrackerPathPanel extends Sprite {
		
		private var bmp:Bitmap;
		private var bmd:BitmapData;
		private var colorTrans:ColorTransform;
		private var blurFilter:BlurFilter;
		private var connectCheckBox:CheckBox;
		private var mirrorCheckBox:CheckBox;
		
		private var oldPos:Point;
		private var srcScaleX:Number;
		private var srcScaleY:Number;
		
		public function TrackerPathPanel( width:int, height:int, srcWidth:int, srcHeight:int ) {
			super();
			
			srcScaleX = 1.0*width/srcWidth;
			srcScaleY = 1.0*height/srcHeight;
			
			colorTrans = new ColorTransform(1.0125, 1.0125, 1.0125, 1, 1,1,1, 0);
			blurFilter = new BlurFilter(2,2,2);
			
			oldPos = new Point( width>>1, height>>1 );
			
			bmd = new BitmapData( width, height, true, 0xFFFFFFFF );
			
			bmp = new Bitmap( bmd, PixelSnapping.AUTO, true );
			addChild( bmp );
			
			connectCheckBox = new CheckBox();
			connectCheckBox.setStyle( "textFormat", StandardTxt.defTextFormat );
			connectCheckBox.textField.autoSize = TextFieldAutoSize.LEFT;
			connectCheckBox.selected = true;
			connectCheckBox.label = "connect nodes";
			connectCheckBox.x = bmp.x - 4;
			connectCheckBox.y = bmp.y + bmp.height;
			addChild( connectCheckBox );
			
			mirrorCheckBox = new CheckBox();
			mirrorCheckBox.setStyle( "textFormat", StandardTxt.defTextFormat );
			mirrorCheckBox.textField.autoSize = TextFieldAutoSize.LEFT;
			mirrorCheckBox.selected = false;
			mirrorCheckBox.label = "mirror output";
			mirrorCheckBox.x = connectCheckBox.x;
			mirrorCheckBox.y = connectCheckBox.y +connectCheckBox.height;
			mirrorCheckBox.addEventListener( Event.CHANGE, mirrorChangeHandler );
			addChild( mirrorCheckBox );
		}
		
		public function addNode( srcPoint:Point ):void {
			bmd.lock();
			
			//bmd.applyFilter( bmd, bmd.rect, bmd.rect.topLeft, blurFilter );
			bmd.colorTransform( bmd.rect, colorTrans );
			
			var p:Point = srcPoint.clone();
			p.x *= srcScaleX;
			p.y *= srcScaleY;
			
			if(mirrorCheckBox.selected) {
				p.x = bmd.width-p.x;
			}
			
			// connect
			if(connectCheckBox.selected){
				var dx:int = p.x - oldPos.x;
				var dy:int = p.y - oldPos.y;
				
				var d:int = Point.distance(p, oldPos);
				var q:Number;
				
				for(var i:int=0; i<d; i++) {
					q = 1.0*i/d;
					bmd.setPixel32( oldPos.x+q*dx, oldPos.y+q*dy, 0xFF333333 );
				}
			}
			
			bmd.setPixel32( p.x-1, p.y, 0xFFFF6666 );
			bmd.setPixel32( p.x+1, p.y, 0xFFFF6666 );
			
			bmd.setPixel32( p.x, p.y, 0xFFFF0000 );
			
			bmd.setPixel32( p.x, p.y-1, 0xFFFF6666 );
			bmd.setPixel32( p.x, p.y+1, 0xFFFF6666 );
			
			bmd.unlock();
			
			oldPos.x = p.x;
			oldPos.y = p.y;
		}
		
		private function mirrorChangeHandler( evt:Event ):void {
			bmd.fillRect(bmd.rect, 0xFFFFFFFFF);
			oldPos.x = bmd.width-oldPos.x;
		}
		
	}
	
}
