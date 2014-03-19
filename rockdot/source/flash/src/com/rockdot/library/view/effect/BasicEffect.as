package com.rockdot.library.view.effect {
	import com.greensock.TweenLite;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;




	/**
	 * @author nilsdoehring
	 */
	public class BasicEffect implements IEffect{
		
		private var _type : String;
		public function get type() : String {
			return _type;
		}
		public function set type(type : String) : void {
			_type = type;
		}

		protected var _initialAlpha : Number;
		public function get initialAlpha() : Number {
			return _initialAlpha;
		}
		public function set initialAlpha(initialAlpha : Number) : void {
			_initialAlpha = initialAlpha;
		}
		
		protected var _duration : Number;
		public function set duration(duration : Number) : void {
			_duration = duration;
		}
		public function get duration() : Number {
			return _duration;
		}

		protected var _sprite : Sprite;
		public function set sprite(sprite : Sprite) : void {
			_sprite = sprite;
		}
		public function get sprite() : Sprite {
			return _sprite;
		}

		protected var _useSprite : Boolean;
		public function useSprite() : Boolean {
			return _useSprite;
		}

		protected var _applyRecursively : Boolean;
		public function get applyRecursively() : Boolean {
			return _useSprite == true ? false : _applyRecursively;
		}

		public function BasicEffect() {
			_duration = 0.5;
			_applyRecursively = false;
			_useSprite = false;
		}
		
		protected function _registerBitmapSprite(target : ISpriteComponent) : Bitmap {
			
			_applyRecursively = false;
			
			target.alpha = 1;
			var rect:Rectangle =  target.getRect( target as DisplayObject);

			var output : BitmapData = new BitmapData(rect.width + 20, rect.height + 20, true, 0x00000000);
			var mat:Matrix = target.transform.matrix ? target.transform.matrix : new Matrix();
			_sprite.x = mat.tx;
			_sprite.y = mat.ty;	
			
			mat.tx = mat.ty = 0;
			output.draw( target, mat );

			var outputBmp : Bitmap = new Bitmap(output);
			outputBmp.cacheAsBitmap = true;
			target.alpha = 0;
			
			_sprite.addChild( outputBmp );
			return outputBmp;
			
		}

		
		//These two are the only methods you'll need to override. See BitmapAlphaEffect.
		public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			target.alpha = 0;
			TweenLite.to(target, duration, {autoAlpha:1, onComplete : callback.call});
		}
		public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			target.visible = true;
			target.alpha = 1;
			TweenLite.to(target, duration, {autoAlpha:0, onComplete : callback.call});
		}
		
		public function cancel(target : ISpriteComponent = null) : void {
			if(!target) return;
			
			TweenLite.killTweensOf(target);
			
			var child : DisplayObject;
			for (var i : int = 0; i < (target as DisplayObjectContainer).numChildren; i++) {
				child = (target as DisplayObjectContainer).getChildAt(i);
				if(child is ISpriteComponent){
					cancel(child as ISpriteComponent);
				}
			}
		}
		
		protected function onComplete(target : Bitmap = null, page: ISpriteComponent = null, callback : Function = null) : void {
			TweenLite.killTweensOf(target);
			
			if(target){
				if(target.parent){
					target.parent.removeChild(target);
				}
				target.bitmapData.dispose();
			}
			
			if(page){
				page.alpha = 1;
			}
			
			if(callback != null){
				callback.call(null);
			}
		}

		public function destroy() : void {
			if(_sprite && useSprite()){
				TweenLite.killTweensOf(_sprite);
				if ( _sprite.parent) {
					_sprite.parent.removeChild(_sprite);
				}
				_sprite = null;
			}
		}
	}
}
