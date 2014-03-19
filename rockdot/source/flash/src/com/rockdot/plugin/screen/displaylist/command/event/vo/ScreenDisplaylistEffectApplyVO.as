package com.rockdot.plugin.screen.displaylist.command.event.vo {
	import com.rockdot.library.view.effect.IEffect;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	/**
	 * @author nilsdoehring
	 */
	public class ScreenDisplaylistEffectApplyVO{
		public var effect : IEffect;
		public var target : ISpriteComponent;
		public var duration : Number;

		public function ScreenDisplaylistEffectApplyVO(effect : IEffect, target : ISpriteComponent, duration : Number) {
			this.effect = effect;
			this.target = target;
			this.duration = duration;
		}
	}
}
