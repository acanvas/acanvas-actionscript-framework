package com.rockdot.library.view.component.example.scrolling.slider {
	import com.rockdot.library.view.component.common.scrollable.Slider;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Slider3 extends Slider {
		private var _progress : Shape;
		public function Slider3(orientation : String, min : Number, max : Number, size : Number, continuous : Boolean = false) {
			super(orientation, min, max, size, continuous);
			
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
