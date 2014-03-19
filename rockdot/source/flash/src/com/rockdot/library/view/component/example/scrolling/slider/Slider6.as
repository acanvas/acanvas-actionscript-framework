package com.rockdot.library.view.component.example.scrolling.slider {
	import com.rockdot.library.view.component.common.scrollable.Slider;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Sprite;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Slider6 extends Slider {
		public function Slider6(orientation : String, min : Number, max : Number, size : Number, continuous : Boolean = false) {
			size -= 20;
			super(orientation, min, max, size, continuous);
			

			var g : Graphics;

			// Draw thumb
			_thumb = new Sprite();
			g = _thumb.graphics;
			g.beginFill(0xEEEEEE);
			if (orientation == Orientation.HORIZONTAL) {
				g.drawRoundRect(0, 0, 80, 16, 20);
				_thumb.y = 2;
			} else {
				g.drawRoundRect(0, 0, 16, 80, 20);
				_thumb.x = 2;
			}
			g.endFill();

			// Draw background
			_background = new Sprite();
			if (orientation == Orientation.HORIZONTAL) {
				g = graphics;
				g.beginFill(0x444444);
				g.drawRect(0, 0, _size + 20, 20);
				g.beginFill(0xBBBBBB);
				g.drawRoundRect(10, 2, _size, 16, 20);
				
				g = _background.graphics;
				g.beginFill(0xFF0000, 0);
				g.drawRect(0, 0, _size, 20);
				
				_background.x = 10;
			} else {
				g = graphics;
				g.beginFill(0x444444);
				g.drawRect(0, 0, 20, _size + 20);
				g.beginFill(0xBBBBBB);
				g.drawRoundRect(2, 10, 16, _size, 20);
				
				g = _background.graphics;
				g.beginFill(0xFF0000, 0);
				g.drawRect(0, 0, 20, _size);
				
				_background.y = 10;
			}
			
			
			g.endFill();

			addChild(_background);
			addChild(_thumb);
		}
	}
}
