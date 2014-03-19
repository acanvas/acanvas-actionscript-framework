package com.rockdot.project.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;

	/** 
	 * Called by the initialization Command Sequence inside of @see Application
	 */
	public class AfterLoginDispatchCommand extends AbstractCommand{

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			// some permission prompts have special operations. most of them want to go to the _data.next address
			switch(event.data.prompt) {
				case "facebook.friends":
					new RockdotEvent(StateEvents.STATE_VO_BACK, null, dispatchCompleteEvent).dispatch();
					break;
				case "facebook.albums":
				default:
					new RockdotEvent(StateEvents.ADDRESS_SET, event.data.next, dispatchCompleteEvent).dispatch();
					break;
			}
		}

	}
}