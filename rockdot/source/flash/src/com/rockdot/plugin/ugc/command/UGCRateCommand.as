package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.command.event.vo.UGCRatingVO;






	public class UGCRateCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			var vo : UGCRatingVO = event.data;
			var uid : String = _ugcModel.userDAO.uid;

			amfOperation("UGCEndpoint.rateItem", {id:vo.id, rating:vo.rating, uid:uid});
		}
	}
}