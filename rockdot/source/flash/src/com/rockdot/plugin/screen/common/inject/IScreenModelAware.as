package com.rockdot.plugin.screen.common.inject {
	import com.rockdot.plugin.screen.common.model.ScreenModel;
	/**
	 * @author nilsdoehring
	 */
	public interface IScreenModelAware {
		function set uiModel(uiModel : ScreenModel) : void;
	}
}
