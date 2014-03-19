package com.rockdot.plugin.@plugin.package@.model {
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;


	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class @plugin.class.prefix@Model {

		protected var _log : ILogger = getLogger(@plugin.class.prefix@Model);
		private var _success : Boolean;
		public function set success(success : Boolean) : void {
			_success = success;
		}
		
	}
}
