package com.rockdot.plugin.screen.common.inject {
	import com.rockdot.plugin.screen.common.service.IScreenService;
	/**
	 * @author nilsdoehring
	 */
	public interface ScreenServiceAware {
		function set uiService(uiService : IScreenService) : void;
	}
}
