package com.rockdot.plugin.state.command {
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.plugin.screen.common.inject.IScreenModelAware;
	import com.rockdot.plugin.screen.common.model.ScreenModel;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;


	public class AbstractStateCommand extends CoreCommand implements IStateModelAware, IScreenModelAware{
		
		protected var _uiModel : ScreenModel;
		public function set uiModel(uiModel : ScreenModel) : void {
			_uiModel = uiModel;
		}

		protected var _stateModel : StateModel;
		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}

	}
}