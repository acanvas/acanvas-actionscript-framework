package com.rockdot.plugin.state.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.model.vo.StateVO;

	import flash.net.URLVariables;







	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateRequestCommand extends AbstractStateCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			var urlData : Array = event.data.split("?");
			var stateVO : StateVO = _stateModel.getPageVO(urlData[0].toLowerCase());

			if (stateVO) {
				if (urlData.length > 1) {
					var params : URLVariables = new URLVariables();
					try {
						params.decode(urlData[1]);
					} catch(error : Error) {
						trace("Unable to decode URLVariables. Cancelling request. \n" + error);
					}
					if (stateVO.params) {
						if (params.toString() != stateVO.params.toString())
							stateVO.params = params;
					} else {
						stateVO.params = params;
					}
				} else {
					stateVO.params = null;
				}
				
				new RockdotEvent(StateEvents.STATE_VO_SET, stateVO, dispatchCompleteEvent).dispatch();
				
				
				
			} else {
				// TODO: Define routine for unregistered urls.
				new RockdotEvent(StateEvents.ADDRESS_SET, "/", dispatchCompleteEvent).dispatch();
			}
			
		}
	}
}
