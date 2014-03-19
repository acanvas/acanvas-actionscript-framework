package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;






	public class GamingGetGamesCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			amfOperation("GamingEndpoint.getGames", _ugcModel.userDAO.uid);
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.gaming.games = result.result.games;
			return super.dispatchCompleteEvent(result.result);
		}
	}
}