package com.rockdot.plugin.state.model {

	public class StateConstants 
	{
		/* APPLICATION STATES */
		public static const MAIN_LOADING 		: String = "StateConstants.MAIN_LOADING";
		public static const MAIN_INITIALIZING 	: String = "StateConstants.MAIN_INITIALIZING";
		public static const MAIN_TRANSITIONING 	: String = "StateConstants.MAIN_TRANSITIONING";
		public static const MAIN_PRESENTING		: String = "StateConstants.MAIN_PRESENTING";
		public static const MAIN_PRESENTING_3D		: String = "StateConstants.MAIN_PRESENTING_3D";
		public static const MAIN_IDLING 			: String = "StateConstants.MAIN_IDLING";
		
		/* APPLICATION SUBSTATES */
		public static const SUB_NORMAL 		: String = "StateConstants.SUB_NORMAL";
		public static const SUB_MODAL	 	: String = "StateConstants.SUB_MODAL";
		public static const SUB_LOCKED	 	: String = "StateConstants.SUB_LOCKED";
		public static const SUB_ERROR	 	: String = "StateConstants.SUB_ERROR";
		
		/* Context IDs: Models */
		public static const CTX_MODEL_STATE : String = "CTX_MODEL_STATE";
	}
}

