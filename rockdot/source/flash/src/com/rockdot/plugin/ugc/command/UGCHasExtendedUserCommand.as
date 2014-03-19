package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;

	public class UGCHasExtendedUserCommand extends AbstractUGCCommand{

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);			
			//event.data == uid String
			amfOperation("UGCEndpoint.hasUserExtended", event.data ? event.data : _ugcModel.userDAO.uid);
		}
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			if(result.result == true){
				_ugcModel.hasUserExtendedDAO = true;
			}
			return super.dispatchCompleteEvent( result.result );
		}

	}
}