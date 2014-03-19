package com.rockdot.plugin.screen.common.command.event {

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class ScreenEvents {
		
		//expects nothing
		public static const INIT : String 					= "ScreenEvents.INIT";
		
		//expects either UIElement (OPTIONAL!) or uses _modelUI.currentPage
		//then calls element.setSize with stageWidth and Height.
		public static const RESIZE : String 				= "ScreenEvents.RESIZE";
		
		
		
	}
}
