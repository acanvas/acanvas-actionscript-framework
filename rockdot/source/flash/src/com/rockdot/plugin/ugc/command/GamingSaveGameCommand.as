package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.model.vo.UGCGameVO;

	public class GamingSaveGameCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			var vo : UGCGameVO = event.data;
			vo.uid = _ugcModel.userDAO.uid;

			amfOperation("GamingEndpoint.saveGame", vo);
		}
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			return super.dispatchCompleteEvent();
		}
	}
}