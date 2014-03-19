package com.rockdot.library.view.effect {
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	public class NoEffect extends BasicEffect {
		public function NoEffect() {
			super();
			_applyRecursively = false;
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			target.alpha = 1;
			callback.call();
		}
		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			callback.call();
		}

	}
}
