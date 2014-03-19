package com.rockdot.project.view.text {
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.project.model.Colors;

	import flash.text.TextFormat;



	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Copy extends UITextField {
		public function Copy(txt : String, size : uint = 12, color : uint = Colors.WHITE) {
			var format : TextFormat = new TextFormat(FontProxy.COPY, size, color);
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
