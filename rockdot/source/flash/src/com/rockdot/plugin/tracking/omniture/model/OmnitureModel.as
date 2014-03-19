package com.rockdot.plugin.tracking.omniture.model {
	import com.omniture.AppMeasurement;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class OmnitureModel {

		protected var _log : ILogger = getLogger(OmnitureModel);
		
		private var _success : Boolean;
		public function set success(success : Boolean) : void {
			_success = success;
		}

		private var _tracker : AppMeasurement;

		public function get tracker() : AppMeasurement {
			return _tracker;
		}

		public function set tracker(tracker : AppMeasurement) : void {
			_tracker = tracker;
		}
		
	}
}
