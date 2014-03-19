package com.jvm.components {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class ReflectionBitmap extends Bitmap {
		private static const REFLECTION_Y_SCALE : Number = 1;
		private static const REFLECTION_ALPHA : Number = .4;
		private static const COLORS : Array = [0, 0xffffff];
		private static const ALPHAS : Array = [.8, 0];
		private static const RATIOS : Array = [0, 255];
		private var _reflection_rectangle : Rectangle;
		private var _reflection_matrix : Matrix;
		private var _reflection_color_trans : ColorTransform;
		private var _source : DisplayObject;
		private var _matrix : Matrix;
		private var _reflectMask : Shape;
		private var _reflectionHeight : int;
		private var _floor : int;

		public function ReflectionBitmap(source : DisplayObject, w : Number = 0 , h : Number = 0, reflectionHeight : int = 70) {
			pixelSnapping = PixelSnapping.NEVER;
			
			_source = source;
			_reflectionHeight = reflectionHeight;
			
			_reflection_matrix = new Matrix();
			_reflection_matrix.scale(-1, REFLECTION_Y_SCALE);
			_reflection_matrix.rotate(Math.PI);
			
			_matrix = new Matrix();
			_reflectMask = new Shape();
			_reflection_rectangle = new Rectangle();
			_reflection_color_trans = new ColorTransform(1, 1, 1, REFLECTION_ALPHA);
			
			update(w, h);
			updateLocation();
		}

		
		public function update( w : Number = 0, h : Number = 0 ) : void {
			var _width : Number = w == 0 ? _source.width : w;
			var _height : Number = h == 0 ? _source.height : h;
			
			_reflection_rectangle.width = _width;
			_reflection_rectangle.height = _reflectionHeight;
			_reflection_matrix.ty = _height;
			
			_matrix.createGradientBox(_width, _reflectionHeight, Math.PI * .5, 0, 0);
			
			var g : Graphics = _reflectMask.graphics;
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, COLORS, ALPHAS, RATIOS, _matrix);
			g.drawRect(0, 0, _width, _reflectionHeight);
			g.endFill();
			_reflectMask.y = _height;
			
			if(bitmapData) bitmapData.dispose();
			
			var bmd : BitmapData = new BitmapData(_width, _reflectionHeight, true, 0x0);
			bmd.draw(_source, _reflection_matrix, _reflection_color_trans, null, _reflection_rectangle, true);
			bmd.draw(_reflectMask, null, null, BlendMode.ALPHA);
			
			bitmapData = bmd;
		}

		
		public function set floor(value : int) : void {
			_floor = value;
		}

		
		public function get floor() : int {
			return _floor;
		}

		
		public function updateLocation() : void {
			x = _source.x;
			y = _floor == 0 ? _source.y + _source.height : _floor + _floor - _source.y - _source.height;
		}
	}
}
