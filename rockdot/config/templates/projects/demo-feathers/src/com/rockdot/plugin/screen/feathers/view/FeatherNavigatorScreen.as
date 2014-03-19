package com.rockdot.plugin.screen.feathers.view {
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.themes.MetalWorksMobileTheme;

	import starling.events.Event;

	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.ScreenFeathersPlugin;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.plugin.state.model.vo.StateVO;

	import org.as3commons.lang.Assert;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;




	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 * 
	 * Subclass View to create ViewComponents with a lifecycle.
	 * View does provide a Logger.
	 */
	public class FeatherNavigatorScreen extends RockdotFeatherScreen implements IApplicationContextAware, IStateModelAware {
		private var _theme : MetalWorksMobileTheme;
		private var _stateModel : StateModel;

		public function FeatherNavigatorScreen() {
			super();

			Assert.notNull(_context, "the objectFactory argument must not be null");

			addEventListener(Event.ADDED_TO_STAGE, _addedToStageHandler);
		}

		private function _addedToStageHandler(event : Event) : void {
			_theme = new MetalWorksMobileTheme(this.stage);

			var navigator : ScreenNavigator = _context.getObject(ScreenFeathersPlugin.FEATHERS_SCREEN_NAVIGATOR);
			addChild(navigator);
			
			var names:Vector.<String> = _context.objectDefinitionRegistry.getObjectDefinitionNamesForType(StateVO);
			if (names != null) {
				for each (var name:String in names){
					var stateVO:StateVO = _context.getObject(name);
					navigator.addScreen(stateVO.url, new ScreenNavigatorItem(_context.getObject, {complete:_onScreenComplete}, {functionArgument:stateVO.view_id}));
				}
			}
		}

		private function _onScreenComplete(event : Event) : void {
			new RockdotEvent(StateEvents.STATE_VO_BACK).dispatch();
		}

		protected var _context : IApplicationContext;

		public function get applicationContext() : IApplicationContext {
			return _context;
		}

		public function set applicationContext(value : IApplicationContext) : void {
			_context = value;
		}

		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}
	}
}
