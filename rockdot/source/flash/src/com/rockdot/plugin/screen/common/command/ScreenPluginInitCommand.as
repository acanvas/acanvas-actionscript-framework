package com.rockdot.plugin.screen.common.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.ScreenPluginBase;
	import com.rockdot.plugin.screen.common.service.IScreenService;


	public class ScreenPluginInitCommand extends AbstractScreenCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			var _uiService : IScreenService = _context.getObject(ScreenPluginBase.SERVICE_UI);
			_uiService.init(dispatchCompleteEvent);
			
			
		}
	}
}