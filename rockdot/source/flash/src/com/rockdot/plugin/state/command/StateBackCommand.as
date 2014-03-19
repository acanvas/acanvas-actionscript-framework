package com.rockdot.plugin.state.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateBackCommand extends AbstractStateCommand {
		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			if (_stateModel.historyCount != 0) {
				_stateModel.historyCount--;
				log.info("Go back to: count {0}, url {1}, history: false", [_stateModel.historyCount, _stateModel.history[_stateModel.historyCount].url]);
			}
			new RockdotEvent(StateEvents.ADDRESS_SET, _stateModel.history[_stateModel.historyCount].url, dispatchCompleteEvent).dispatch();
		}

		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			return super.dispatchCompleteEvent(result);
		}


	}
}
