package com.jvm.view {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class CopyPixelBitmap extends Bitmap {
		protected var _source : BitmapData;
		protected var _rect : Rectangle;
		protected var _fillColor : uint;
		//
		protected static const PT : Point = new Point();

		public function CopyPixelBitmap(source : *, w : int, h : int, fillRectColor : uint = 0xFFFFFFFF, transparent : Boolean = false, pixelSnapping : String = "auto", smoothing : Boolean = false) {
			if (source is BitmapData) {
				_source = source;
			} else {
				_source = new BitmapData(source.width, source.height, transparent, fillRectColor);
				_source.draw(source);
			}

			_rect = new Rectangle(0, 0, w, h);
			_fillColor = fillRectColor;

			super(new BitmapData(w, h, transparent, fillRectColor), pixelSnapping, smoothing);
			render();
		}


		public function render() : void {
			bitmapData.lock();
			bitmapData.fillRect(_rect, _fillColor);
			bitmapData.copyPixels(_source, _rect, PT);
			bitmapData.unlock();
		}


		public function get sourceX() : Number {
			return -_rect.x;
		}


		public function set sourceX(value : Number) : void {
			_rect.x = -value;
			render();
		}


		public function get sourceY() : Number {
			return -_rect.y;
		}


		public function set sourceY(value : Number) : void {
			_rect.y = -value;
			render();
		}


		public function position(tx : Number, ty : Number) : void {
			_rect.x = -tx;
			_rect.y = -ty;
			render();
		}
	}
}
