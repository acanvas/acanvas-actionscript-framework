package com.rockdot.library.view.component.example.scrolling.scrollbars {
	import com.rockdot.library.view.component.common.scrollable.Slider;
	import com.jvm.components.Orientation;

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Scrollbar4 extends Slider {
		public function Scrollbar4(orientation : String, max : Number, size : Number, pageScrollDuration : Number = 0.7) {
			super(orientation, max, size, pageScrollDuration);

			var g : Graphics;

			var pageUpBtn : Sprite = new Sprite();
			g = pageUpBtn.graphics;
			g.beginFill(0x555555);
			g.drawRect(0, 0, 20, 20);
			g.endFill();
			pageUpBtn.addEventListener(MouseEvent.CLICK, _onPageUpBtnClicked, false, 0, true);
			addChild(pageUpBtn);

			var pageDownBtn : Sprite = new Sprite();
			g = pageDownBtn.graphics;
			g.beginFill(0x555555);
			g.drawRect(0, 0, 20, 20);
			g.endFill();
			pageDownBtn.addEventListener(MouseEvent.CLICK, _onPageDownBtnClicked, false, 0, true);
			addChild(pageDownBtn);

			// Draw thumb
			_thumb = new Sprite();
			g = _thumb.graphics;
			g.beginFill(0x333333);
			g.drawRoundRect(0, 0, 20, 20, 15, 15);
			g.endFill();

			// Draw background
			_background = new Sprite();
			g = _background.graphics;
			g.beginFill(0xAAAAAA);
			if (orientation == Orientation.HORIZONTAL) {
				g.drawRect(0, 0, _size, 10);
				_background.y = 5;
				pageUpBtn.x = _size + 2;
				pageDownBtn.x = pageUpBtn.x + pageUpBtn.width + 2;
			} else {
				g.drawRect(0, 0, 10, _size);
				_background.x = 5;
				pageUpBtn.y = _size + 2;
				pageDownBtn.y = pageUpBtn.y + pageUpBtn.height + 2;
			}
			g.endFill();

			addChild(_background);
			addChild(_thumb);
		}


		private function _onPageUpBtnClicked(event : MouseEvent) : void {
			value -= 1;
		}


		private function _onPageDownBtnClicked(event : MouseEvent) : void {
			value += 1;
		}
	}
}
