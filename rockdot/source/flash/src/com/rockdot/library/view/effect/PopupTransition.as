package com.rockdot.library.view.effect {
	import com.greensock.TweenLite;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import flash.geom.Point;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class PopupTransition extends BasicEffect {
		private static const zoomOutScale : Number = 0.9;

		public function PopupTransition() {
			super();
//			_useSprite = true;
//			_sprite = new Sprite();
			
			TweenPlugin.activate([TransformAroundPointPlugin]);
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
//			_sprite.x = Math.round(target.x + target.width / 2);
//			_sprite.y = Math.round(target.y + target.height / 2);
//			
//			var bmpspr : Bitmap = _registerBitmapSprite(target);
//			bmpspr.x = -Math.round(bmpspr.width / 2);
//			bmpspr.y = -Math.round(bmpspr.height / 2);
			TweenLite.to(target, 0, {transformAroundPoint:{point:new Point(target.width / 2, target.height / 2), pointIsLocal:true, scale: zoomOutScale}, autoAlpha: 0});
			TweenLite.to(target, duration, {transformAroundPoint:{point:new Point(target.width / 2, target.height / 2), pointIsLocal:true, scale: 1.0}, autoAlpha: 1, onComplete:onComplete, onCompleteParams: [null, target, callback]});
		}
		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
//			_sprite.x = Math.round(target.x + target.width / 2);
//			_sprite.y = Math.round(target.y + target.height / 2);
//			
//			var bmpspr : Bitmap = _registerBitmapSprite(target);
//			bmpspr.x = -Math.round(bmpspr.width / 2);
//			bmpspr.y = -Math.round(bmpspr.height / 2);
			
			TweenLite.to(target, duration, {transformAroundPoint:{point:new Point(target.width / 2, target.height / 2), pointIsLocal:true, scale: zoomOutScale}, autoAlpha: 0, onComplete:onComplete, onCompleteParams: [null, target, callback]});
		}

	}
}
