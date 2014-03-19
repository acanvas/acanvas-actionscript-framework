package com.rockdot.library.view.component.common.box.accordeon {
	import com.rockdot.library.view.component.common.form.list.Cell;
	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class AccordionCell extends Cell {
		// Duration of the expand / collapse animation
		protected var _duration : Number;

		public function AccordionCell() {
			super();
		}


		public function get duration() : Number {
			return _duration;
		}


		public function set duration(value : Number) : void {
			_duration = value;
		}
	}
}
