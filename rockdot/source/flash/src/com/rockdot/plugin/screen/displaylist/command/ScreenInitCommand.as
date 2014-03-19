package com.rockdot.plugin.screen.displaylist.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.command.AbstractScreenCommand;
	import com.rockdot.plugin.screen.displaylist.view.IManagedSpriteComponent;
	import com.rockdot.plugin.screen.displaylist.view.ManagedSpriteComponentEvent;




	public class ScreenInitCommand extends AbstractScreenCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			var ui :IManagedSpriteComponent;
			if(event.data){
				ui = (event.data as IManagedSpriteComponent);
			}
			else if(_stateModel.currentPage){
				//TODO failsafe minimal width/height
				ui = _stateModel.currentPage;
			}
			
			if(ui.isInitialized){
				dispatchCompleteEvent();										
			}
			else{
				ui.addEventListener(ManagedSpriteComponentEvent.INIT_COMPLETE, dispatchCompleteEvent);
				ui.init(_stateModel.currentPageVOParams);
			}
			
			return null;
		}
	}
}