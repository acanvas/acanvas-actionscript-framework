package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;

	public class TaskGetTasksByCategoryCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			amfOperation("UGCEndpoint.getTasksOfCategory", event.data);
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.loadedTasks = result.result;
			return super.dispatchCompleteEvent(result.result);
		}
	}
}