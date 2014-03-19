package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;






	public class UGCDeleteCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);			
			amfOperation("UGCEndpoint.deleteItem", _ugcModel.currentItemDAO.id);
		}
	}
}