package com.rockdot.plugin.tracking.etracker.command {
	import com.greensock.TweenLite;
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.core.mvc.RockdotEvent;



	public class EtrackerInitCommand extends CoreCommand {
		
		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			TweenLite.delayedCall(.1, dispatchCompleteEvent);
			return null;
		}
	}
}