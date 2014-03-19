package com.rockdot.plugin.state.command.event {
	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateEvents {
		// expects nothing
		public static const INIT : String 				= "StateEvents.INIT";
		
		// expects URL String, e.g. "/"
		public static const ADDRESS_SET : String 		= "StateEvents.ADDRESS_SET";
		
		//expects PageVO
		public static const STATE_VO_SET : String 	= "StateEvents.STATE_VO_CHANGE";
		
		//expects nothing
		public static const STATE_VO_BACK : String 		= "StateEvents.STATE_VO_BACK";
		
		//expects nothing
		public static const STATE_VO_FORWARD : String 	= "StateEvents.STATE_VO_FORWARD";
		
		
		/* The following Events are used internally. See config/docs/model/GetAddressSequence.png */
		
		// expects URL String, e.g. "/"
		public static const STATE_REQUEST : String 		= "StateEvents.STATE_REQUEST";
		// expects VOStatePageChange
		public static const STATE_CHANGE : String 		= "StateEvents.STATE_CHANGE";
		// expects PageVO
		public static const STATE_PARAMS_CHANGE : String= "StateEvents.STATE_PARAMS_CHANGE";

	}
}
