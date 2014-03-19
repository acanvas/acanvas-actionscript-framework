package com.rockdot.plugin.state.command {


	import com.rockdot.core.mvc.RockdotEvent;
	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateAddressSetCommand extends AbstractStateCommand {
		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			_stateModel.addressService.changeAddress(event.data, dispatchCompleteEvent);
		}
	}
}
