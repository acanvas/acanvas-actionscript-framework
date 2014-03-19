package com.rockdot.plugin.screen.common.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;


	public class ScreenResizeCommand extends AbstractScreenCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			if(event.data){
				if(event.data is ISpriteComponent){
					(event.data as ISpriteComponent).setSize(_uiService.stage.stageWidth, _uiService.stage.stageHeight);
				}
				else{
					event.data.setSize(_uiService.stage.stageWidth, _uiService.stage.stageHeight);
				}
			}
			else if(_stateModel.currentPage){
				//TODO failsafe minimal width/height
				_stateModel.currentPage.setSize(_uiService.stage.stageWidth, _uiService.stage.stageHeight);;
			}
						
			dispatchCompleteEvent();
			
			return null;
		}
	}
}