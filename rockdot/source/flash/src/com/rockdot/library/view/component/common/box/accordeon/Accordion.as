package com.rockdot.library.view.component.common.box.accordeon {
	import com.greensock.TweenLite;
	import com.rockdot.library.view.component.common.box.VBox;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.library.view.component.common.form.list.Cell;

	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Accordion extends VBox {
		protected var _duration : Number;
		private var _multiselection : Boolean;
		public function Accordion(duration : Number = 0.3, padding : int = 0) {
			_duration = duration;
			super(padding, false, false);
		}


		private function _onCellSelected(cell : Cell) : void {
			var selectedItem : AccordionCell = AccordionCell(cell);
			if (_multiselection) {
				_startAnimation(_duration);
			} else {
				deselectAll(selectedItem);
			}
		}


		private function _onCellDeselected(cell : Cell) : void {
			_startAnimation(_duration);
		}


		public function deselectAll(exception : AccordionCell = null) : void {
			var n : uint = numChildren;
			var item : AccordionCell;
			for (var i : int = 0; i < n; i++) {
				item = AccordionCell(getChildAt(i));
				if (item != exception) item.deselect();
			}
			_startAnimation(_duration);
		}


		private function _startAnimation(duration : Number) : void {
			TweenLite.killDelayedCallsTo(removeEventListener);
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			TweenLite.delayedCall(duration + 0.1, removeEventListener, [Event.ENTER_FRAME, _onEnterFrame]);
		}


		private function _onEnterFrame(event : Event) : void {
			update();
		}


		override public function addChild(child : DisplayObject) : DisplayObject {
			if(child is Button)
			Button(child).submitCallback = _onCellSelected;
//			child.addEventListener(CellEvent.SELECTED, _onCellSelected, false, 0, true);
//			child.addEventListener(CellEvent.DESELECTED, _onCellDeselected, false, 0, true);
			AccordionCell(child).duration = _duration;
			return super.addChild(child);
		}


		public function get duration() : Number {
			return _duration;
		}


		public function set duration(value : Number) : void {
			_duration = value;
			for (var i : int = 0; i < numChildren; i++) {
				AccordionCell(getChildAt(i)).duration = _duration;
			}
		}
	}
}
