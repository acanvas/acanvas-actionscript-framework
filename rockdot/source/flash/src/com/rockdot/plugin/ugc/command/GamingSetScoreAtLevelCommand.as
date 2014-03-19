package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.model.vo.UGCGameVO;

	public class GamingSetScoreAtLevelCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			var vo : UGCGameVO = event.data;
			vo.uid = _ugcModel.userDAO.uid;

			amfOperation("GamingEndpoint.setScore", vo);
		}
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.userExtendedDAO.score = result.result.score;
			_ugcModel.gaming.rank = result.result.rank;
			return super.dispatchCompleteEvent(result.result);
		}
	}
}