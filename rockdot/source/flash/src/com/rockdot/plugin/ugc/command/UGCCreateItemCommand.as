package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;

	public class UGCCreateItemCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);			
			
			if (event.data is UGCItemVO) {
				_ugcModel.currentItemDAO = event.data;
			}
			
			if(_ugcModel.currentItemDAO){
				if(_ugcModel.currentItemContainerDAO && _ugcModel.currentItemContainerDAO.id){
					_ugcModel.currentItemDAO.container_id = _ugcModel.currentItemContainerDAO.id;
				}
				_ugcModel.currentItemDAO.creator_uid = _ugcModel.userDAO.uid;
				amfOperation("UGCEndpoint.createItem", _ugcModel.currentItemDAO);
			}
			else{
				dispatchErrorEvent("Nothing to upload. Meh.");
			}
			

		}
	}
}