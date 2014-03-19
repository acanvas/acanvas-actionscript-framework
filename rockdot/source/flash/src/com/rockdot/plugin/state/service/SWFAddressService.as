package com.rockdot.plugin.state.service {
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.jvm.utils.UrlUtils;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.model.vo.StateVO;




	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class SWFAddressService extends BasicAddressService implements IAddressService{
		private var _defaultTitle : String;
		private var _callback : Function;

		public function SWFAddressService() {
		}

		override public function init() : void {
			_defaultTitle = SWFAddress.getTitle() + " - ";
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, _onSWFAddressChange);
		}

		private function _onSWFAddressChange(event : SWFAddressEvent) : void {
			new RockdotEvent(StateEvents.STATE_REQUEST, event.value, _callback).dispatch();
		}

		override public function changeAddress(url : String, callback : Function = null) : void {
			_callback = callback;
			if (UrlUtils.isHyperlink(url))
				SWFAddress.href(url, "_blank");
			else
				SWFAddress.setValue(url);
		}

		override public function onAddressChanged(vo : StateVO) : void {
			SWFAddress.setTitle(_defaultTitle + vo.title);
			super.onAddressChanged(vo);
		}
	}
}
