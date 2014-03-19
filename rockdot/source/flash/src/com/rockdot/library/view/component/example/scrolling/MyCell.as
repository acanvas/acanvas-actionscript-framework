package com.rockdot.library.view.component.example.scrolling {
	import com.rockdot.library.view.component.common.form.list.Cell;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;


	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class MyCell extends Cell {
		private var _title : TextField;
		private var _subtitle : TextField;
		[Embed(source="images/arrow.png")]
		private static var embeddedClass : Class;
		private static var bmd : BitmapData = new embeddedClass().bitmapData;

		public function MyCell() {
			super();
			_title = new TextField();
			_title.defaultTextFormat = new TextFormat("Arial", 34, 0x0, true);
			_title.wordWrap = _title.multiline = false;
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.y = 5;
			_title.x = 10;
			addChild(_title);

			_subtitle = new TextField();
			_subtitle.defaultTextFormat = new TextFormat("Arial", 20);
			_subtitle.wordWrap = _subtitle.multiline = false;
			_subtitle.autoSize = TextFieldAutoSize.LEFT;
			_subtitle.x = 10;
			addChild(_subtitle);

			var arrow : Sprite = new Sprite();
			arrow.addChild(new Bitmap(bmd));
			arrow.x = 480 - arrow.width - 20;
			arrow.y = 25;
			arrow.buttonMode = true;
			addChild(arrow);

			arrow.addEventListener(MouseEvent.CLICK, _onClick, false, 0, true);
		}


		override public function set data(data : Object) : void {
			if (data != _data) {
				super.data = data;
				_data = data;
				_title.text = data ? data.title : "NO DATA";
				_subtitle.y = _title.y + _title.height;
				_subtitle.text = data ? data.subtitle : "YOU SHOULD NOT SEE ME";
				render();
			}
		}


		override public function render() : void {
			graphics.clear();
			graphics.beginFill(0xAAAAAA);
			graphics.drawRect(0, 0, 480, height + 8);
			graphics.beginFill(_isSelected ? 0x2579db : (id % 2 == 0 ? 0xFFFFFF : 0xEEEEEE));
			graphics.drawRect(1, 1, 479, height - 2);
			graphics.endFill();
		}


		override public function select() : void {
			if (!_isSelected) {
				super.select();
				render();
			}
		}


		override public function deselect() : void {
			if (_isSelected) {
				super.deselect();
				render();
			}
		}
	}
}
