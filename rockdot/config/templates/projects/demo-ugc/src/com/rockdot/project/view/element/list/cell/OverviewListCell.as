package com.rockdot.project.view.element.list.cell {
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Copy;
	import com.rockdot.project.view.text.Headline;

	import flash.display.BitmapData;



	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class OverviewListCell extends Cell {
		protected static const CELL_HEIGHT : Number = 150;
		protected var _title : Headline;
		protected var _subtitle : Copy;
		protected var _bgBmd : BitmapData;

		public function OverviewListCell(w : uint) {
			super();
			_width = w;

			_title = new Headline("emtpy", 15, 0x0);
			addChild(_title);

			_subtitle = new Copy("emtpy", 11, 0x0);
			addChild(_subtitle);
			
			render();

		}


		override public function set data(data : Object) : void {
			if (data != _data) {
				super.data = data;
				if (_data) {
					_title.text = _data.label;
					_subtitle.text = _data.url;
					render();
				}
			}
		}


		override public function render() : void {
			_title.x = 10;
			_title.y = 10;
			_title.width = _width - 20;

			_subtitle.x = 10;
			_subtitle.y = _title.y + _title.textHeight + 5;
			_subtitle.width = _width - 20;
			
			graphics.clear();
			graphics.beginFill(_isSelected ? Colors.YELLOW : (id % 2 == 0 ? 0xFFFFFF : 0xEEEEEE));
			graphics.drawRect(0, 0, _width-10, CELL_HEIGHT);
			graphics.endFill();
		}

		override public function get width() : Number {
			return _width - 10;
		}
		override public function get height() : Number {
			return CELL_HEIGHT;
		}


	}
}
