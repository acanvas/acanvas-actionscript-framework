package com.rockdot.library.util.tracker.data {
	import flash.display.BitmapData;

	/**
	 * provides abstract bitmap data for tracker
	 */
	public class BmdProvider {
		protected var _bmd : BitmapData;

		public function BmdProvider(bmd : BitmapData = null) {
			if (bmd) _bmd = bmd;
		}

		public function update() : void {
		}

		public function stop() : void {
		}

		public function destroy() : void {
		}

		public function get bmd() : BitmapData {
			return _bmd;
		};
	}
}