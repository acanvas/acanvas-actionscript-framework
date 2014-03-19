package com.rockdot.library.view.component.example.scrolling {
	import com.rockdot.library.view.component.common.scrollable.Scrollbar;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Sprite;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class MyScrollbar extends Scrollbar {
		public function MyScrollbar(orientation : String, max : Number, size : Number, pageJumpDuration : Number = 0.7) {
			size -= 20;
			var g : Graphics;

			// Draw thumb
			_thumb = new Sprite();
			g = _thumb.graphics;
			g.beginFill(0x333333);
			g.drawRect(0, 0, 9, 9);
			g.endFill();

			// Draw background
			_background = new Sprite();
			g = _background.graphics;
			g.beginFill(0xAAAAAA);
			if (orientation == Orientation.HORIZONTAL) {
				g.drawRect(0, 0, size, 5);
				_background.y = 2;
				x += 10;
			} else {
				g.drawRect(0, 0, 5, size);
				_background.x = 2;
				y += 10;
			}
			g.endFill();
			addChild(_background);
			addChild(_thumb);

			super(orientation, max, size, pageJumpDuration);
			pages = 3;
		}
		
		
		override public function set enabled(value : Boolean) : void {
			super.enabled = value;
			visible = _enabled;
		}
	}
}
