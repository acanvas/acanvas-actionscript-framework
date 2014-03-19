package com.rockdot.project.view.text {
	import com.rockdot.library.view.textfield.UITextField;

	import flash.text.TextFormat;



	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Headline extends UITextField {
		
		public function Headline(txt : String, size : uint = 23, color : uint = 0xffffff) {
			var format : TextFormat = new TextFormat(FontProxy.HEADLINE, size, color);
			format.leading = -2;
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
