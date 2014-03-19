package com.rockdot.plugin.screen.displaylist.command.event.vo {
	import com.rockdot.library.view.effect.IEffect;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	/**
	 * @author nilsdoehring
	 */
	public class ScreenDisplaylistTransitionApplyVO {
		public var effect : IEffect;
		public var transitionType : String;
		public var targetPrimary : ISpriteComponent;
		public var targetSecondary : ISpriteComponent;
		public var duration : Number;

		public function ScreenDisplaylistTransitionApplyVO(effect : IEffect, transitionType : String, targetPrimary : ISpriteComponent, duration : Number, targetSecondary : ISpriteComponent = null) {
			this.duration = duration;
			this.targetPrimary = targetPrimary;
			this.targetSecondary = targetSecondary;
			this.transitionType = transitionType;
			this.effect = effect;
		}
	}
}
