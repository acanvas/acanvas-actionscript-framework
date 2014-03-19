package com.rockdot.library.view.textfield {
	import flash.text.TextFormat;

	public class UITextFieldShrinkToFit extends UITextField 
	{
		
		public function UITextFieldShrinkToFit( value : String, format : TextFormat, maxwidth : int, maxheight : int = 0 )
		{
			super(value, format, true);
			width = maxwidth;
			while(textWidth > maxwidth){
				format.size = int(format.size) - 1;
				setTextFormat(format);
			}
			if(maxheight > 0){
				while(textHeight > maxheight){
					format.size = int(format.size) - 1;
					setTextFormat(format);
				}
			}
		}
		
	}
}
