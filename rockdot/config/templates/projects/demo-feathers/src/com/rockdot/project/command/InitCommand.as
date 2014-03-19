package com.rockdot.project.command {
	import feathers.controls.ScreenNavigator;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;

	import starling.animation.Transitions;

	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.ScreenFeathersPlugin;
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
			
			
			var navigator : ScreenNavigator = _context.getObject(ScreenFeathersPlugin.FEATHERS_SCREEN_NAVIGATOR);
			
			var transitionManager : ScreenSlidingStackTransitionManager = new ScreenSlidingStackTransitionManager(navigator);
			transitionManager.duration = 0.4;
			transitionManager.ease = Transitions.EASE_OUT_BACK;
			
			_stateModel.addressService.init();
			dispatchCompleteEvent();

			return null;
			
				
			
		}
	}
}