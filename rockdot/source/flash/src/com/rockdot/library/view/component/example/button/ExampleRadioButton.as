package com.rockdot.library.view.component.example.button {
	import com.rockdot.library.view.component.common.form.button.RadioButton;

	import flash.display.Graphics;
	import flash.display.Shape;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ExampleRadioButton extends RadioButton {
		private var _icon : Shape;

		public function ExampleRadioButton() {
			super();
			var g : Graphics = graphics;
			g.beginFill(0x555555);
			g.drawCircle(10, 10, 10);
			g.endFill();

			_icon = new Shape();
			g = _icon.graphics;
			g.beginFill(0xDDDDDD);
			g.drawCircle(10, 10, 5);
			g.endFill();
			addChild(_icon);
			_icon.visible = false;
		}


		override public function set isToggled(value : Boolean) : void {
			super.isToggled = value;
			_icon.visible = _isToggled;
		}
	}
}
