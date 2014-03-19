package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;






	public class UGCTrackInviteCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			amfOperation("UGCEndpoint.trackInvite", event.data);
		}
	}
}