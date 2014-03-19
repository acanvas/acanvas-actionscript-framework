package com.rockdot.project.view.element {
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Copy;
	import com.rockdot.project.view.text.Headline;

	import flash.display.BitmapData;





	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateVOCell extends Cell {
		protected static const CELL_HEIGHT : Number = 150;
		protected var _title : Headline;
		protected var _subtitle : Copy;
		protected var _bgBmd : BitmapData;

		public function StateVOCell(w : uint) {
			super();
			_width = w;

			_title = new Headline("emtpy", 15, 0x0);
			_title.width = w-10;
			_title.y = 10;
			_title.x = 10;
			addChild(_title);

			_subtitle = new Copy("emtpy", 11, 0x0);
			_subtitle.width = w-10;
			_subtitle.x = 10;
			_subtitle.y = _title.y + _title.height;
			addChild(_subtitle);
			
			render();

		}


		override public function set data(data : Object) : void {
			if (data != _data) {
				super.data = data;
				if (_data) {
					_title.text = _data["label"];
					_subtitle.y = _title.y + _title.height;
					_subtitle.text = _data["url"];
					render();
				}
			}
		}


		override public function render() : void {
			graphics.clear();
			graphics.beginFill(0x222222);
			graphics.drawRect(0, 0, _width, CELL_HEIGHT);
			graphics.beginFill(_isSelected ? Colors.HIGHLIGHT : (id % 2 == 0 ? 0xFFFFFF : 0xEEEEEE));
			graphics.drawRect(0, 0, _width, CELL_HEIGHT);
			graphics.endFill();
		}


	}
}
