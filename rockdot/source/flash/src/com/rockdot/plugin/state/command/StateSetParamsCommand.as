package com.rockdot.plugin.state.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.model.vo.StateVO;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateSetParamsCommand extends AbstractStateCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			var vo : StateVO = event.data;
			_stateModel.addressService.onAddressChanged(vo);
			if(_stateModel.currentPage){
				_stateModel.currentPage.setData( vo.params );
			}
			
			dispatchCompleteEvent();
		}
	}
}
