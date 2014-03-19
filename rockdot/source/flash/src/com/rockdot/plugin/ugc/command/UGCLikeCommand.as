package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;






	public class UGCLikeCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			var id : int = event.data;
			var uid : String = _ugcModel.userDAO.uid;
			
			amfOperation("UGCEndpoint.likeItem", {id:id, uid:uid});
		}
	}
}