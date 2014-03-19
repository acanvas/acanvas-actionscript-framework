package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.model.vo.UGCItemContainerVO;

	public class UGCCreateItemContainerCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);			
			if (event.data is UGCItemContainerVO) {
				_ugcModel.currentItemContainerDAO = event.data;
			}
			amfOperation("UGCEndpoint.createItemContainer", _ugcModel.currentItemContainerDAO);
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.currentItemContainerDAO.id = result.result;
			if(_ugcModel.currentItemDAO){
				_ugcModel.currentItemDAO.container_id = result.result;
			}
			return super.dispatchCompleteEvent(result);
		}
	}
}