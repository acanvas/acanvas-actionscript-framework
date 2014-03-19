package com.rockdot.project.command {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.screen.common.inject.ScreenServiceAware;
	import com.rockdot.plugin.screen.common.service.IScreenService;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.project.view.element.frame.Background;
	import com.rockdot.project.view.text.Fontset;

	import flash.filters.BlurFilter;




	/** 
	 * Called by the initialization Command Sequence inside of @see Application
	 */

	public class InitCommand extends AbstractCommand implements IStateModelAware, ScreenServiceAware, IFBModelAware{
		private var _stateModel : StateModel;
		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}

		private var _uiService : IScreenService;
		public function set uiService(uiService : IScreenService) : void {
			_uiService = uiService;
		}
		
		private var _fbModel : FBModel;
		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
		
			//Register Fonts
			new Fontset();
			
			//App Background
			var background : Background = new Background("element.background");
			background.init();
			background.setSize(BootstrapConstants.WIDTH_STAGE - 20, BootstrapConstants.HEIGHT_STAGE - 20);
			background.render();

			_uiService.background.addChild(background);
			_uiService.modalBackgroundFilter = new BlurFilter(6, 6);
			
//			 Possible States:
//			  	- RockdotConstants.VAR_FROM_VALUE_APPREQUEST_VIEW
//			 	- RockdotConstants.VAR_FROM_VALUE_APPREQUEST_PARTICIPATE
//			 	- RockdotConstants.VAR_FROM_VALUE_SHARE
			var reason_value : String = RockdotConstants.URLVAR(RockdotConstants.VAR_REASON_KEY);
			_appModel.state = reason_value;
			
			if(RockdotConstants.URLVAR(RockdotConstants.VAR_ITEM_ID)){
				/* Optional: Direct Link to Item ID (Good for Facebook Posts linking back to User Generated Content) */
				new RockdotEvent(StateEvents.ADDRESS_SET, "/image/view?id=" + RockdotConstants.URLVAR(RockdotConstants.VAR_ITEM_ID)).dispatch();
			}

			_stateModel.addressService.init();
			dispatchCompleteEvent();

			return null;
			
				
//			var navigator : ScreenNavigator = _context.getObject(FeathersPlugin.FEATHERS_SCREEN_NAVIGATOR);
//			
//			var transitionManager : ScreenSlidingStackTransitionManager = new ScreenSlidingStackTransitionManager(navigator);
//			transitionManager.duration = 0.4;
//			transitionManager.ease = Transitions.EASE_OUT_BACK;
			
		}
	}
}