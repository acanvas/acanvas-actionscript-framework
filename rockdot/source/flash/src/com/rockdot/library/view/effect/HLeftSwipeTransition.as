package com.rockdot.library.view.effect {
	import com.greensock.TweenLite;
	import com.greensock.easing.Quart;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	public class HLeftSwipeTransition extends BasicEffect {
		public function HLeftSwipeTransition() {
			super();
			_applyRecursively = false;
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			var iTargetXOriginal : Number = target.x;
			target.x = target.stage.stageWidth;
			target.alpha = 1;
			TweenLite.to(target, duration, {x:iTargetXOriginal, ease:Quart.easeOut, onComplete:callback.call});
		}
		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			TweenLite.to(target, duration, {x:-target.stage.stageWidth, ease:Quart.easeOut, onComplete:callback.call});
		}

	}
}
