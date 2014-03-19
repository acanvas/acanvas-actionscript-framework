package com.rockdot.library.view.component.common {
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import org.bytearray.display.ScaleBitmap2;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;


	/**
	 * Copyright (c) 2010, Jung von Matt/Neckar
	 * All rights reserved.
	 */

	public class ComponentBitmapData extends SpriteComponent {
		private var _innerRect : Rectangle;
		private var _bitmapData : BitmapData;

		public function ComponentBitmapData(bitmapData : BitmapData, innerRect : Rectangle = null) {
			super();
			_bitmapData = bitmapData;
			_innerRect = innerRect;
		}

		override public function render( ):void {
			
			_innerRect ||= new Rectangle(5, 5, _bitmapData.width-10, _bitmapData.height-10);
			
			ScaleBitmap2.draw(		_bitmapData,
									 graphics,
									 _width >> 0,
									 _height >> 0,
									 _innerRect,
									 null,
									 true);

			super.render();
		}

		override public function destroy() : void {
			super.destroy();
			graphics.clear();
//			_bitmapData.dispose();
		}
	}
}
