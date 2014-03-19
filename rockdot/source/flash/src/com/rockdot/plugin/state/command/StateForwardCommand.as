package com.rockdot.plugin.state.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateForwardCommand extends AbstractStateCommand {
		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			if (_stateModel.historyCount != _stateModel.history.length - 1) {
				_stateModel.historyCount++;
				log.info("Go forward to: count {0}, url {1}, history: false", [_stateModel.historyCount, _stateModel.history[_stateModel.historyCount].url]);
			}
			new RockdotEvent(StateEvents.ADDRESS_SET, _stateModel.history[_stateModel.historyCount].url, dispatchCompleteEvent).dispatch();
		}
	}
}
