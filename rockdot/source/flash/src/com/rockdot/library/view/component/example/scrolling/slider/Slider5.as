package com.rockdot.library.view.component.example.scrolling.slider {
	import com.rockdot.library.view.component.common.scrollable.Slider;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Sprite;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Slider5 extends Slider {
		public function Slider5(orientation : String, min : Number, max : Number, size : Number, continuous : Boolean = false) {
			super(orientation, min, max, size, continuous);

			var g : Graphics;

			// Draw thumb
			_thumb = new Sprite();
			g = _thumb.graphics;
			g.beginFill(0x333333);
			if (orientation == Orientation.HORIZONTAL) {
				g.drawRect(0, 0, 2, 20);
			} else {
				g.drawRect(0, 0, 20, 2);
			}
			g.endFill();

			// Draw background
			_background = new Sprite();
			g = _background.graphics;
			g.beginFill(0xAAAAAA);
			var i : int;
			if (orientation == Orientation.HORIZONTAL) {
				g.drawRect(0, 0, _size, 10);
				_background.y = 5;
				graphics.beginFill(0xFF0000);
				for (i = 0; i <= _max; i++) {
					graphics.drawRect((_size - 2) * (i/_max), 0, 2, 10);
				}
			} else {
				g.drawRect(0, 0, 10, _size);
				_background.x = 5;
				graphics.beginFill(0xFF0000);
				for (i = 0; i <= _max; i++) {
					graphics.drawRect(0, (_size - 2) * (i/_max), 10, 2);
				}
			}
			g.endFill();

			addChild(_background);
			addChild(_thumb);
		}
	}
}
