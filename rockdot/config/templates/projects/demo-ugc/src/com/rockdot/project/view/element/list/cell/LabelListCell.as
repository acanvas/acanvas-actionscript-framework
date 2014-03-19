package com.rockdot.project.view.element.list.cell {
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Headline;

	import flash.display.BitmapData;



	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class LabelListCell extends Cell {
		protected static const CELL_HEIGHT : Number = 30;
		protected var _title : Headline;
		protected var _bgBmd : BitmapData;

		public function LabelListCell(w : uint) {
			super();
			_width = w;

			_title = new Headline("emtpy", 15, 0x0);
			addChild(_title);
			
			render();
		}


		override public function set data(data : Object) : void {
			if (data != _data) {
				super.data = data;
				if (_data) {
					_title.text = String(_data);
					render();
				}
			}
		}


		override public function render() : void {
			_title.x = 10;
			_title.y = 7;
			_title.width = _width - 10;

			graphics.clear();
			graphics.beginFill(0x222222);
			graphics.drawRect(0, 0, _width, CELL_HEIGHT);
			graphics.beginFill(_isSelected ? Colors.YELLOW : (id % 2 == 0 ? 0xFFFFFF : 0xEEEEEE));
			graphics.drawRect(0, 0, _width, height + 6);
			graphics.endFill();
		}

	}
}
