package com.rockdot.library.view.effect {
	import com.greensock.TweenLite;
	import com.greensock.easing.Quart;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class HRightSwipeTransition extends BasicEffect {
		public function HRightSwipeTransition() {
			super();
			_applyRecursively = false;
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			target.x = -target.stage.stageWidth;
			target.alpha = 1;
			TweenLite.to(target, duration, {x:0/*ApplicationConstants.X_PAGES*/, ease:Quart.easeOut, onComplete:callback.call});
		}
		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			TweenLite.to(target, duration, {x:target.stage.stageWidth, ease:Quart.easeOut, onComplete:callback.call});
		}
	}
}
