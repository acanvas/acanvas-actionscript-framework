package com.rockdot.library.view.component.example.button {
	import com.greensock.TweenMax;
	import com.rockdot.library.view.component.common.form.button.ToggleButton;
	import com.rockdot.library.view.textfield.UITextField;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ExampleToggleButton extends ToggleButton {
		private var _hPadding : int = 10;
		private var _vPadding : int = 5;
		private var _label : UITextField;
		private var _bg : Bitmap;

		public function ExampleToggleButton() {
			mouseChildren = false;

			_label = new UITextField("Not toggled", new TextFormat("Arial", 12, 0xFFFFFF, true));
			_label.embedFonts = false;
			_label.wordWrap = false;
			_label.x = _hPadding;
			_label.y = _vPadding;

			_bg = new Bitmap(new BitmapData(_label.width + 2 * _hPadding, _label.height + 2 * _vPadding, false, 0x0));
			_bg.bitmapData.fillRect(_bg.bitmapData.rect, 0x999999);

			addChild(_bg);
			addChild(_label);

			addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);

			super();
		}


		override public function set isToggled(value : Boolean) : void {
			super.isToggled = value;
			if (_isToggled) {
				_label.text = "Toggled";
				_bg.bitmapData.fillRect(_bg.bitmapData.rect, 0xFF6666);
			} else {
				_label.text = "Not toggled";
				_bg.bitmapData.fillRect(_bg.bitmapData.rect, 0x999999);
			}
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


		override protected function _onRollOver(event : MouseEvent) : void {
			TweenMax.to(this, 0, {colorMatrixFilter:{brightness:0.7}});
		}


		override protected function _onRollOut(event : MouseEvent) : void {
			TweenMax.to(this, 0, {colorMatrixFilter:{brightness:1.0}});
		}


		override public function set enabled(value : Boolean) : void {
			TweenMax.to(this, 0, {colorMatrixFilter:{brightness:value ? 1 : 1.5}});
			super.enabled = value;
		}
	}
}
