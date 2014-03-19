package com.rockdot.library.view.component.example.scrolling.scrollbars {
	import com.rockdot.library.view.component.common.scrollable.Slider;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Scrollbar3 extends Slider {
		private var _progress : Shape;
		public function Scrollbar3(orientation : String, max : Number, size : Number, pageScrollDuration : Number = 0.7) {
			super(orientation, max, size, pageScrollDuration);
			
			var g : Graphics;
			
			// Draw background
			_background = new Sprite();
			g = _background.graphics;
			g.beginFill(0xAAAAAA);
			if (orientation == Orientation.HORIZONTAL) {
				g.drawRect(0, 0, _size, 10);
			} else {
				g.drawRect(0, 0, 10, _size);
			}
			g.endFill();
			
			_progress = new Shape();
			
			addChild(_background);
			addChild(_progress);

			value = _max / 2;
		}

		override public function set value(value : Number) : void {
			super.value = value;
			var g : Graphics = _progress.graphics;
			g.clear();
			g.beginFill(0x3ca800);
			if (_orientation == Orientation.HORIZONTAL) g.drawRect(0, 0, _thumb.x, 10);
			else g.drawRect(0, 0, 10, _thumb.y);
			g.endFill();
		}
	}
}
