package com.rockdot.library.view.component.example.scrolling {
	import com.greensock.TweenMax;
	import com.rockdot.library.view.component.common.scrollable.Scrollbar;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class HidingScrollbar extends Scrollbar {
		public function HidingScrollbar(orientation : String, max : Number, size : Number, pageJumpDuration : Number = 0.7) {
			size -= 26;
			var g : Graphics;

			// Draw thumb
			_thumb = new Sprite();
			g = _thumb.graphics;
			g.beginFill(0xEEEEEE);
			g.drawRect(0, 0, 8, 8);
			g.drawRect(1, 1, 6, 6);
			g.beginFill(0x333333);
			g.drawRect(1, 1, 6, 6);
			g.endFill();
			
			_thumb.scale9Grid = new Rectangle(1, 1, 6, 6);

			// Draw background
			_background = new Sprite();
			addChild(_background);
			addChild(_thumb);

			super(orientation, max, size, pageJumpDuration);
		}


		override public function set enabled(value : Boolean) : void {
			super.enabled = value;
			if (_enabled) TweenMax.to(this, 0.2, {autoAlpha:1});
			else TweenMax.to(this, 0.2, {autoAlpha:0});
		}


		override public function set size(value : Number) : void {
			super.size = value;
			var g : Graphics;
			g = _background.graphics;
			g.beginFill(0xAAAAAA, 0);
			if (_orientation == Orientation.HORIZONTAL) {
				g.drawRect(0, 0, size, 5);
				_background.y = 2;
				x += 13;
			} else {
				g.drawRect(0, 0, 5, size);
				_background.x = 2;
				y += 13;
			}
			g.endFill();
		}
	}
}
