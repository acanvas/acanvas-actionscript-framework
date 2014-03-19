package com.rockdot.library.view.component.example {
	import com.greensock.TweenLite;
	import com.rockdot.library.view.component.common.box.accordeon.AccordionCell;

	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ExampleAccordionCell extends AccordionCell {
		private var _mask : Shape;

		public function ExampleAccordionCell() {
			_duration = 0.3;

			// Full cell
			graphics.beginFill(0x999999);
			graphics.drawRect(0, 0, 100, 100);
			graphics.endFill();

			_mask = new Shape();
			_mask.graphics.beginFill(0x0);
			_mask.graphics.drawRect(0, 0, 100, 30);
			addChild(_mask);
			mask = _mask;

			var title : TextField = new TextField();
			title.defaultTextFormat = new TextFormat("Arial", 20, 0xFFFFFF, true);
			title.wordWrap = title.multiline = false;
			title.autoSize = TextFieldAutoSize.LEFT;
			title.y = 60;
			title.x = 10;
			title.text = "Cell " + parent.getChildIndex(this);
			addChild(title);
		}


		override public function render() : void {
			graphics.clear();
			graphics.beginFill(0x999999);
			graphics.drawRect(0, 0, _width, 100);
			graphics.endFill();

			_mask.graphics.clear();
			_mask.graphics.beginFill(0x0);
			_mask.graphics.drawRect(0, 0, _width, 30);
			_mask.graphics.endFill();
		}


		override protected function _onRollOut(event : MouseEvent) : void {
			alpha = 1;
		}


		override protected function _onRollOver(event : MouseEvent) : void {
			alpha = 0.5;
		}


		override protected function _onClick(event : MouseEvent) : void {
			_isMultiselection = event.shiftKey;
			if (_isSelected) deselect();
			else select();
		}


		override public function select() : void {
			super.select();
			TweenLite.to(_mask, _duration, {height:100});
		}


		override public function deselect() : void {
			super.deselect();
			TweenLite.to(_mask, _duration, {height:30});
		}


		override public function get height() : Number {
			return _mask.height;
		}
	}
}
