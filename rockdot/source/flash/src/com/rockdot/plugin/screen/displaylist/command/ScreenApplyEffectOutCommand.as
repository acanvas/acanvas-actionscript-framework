package com.rockdot.plugin.screen.displaylist.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.command.AbstractScreenCommand;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistEffectApplyVO;


	public class ScreenApplyEffectOutCommand extends AbstractScreenCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			var vo : ScreenDisplaylistEffectApplyVO = event.data;
			vo.effect.runOutEffect(vo.target, vo.duration, dispatchCompleteEvent);
			
			return null;
		}

		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			return super.dispatchCompleteEvent(result);
		}
	}
}