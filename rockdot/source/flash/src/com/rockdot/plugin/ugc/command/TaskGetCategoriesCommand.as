package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;

	public class TaskGetCategoriesCommand extends AbstractUGCCommand{

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			amfOperation("UGCEndpoint.getTaskCategories", null);
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.taskCategories = result.result;
			return super.dispatchCompleteEvent(_ugcModel.taskCategories);
		}
	}
}