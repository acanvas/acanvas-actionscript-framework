package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;






	public class GamingCheckPermissionToPlayCommand extends AbstractUGCCommand{

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			amfOperation("GamingEndpoint.checkPermissionToPlay", _ugcModel.userDAO.uid);
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.gaming.allowedToPlay = result.result;
			return super.dispatchCompleteEvent(_ugcModel.gaming.allowedToPlay);
		}
	}
}