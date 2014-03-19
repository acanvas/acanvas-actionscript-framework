package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;






	public class GamingCheckPermissionToPlayLocaleCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			var obj : Object = {};
			obj.uid = _ugcModel.userDAO.uid;
			obj.locale = RockdotConstants.LANGUAGE + "_" + RockdotConstants.MARKET; 
			
			amfOperation("GamingEndpoint.checkPermissionToPlayLocale", obj);
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.gaming.allowedToPlay = result.result;
			return super.dispatchCompleteEvent(_ugcModel.gaming.allowedToPlay);
		}
	}
}