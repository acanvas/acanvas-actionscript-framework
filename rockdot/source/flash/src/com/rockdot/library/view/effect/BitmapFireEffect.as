package com.rockdot.library.view.effect {
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;




	/**
	 * @author Nicolas Barradeau
	 */
	public class BitmapFireEffect extends BasicEffect
	{
		private var _frame:int;
		private var _totalFrames:uint = 90;
		
		private var output:BitmapData;
		private var outputBmp:Bitmap;
		private var originalBd:BitmapData;
		private var _burnColor:uint = 0xFFFFAA00;
		private var _burnWidth:int = 2;
		private var __mask:BitmapData;
		
		private var _trails:Boolean = false;
		private var _trailSmooth:Boolean = false;
		private var _trailColor:uint = 0xFFFF6600;
		private var _trailScale:Number = .5;
		private var _trailLength:Number = .5;
		private var _trailDisplacement:Number = 0;
		private var _trailDisplacementX:Number = 0;
		private var _trailDisplacementY:Number = 0;
		
		private var trail:BitmapData;
		private var trailTmp:BitmapData;
		private var trailBmp: Bitmap;
		private var _callback : Function;

		
		public function BitmapFireEffect() {
			_useSprite = true;
			_sprite = new Sprite();
			_applyRecursively = false;
		}
		
		override public function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			_frame = 0;
			if ( duration != -1 ) {
				this.totalFrames =int( duration * 20);
			}
			
			/* impossible to run an InEffect with Fire, so we use simple alpha fadein */
			super.runInEffect(target, duration, callback);
		}

		override public function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void {
			_callback = callback;
			_frame = 0;
			if ( duration != -1 ) {
				this.totalFrames =int( duration * 20);
			}
			
			init(target);

			target.visible = false;
			target.alpha = 0;

			_sprite.addEventListener(Event.ENTER_FRAME, _effect);
		}
		
		public function init( _do:ISpriteComponent, _mask:BitmapData = null ):void
		{
			var rect:Rectangle =  _do.getRect( _do as DisplayObject);
			output = new BitmapData( rect.width, rect.height, true, 0x00000000 );
			originalBd = new BitmapData( rect.width, rect.height, true, 0x00000000 );
			
			var mat:Matrix = _do.transform.matrix;
			_sprite.x = mat.tx;
			_sprite.y = mat.ty;	
			
			mat.tx = mat.ty = 0;
			output.draw( _do, mat );
			originalBd.draw( _do, mat );
			
			var cmf:ColorMatrixFilter;
			if ( _mask == null )
			{
				__mask = output.clone();
				__mask.perlinNoise( 200, 200, 6, Math.random() * 1000, false, true, 7, true );
				cmf = new ColorMatrixFilter( [1.44,0,0,0,-99.94,0,1.44,0,0,-99.94,0,0,1.44,0,-99.94,0,0,0,1,0] );
				__mask.applyFilter( __mask, __mask.rect, new Point(), cmf );
			}
			else
			{
				__mask = output.clone();
				mat.identity();
				if ( output.width > _mask.width || output.height > _mask.height )mat = new Matrix( output.width / _mask.width, 0, 0, output.height / _mask.height );
				__mask.draw( _mask, mat );
				cmf = new ColorMatrixFilter( [0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0] );
				__mask.applyFilter( __mask, __mask.rect, new Point(), cmf );
			}
			
			//if the image's transparency is enabled and if there is at least one transparent pixel
			if( originalBd.threshold( originalBd, originalBd.rect, new Point(), '<=', 0, 0) != 0 )
			{
				__mask.threshold( originalBd, originalBd.rect, new Point(), '<=', 0, 0 );
			}
			
			outputBmp = new Bitmap( output );
			outputBmp.cacheAsBitmap = true;
			_sprite.addChild( outputBmp );
			
			
			
			if ( trails )
			{
				trail = new BitmapData( output.width * trailScale, output.height * trailScale, true, 0 );
				trailBmp = new Bitmap( trail, 'auto', _trailSmooth );
				trailBmp.scaleX = trailBmp.scaleY = 1/trailScale;
				trailBmp.blendMode = BlendMode.ADD;
				_sprite.addChild( trailBmp );
				trailTmp = output.clone();
			}
		}
		
		private function _effect( e:Event ):void
		{
			var val:int;
			var t:Number;
			var color:uint;
			var burning:uint;
			if ( _frame < totalFrames )
			{
				if ( _frame >= 0 )
				{
					t = Number( _frame / totalFrames );
					
					val = int( t * 255 );
					color = 0xFF << 24 | val << 16 | val << 8 | val;
					
					val += burnWidth;
					burning = 0xFF << 24 | val << 16 | val << 8 | val;
					
					//in case original should be updated, or redrawn backwards
					//output.copyPixels( originalBd, output.rect, new Point() );
					// or 
					//output.draw( originalBd );// + , null, new ColorTransform( 1 - t, 1 - t, 1 - t , 1 ) );
					
					output.threshold( __mask, __mask.rect, new Point(), '<', burning, burnColor );
					output.threshold( __mask, __mask.rect, new Point(), '<', color, 0x00000000 );
					
					if ( trails )
					{
						trailTmp.threshold( output, output.rect, new Point(), '==', burnColor, trailColor );
						trail.applyFilter( trail, trail.rect, new Point(), new DisplacementMapFilter( originalBd, null, 1, 2, _trailDisplacementX, _trailDisplacementY ) );
						trailTmp.threshold( output, output.rect, new Point(), '!=', burnColor, 0 );
						trail.draw( trailTmp, new Matrix( trailScale, 0,0, trailScale ) );
						trail.colorTransform( trail.rect, new ColorTransform( 1, 1, 1, 1, 0, 0, 0, -( 255 * trailLength ) ) );
					}
				}
				_frame++;
//				dispatchEvent( new Event( Event.CHANGE ) );
			}
			else 
			{
				_sprite.removeEventListener( Event.ENTER_FRAME, _effect );
//				dispatchEvent( new Event( Event.COMPLETE ) );
				output.dispose();
				__mask.dispose();
				_sprite.removeChild( outputBmp );
				if ( trails )
				{
					trailTmp.dispose();
					trail.dispose();
					_sprite.removeChild( trailBmp );
				}
				
				if(_callback != null){
					_callback.call(this);
				}
			}
		}
		/*********************************************
		
			- params -
		
		*********************************************/
		public function get totalFrames():uint { return _totalFrames; }
		
		public function set totalFrames(value:uint):void 
		{
			_totalFrames = value;
		}
		
		public function get burnWidth():int { return _burnWidth; }
		
		public function set burnWidth(value:int):void 
		{
			_burnWidth = value;
		}
		
		public function get trails():Boolean { return _trails; }
		
		public function set trails(value:Boolean):void 
		{
			_trails = value;
		}
		
		public function get trailColor():uint { return _trailColor; }
		
		public function set trailColor(value:uint):void 
		{
			_trailColor = value;
		}
		
		public function get trailScale():Number { return _trailScale; }
		
		public function set trailScale(value:Number):void 
		{
			_trailScale = value;
		}
		
		public function get trailLength():Number { return _trailLength; }
		
		public function set trailLength(value:Number):void 
		{
			value = ( value > 1 ) ? 1 :  ( value < 0 ) ? 0 : value;
			_trailLength = 1 - value;
		}
		
		public function get trailSmooth():Boolean { return _trailSmooth; }
		
		public function set trailSmooth(value:Boolean):void 
		{
			_trailSmooth = value;
			if ( trailBmp != null ) trailBmp.smoothing = _trailSmooth;
		}
		public function get trailDisplacement():Number { return _trailDisplacement; }
		
		public function set trailDisplacement(value:Number):void 
		{
			_trailDisplacement = _trailDisplacementX = _trailDisplacementY = value;
		}
		public function get trailDisplacementX():Number { return _trailDisplacementX; }
		
		public function set trailDisplacementX(value:Number):void 
		{
			_trailDisplacementX = value;
		}
		
		public function get trailDisplacementY():Number { return _trailDisplacementY; }
		
		public function set trailDisplacementY(value:Number):void 
		{
			_trailDisplacementY = value;
		}
		
		public function get burnColor():uint { return _burnColor; }
		
		public function set burnColor(value:uint):void 
		{
			_burnColor = value;
		}
		
		public function get time():Number { return _frame / totalFrames; }
	}
}
