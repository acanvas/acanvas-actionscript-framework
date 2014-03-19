package com.rockdot.plugin.state.service {
	import com.rockdot.plugin.state.model.vo.StateVO;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public interface IAddressService {
		function init() : void;
		function changeAddress(url : String, callback : Function = null) : void;
		function onAddressChanged(event : StateVO) : void;
	}
}
