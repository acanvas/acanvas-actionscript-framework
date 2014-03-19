package com.rockdot.plugin.screen.displaylist.command.event.vo {
	import com.rockdot.library.view.effect.IEffect;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	/**
	 * @author nilsdoehring
	 */
	public class ScreenDisplaylistTransitionPrepareVO {
		public var outTarget : ISpriteComponent;
		public var inTarget : ISpriteComponent;
		public var effect : IEffect;
		public var modal : Boolean;
		public var transitionType : String;
		public var initialAlpha : Number = 0;

		public function ScreenDisplaylistTransitionPrepareVO(transitionType : String, outTarget : ISpriteComponent, effect : IEffect, inTarget : ISpriteComponent, modal : Boolean, initialAlpha : Number) {
			this.transitionType = transitionType;
			this.modal = modal;
			this.outTarget = outTarget;
			this.inTarget = inTarget;
			this.effect = effect;
			this.initialAlpha = initialAlpha;
		}
	}
}
