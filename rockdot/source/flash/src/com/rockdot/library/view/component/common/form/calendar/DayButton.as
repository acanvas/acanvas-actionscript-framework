package com.rockdot.library.view.component.common.form.calendar {
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.library.view.textfield.UITextField;

	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * Copyright (c) 2012, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 16.01.2012 18:32:51
	 */
	public class DayButton extends Button {

		private var _label : UITextField;
		private var _tag : int;

		public function DayButton(label : String, w : int, h : int) {
			super();
			mouseChildren = false;
			
			graphics.beginFill(0x0, .4);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			
			var fm : TextFormat = new TextFormat("Arial", 12, 0xFFFFFF, true);
			fm.align = TextFormatAlign.CENTER;
			
			_label = new UITextField(label, fm, w);
			_label.embedFonts = false;
			_label.wordWrap = true;
			_label.multiline = false;
			_label.height = h;
			_label.autoSize = TextFieldAutoSize.CENTER;
			addChild(_label);
			
			_label.y = Math.floor(h * .5 - _label.height * .5);
		}

		public function get label() : String {
			return _label.text;
		}

		public function set label(value : String) : void {
			_label.text = value;
		}

		public function get tag() : int {
			return _tag;
		}

		public function set tag(tag : int) : void {
			_tag = tag;
		}
	}
}
