package com.rockdot.plugin.screen.common.model {
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;








	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class ScreenModel{

		protected var _log : ILogger = getLogger(ScreenModel);
		
		
		private var _lastResizeTime : Number = 0;
		public function get lastResizeTime() : Number {
			return _lastResizeTime;
		}
		public function set lastResizeTime(lastResizeTime : Number) : void {
			_lastResizeTime = lastResizeTime;
		}

		
		public function ScreenModel() {
		}

	}
}
