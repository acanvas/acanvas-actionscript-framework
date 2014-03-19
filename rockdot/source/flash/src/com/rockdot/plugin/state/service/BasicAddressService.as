package com.rockdot.plugin.state.service {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.model.vo.StateVO;




	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class BasicAddressService implements IAddressService{

		public function init() : void {}

		
		public function changeAddress(url : String, callback : Function = null) : void {
			new RockdotEvent(StateEvents.STATE_REQUEST, url).dispatch();
		}

		public function onAddressChanged(vo : StateVO) : void {}


	}
}
