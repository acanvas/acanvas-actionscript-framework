package com.rockdot.library.view.component.example.button {
	import com.greensock.TweenMax;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.library.view.textfield.UITextField;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ExampleButton extends Button {
		private var _hPadding : int = 10;
		private var _vPadding : int = 5;
		private var _label : UITextField;
		private var _bg : Bitmap;

		public function ExampleButton(label : String) {
			mouseChildren = false;

			_label = new UITextField(label, new TextFormat("Arial", 12, 0xFFFFFF, true));
			_label.embedFonts = false;
			_label.wordWrap = false;
			_label.x = _hPadding;
			_label.y = _vPadding;

			// Instead of graphics.xyz
			_bg = new Bitmap(new BitmapData(_label.width + 2 * _hPadding, _label.height + 2 * _vPadding, false, 0x0));
			_bg.bitmapData.fillRect(_bg.bitmapData.rect, 0x999999);

			addChild(_bg);
			addChild(_label);

			addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);

			super();
		}


		private function _onMouseDown(event : MouseEvent) : void {
			stage.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
			TweenMax.to(this, 0, {colorMatrixFilter:{brightness:0.5}});
		}


		private function _onStageMouseUp(event : MouseEvent) : void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
			if (_enabled) {
				TweenMax.to(this, 0, {colorMatrixFilter:{brightness:1}});
			}
		}


		override protected function _onClick(event : MouseEvent = null) : void {
			trace("Clicked!");
		}


		override protected function _onRollOver(event : MouseEvent = null) : void {
			TweenMax.to(this, 0, {colorMatrixFilter:{brightness:0.7}});
		}


		override protected function _onRollOut(event : MouseEvent = null) : void {
			TweenMax.to(this, 0, {colorMatrixFilter:{brightness:1.0}});
		}


		override public function set enabled(value : Boolean) : void {
			TweenMax.to(this, 0, {colorMatrixFilter:{brightness:value ? 1 : 1.5}});
			super.enabled = value;
		}
	}
}
