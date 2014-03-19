package com.rockdot.project.view.text {
	import com.rockdot.library.view.textfield.UITextField;

	import flash.text.TextFormat;



	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Light extends UITextField {
		public function Light(txt : String, size : uint = 35, color : uint = 0xffffff) {
			var format : TextFormat = new TextFormat(FontProxy.LIGHT, size, color);
			super(txt, format, true);
			thickness = -50;
		}

		public function set leading(value : Number) : void {
			var format : TextFormat = getTextFormat();
			format.leading = value;
			setTextFormat(format);
		}

		public function get format() : TextFormat {
			return TextFormat(getTextFormat());
		}


		public function set format(value : TextFormat) : void {
			setTextFormat(value);
		}
	}
}
