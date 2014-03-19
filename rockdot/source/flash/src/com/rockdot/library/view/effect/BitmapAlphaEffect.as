package com.rockdot.library.view.effect {
	import com.greensock.TweenLite;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import flash.display.Bitmap;
	import flash.display.Sprite;




	/**
	 */
	public class BitmapAlphaEffect extends BasicEffect {
		public function BitmapAlphaEffect() {
			_useSprite = true;
			_sprite = new Sprite();
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			var bmpspr : Bitmap = _registerBitmapSprite(target);
			bmpspr.visible = false;
			bmpspr.alpha = 0;
			TweenLite.to(bmpspr, duration, {autoAlpha:1, onComplete:onComplete, onCompleteParams: [bmpspr, target, callback]});
		}
		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			var bmpspr : Bitmap = _registerBitmapSprite(target);
			bmpspr.visible = true;
			bmpspr.alpha = 1;
			TweenLite.to(bmpspr, duration, {autoAlpha:0, onComplete:onComplete, onCompleteParams: [bmpspr, null, callback]});
		}
		
	}
}
