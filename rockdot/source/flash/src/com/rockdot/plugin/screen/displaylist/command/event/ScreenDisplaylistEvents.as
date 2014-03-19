package com.rockdot.plugin.screen.displaylist.command.event {

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class ScreenDisplaylistEvents {

		public static const SCREEN_INIT : String 				= "ScreenDisplaylistEvents.SCREEN_INIT";
		
		//expects VOUITransition
		public static const TRANSITION_PREPARE : String 				= "ScreenDisplaylistEvents.TRANSITION_DISPLAYLIST";

		//expects VOUIApplyEffect
		public static const TRANSITION_RUN : String 					= "ScreenDisplaylistEvents.TRANSITION_RUN";
		public static const APPLY_EFFECT_IN : String					= "ScreenDisplaylistEvents.APPLY_EFFECT_IN";
		public static const APPLY_EFFECT_OUT : String 					= "ScreenDisplaylistEvents.APPLY_EFFECT_OUT";

		//expects VOUIAppearDisappear
		public static const APPEAR : String 							= "ScreenDisplaylistEvents.APPEAR";
		public static const DISAPPEAR : String = "ScreenDisplaylistEvents.DISAPPEAR";
			
	}
}
