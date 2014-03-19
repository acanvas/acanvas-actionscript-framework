package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.command.event.vo.UGCRatingVO;






	public class UGCUnlikeCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			var id : int = (event.data as UGCRatingVO).id;
			var uid : String = _ugcModel.userDAO.uid;

			amfOperation("UGCEndpoint.unlikeItem", {id:id, uid:uid});
		}
	}
}