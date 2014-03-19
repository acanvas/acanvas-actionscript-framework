package com.rockdot.project.command {
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.inject.ScreenServiceAware;
	import com.rockdot.plugin.screen.common.service.IScreenService;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.project.view.text.Fontset;




	/** 
	 * Called by the initialization Command Sequence inside of @see Application
	 */

	public class InitCommand extends CoreCommand implements IStateModelAware, ScreenServiceAware{
		private var _stateModel : StateModel;
		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}

		private var _uiService : IScreenService;
		public function set uiService(uiService : IScreenService) : void {
			_uiService = uiService;
		}

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
		
			//Register Fonts
			new Fontset();
			
			_stateModel.addressService.init();
			dispatchCompleteEvent();

			return null;
		}
	}
}