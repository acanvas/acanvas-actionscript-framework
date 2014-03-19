package com.rockdot.plugin.screen.displaylist.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.command.AbstractScreenCommand;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistAppearDisappearVO;
	import com.rockdot.plugin.screen.displaylist.view.ManagedSpriteComponentEvent;

	public class ScreenAppearCommand extends AbstractScreenCommand {
		private var _vo : ScreenDisplaylistAppearDisappearVO;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			_vo = event.data;
			_vo.target.addEventListener(ManagedSpriteComponentEvent.APPEAR_COMPLETE, dispatchCompleteEvent);
			_vo.target.appear(_vo.duration);

			return null;
		}

		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_vo.target.removeEventListener(ManagedSpriteComponentEvent.APPEAR_COMPLETE, dispatchCompleteEvent);
			// _vo.target.alpha = 1;
			// _vo.target.visible = true;

			if (_vo.autoDestroy == true) {
				_vo.target.destroy();
			}

			return super.dispatchCompleteEvent(result);
		}
	}
}