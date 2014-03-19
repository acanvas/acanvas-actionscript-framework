package com.rockdot.library.view.component.example.scrolling.scrollbars {
	import com.rockdot.library.view.component.common.scrollable.Scrollbar;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Sprite;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Scrollbar2 extends Scrollbar {
		public function Scrollbar2(orientation : String, max : Number, size : Number, pageScrollDuration : Number = 0.7) {
			super(orientation, max, size, pageScrollDuration);
			
			var g : Graphics;
			
			// Draw thumb
			_thumb = new Sprite();
			g = _thumb.graphics;
			
			g.beginFill(0x0, 0);
			g.drawCircle(10, 10, 10);
			g.beginFill(0x333333);
			g.drawCircle(10, 10, 10);
			g.drawCircle(10, 10, 7);
			g.beginFill(0xFF0000);
			g.drawCircle(10, 10, 3);
			g.drawCircle(10, 10, 2);
			g.endFill();
			
			// Draw background
			_background = new Sprite();
			g = _background.graphics;
			if (orientation == Orientation.HORIZONTAL) {
				g.beginFill(0x0, 0);
				g.drawRect(0, 0, _size, _thumb.height);
				g.beginFill(0xAAAAAA);
				g.drawRect(10, 9, _size - 20, 2);
			} else {
				g.beginFill(0x0, 0);
				g.drawRect(0, 0, _thumb.width, _size);
				g.beginFill(0xAAAAAA);
				g.drawRect(9, 10, 2, _size - 20);
			}
			g.endFill();
			
			addChild(_background);
			addChild(_thumb);
		}
	}
}
