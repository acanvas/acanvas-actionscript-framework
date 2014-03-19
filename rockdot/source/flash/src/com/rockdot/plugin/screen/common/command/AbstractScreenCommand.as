package com.rockdot.plugin.screen.common.command {
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.plugin.screen.common.inject.IScreenModelAware;
	import com.rockdot.plugin.screen.common.inject.ScreenServiceAware;
	import com.rockdot.plugin.screen.common.model.ScreenModel;
	import com.rockdot.plugin.screen.common.service.IScreenService;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;

	public class AbstractScreenCommand extends CoreCommand implements IScreenModelAware, ScreenServiceAware, IStateModelAware{

		protected var _uiModel : ScreenModel;
		public function set uiModel(uiModel : ScreenModel) : void {
			_uiModel = uiModel;
		}

		protected var _uiService : IScreenService;
		public function set uiService(uiService : IScreenService) : void {
			_uiService = uiService;
		}

		protected var _stateModel : StateModel;
		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}

	}
}