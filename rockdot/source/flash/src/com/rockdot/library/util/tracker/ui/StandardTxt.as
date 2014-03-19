package com.rockdot.library.util.tracker.ui {
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	public class StandardTxt extends TextField {
		
		public static const defTextFormat:TextFormat = new TextFormat("Verdana",11,0xFFFFFF);
		public static const defFilters:Array = [/*new DropShadowFilter(1,90,0x000000,0.25,4,4,3,2)*/];
		
		public function StandardTxt() {
			super();
			
			defaultTextFormat = defTextFormat;
			selectable = false;
			multiline = true;
			wordWrap = true;
			autoSize = TextFieldAutoSize.LEFT;
			filters = defFilters;
		}
		
		override public function set text( t:String ):void {
			super.text = t;
			filters = filters;
		}
		override public function get text():String {
			return super.text;
		}
		
		override public function appendText( t:String ):void {
			super.appendText(t);
			filters = filters;
		}
		
	}
}