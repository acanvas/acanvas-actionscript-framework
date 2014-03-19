package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.command.event.vo.UGCFilterVO;

	public class UGCGetLikersCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			var currentImageID : int = int(_ugcModel.currentItemDAO.id);
			var vo : UGCFilterVO = event.data;
			amfOperation("UGCEndpoint.getLikersOfItem", {id:currentImageID, limitIndex:vo.limitindex, limit:vo.limit});
			
			return null;
		}
		
		override public function dispatchCompleteEvent(event : * = null) : Boolean {
			_ugcModel.currentItemDAO.likers = event.result;
			return super.dispatchCompleteEvent(event.result);
		}
	}
}