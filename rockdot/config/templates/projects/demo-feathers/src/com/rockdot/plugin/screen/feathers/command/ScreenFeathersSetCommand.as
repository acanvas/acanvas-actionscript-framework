package com.rockdot.plugin.screen.feathers.command {
	import feathers.controls.ScreenNavigator;
	import feathers.events.FeathersEventType;

	import starling.events.Event;

	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.ScreenFeathersPlugin;
	import com.rockdot.plugin.state.command.AbstractStateCommand;
	import com.rockdot.plugin.state.command.event.vo.VOStateChange;
	import com.rockdot.plugin.state.model.vo.StateVO;





	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class ScreenFeathersSetCommand extends AbstractStateCommand {
		private var _navigator : ScreenNavigator;

		override public function execute(event : RockdotEvent = null) : * {
			
			var e : VOStateChange = event.data;
			var nextVO : StateVO = e.newVO;

			_navigator = _context.getObject(ScreenFeathersPlugin.FEATHERS_SCREEN_NAVIGATOR);
			_navigator.addEventListener(FeathersEventType.TRANSITION_COMPLETE, _transitionCompleteHandler);
			_navigator.showScreen(nextVO.url);
		}

		private function _transitionCompleteHandler(event : Event) : void {
			_navigator.removeEventListener(FeathersEventType.TRANSITION_COMPLETE, _transitionCompleteHandler);
			dispatchCompleteEvent();
		}

	}
}
