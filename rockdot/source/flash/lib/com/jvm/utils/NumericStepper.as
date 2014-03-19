package com.jvm.utils {
	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class NumericStepper {
		private var _min : Number;
		private var _max : Number;
		private var _step : Number;
		private var _loop : Boolean;
		private var _curStep : Number;

		public function NumericStepper(min : Number, max : Number, step : Number = 1, loop : Boolean = true) {
			_min = min;
			_max = max;
			_step = step;
			_loop = loop;
			_curStep = min;
		}


		public function get value() : Number {
			return _curStep;
		}


		public function get step() : Number {
			return _step;
		}


		public function set step(step : Number) : void {
			_step = step;
		}


		public function jumpTo(i : Number) : Number {
			return _update(i, false);
		}


		public function jumpToFirst() : Number {
			_curStep = _min;
			return _curStep;
		}


		public function jumpToLast() : Number {
			_curStep = _max;
			return _curStep;
		}


		public function forward() : Number {
			return _update(_curStep + _step, _loop);
		}


		public function back() : Number {
			return _update(_curStep - _step, _loop);
		}


		private function _update(i : Number, loop : Boolean) : Number {
			if (i != _curStep) {
				if (i < _min) {
					if (loop) _curStep = _max;
					else _curStep = _min;
				} else if (i > _max) {
					if (loop) _curStep = _min;
					else _curStep = _max;
				} else {
					_curStep = i;
				}
			}
			return _curStep;
		}


		public function get min() : Number {
			return _min;
		}


		public function set min(min : Number) : void {
			_min = min;
		}


		public function get max() : Number {
			return _max;
		}


		public function set max(max : Number) : void {
			_max = max;
		}


		public function get loop() : Boolean {
			return _loop;
		}


		public function set loop(loop : Boolean) : void {
			_loop = loop;
		}
	}
}
