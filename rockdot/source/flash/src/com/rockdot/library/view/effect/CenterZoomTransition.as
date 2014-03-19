package com.rockdot.library.view.effect {
	import com.greensock.TweenLite;
	import com.greensock.easing.Quart;
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import flash.display.Bitmap;
	import flash.display.Sprite;


	public class CenterZoomTransition extends BasicEffect {
		public function CenterZoomTransition() {
			super();
			_sprite = new Sprite();
			_useSprite = true;
			
			TweenPlugin.activate([TransformAroundCenterPlugin]);
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			var bmpspr : Bitmap = _registerBitmapSprite(target);
			TweenLite.to(bmpspr, 0, {alpha:0, transformAroundCenter:{scale:.8}});
			TweenLite.to(bmpspr, duration, {alpha:1, transformAroundCenter:{scale:1}, ease:Quart.easeOut, onComplete:onComplete, onCompleteParams: [bmpspr, target, callback]});
		}
		
		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			var bmpspr : Bitmap = _registerBitmapSprite(target);
			TweenLite.to(bmpspr, duration, {alpha:0, transformAroundCenter:{scale:.8}, ease:Quart.easeOut, onComplete:onComplete, onCompleteParams: [bmpspr, null, callback]});
		}


	}
}
