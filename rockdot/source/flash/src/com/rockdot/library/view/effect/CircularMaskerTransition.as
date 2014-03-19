package com.rockdot.library.view.effect {
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.jvm.components.CircularMasker;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class CircularMaskerTransition extends BasicEffect {
		private var _mask : CircularMasker;

		public function CircularMaskerTransition() {
			_applyRecursively = false;
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			_mask = new CircularMasker(target.width*2, target.height*2);
			_mask.x = target.x - target.width/2;
			_mask.y = target.y - target.height/2;
			
			if (!target.parent.contains(_mask))
				target.parent.addChild(_mask);
			target.mask = _mask;
			target.alpha = 1;
			
			_mask.progress = 0;
			TweenLite.to(_mask, duration, {progress: 1, ease: Linear.easeNone , onComplete: _onComplete, onCompleteParams: [callback]});
		}
		
		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			_mask = new CircularMasker(target.width*2, target.height*2);
			_mask.x = target.x - target.width/2;
			_mask.y = target.y - target.height/2;
			
			if (!target.parent.contains(_mask))
				target.parent.addChild(_mask);
			target.mask = _mask;
			target.alpha = 1;
			
			_mask.progress = 1;
			TweenLite.to(_mask, duration, {progress: 0, ease: Linear.easeNone , onComplete: _onComplete, onCompleteParams: [callback]});
		}


		private function _onComplete(callback : Function) : void {
			TweenLite.killTweensOf(_mask);
			_mask.parent.removeChild(_mask);
			_mask = null;
			callback.call(null);
		}


		override public function cancel(target : ISpriteComponent = null) : void {
			if (!target) {
				TweenLite.killTweensOf(_mask);
			}
			super.cancel(target);
		}
	}
}
