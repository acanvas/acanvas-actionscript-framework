package com.rockdot.library.view.component.common.scrollable {
	import com.greensock.TweenMax;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class DefaultScrollbar extends Scrollbar {
		public function DefaultScrollbar(orientation : String, max : Number, size : Number, pageJumpDuration : Number = 0.7) {

			// Draw thumb
			_thumb = new Sprite();
			var g : Graphics;
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
		
		
		override public function render() : void {
			var g : Graphics;
			g = _background.graphics;
			g.beginFill(0xAAAAAA, 0);
			if (_orientation == Orientation.HORIZONTAL) {
				g.drawRect(0, 0, size, 5);
				_background.y = 2;
			} else {
				g.drawRect(0, 0, 5, size);
				_background.x = 2;
			}
			g.endFill();
			
			super.render();
			
		}


		override public function set enabled(value : Boolean) : void {
			super.enabled = value;
			if (_enabled) TweenMax.to(this, 0.2, {autoAlpha:1});
			else TweenMax.to(this, 0.2, {autoAlpha:0});
		}
	}
}
