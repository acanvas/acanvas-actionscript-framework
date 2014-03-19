package com.rockdot.library.view.effect {
	import com.greensock.TweenLite;
	import com.greensock.easing.Quart;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;


	public class HFlipTransition extends BasicEffect {

		public function HFlipTransition() {
			_applyRecursively = false;
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			target.rotationY = 179;
			target.alpha = 1;
			TweenLite.to(target, duration, {rotationY:0, ease:Quart.easeOut, onComplete:callback.call});
		}
		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			target.alpha = 1;
			TweenLite.to(target, duration, {rotationY:-179, ease:Quart.easeIn, onComplete:callback.call});
		}

	}
}
