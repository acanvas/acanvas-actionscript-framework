package com.jvm.components.effects 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 *
	 * @author danielhuebschmann
	 * @since	16.01.2011 16:07:17
	 */
	public class Clouds extends Sprite 
	{
		private var _w : Number;
		private var _h : Number;
		private var _bitmapData : BitmapData;
		private var _xOffset : Number = 0;
		private var _point : Point;
		private var _image : Bitmap;

		public function Clouds(w:Number, h:Number)
		{
			//INFO: clear grafix if not needed
			graphics.beginFill(0x0, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			
			_w = w;
			_h = h;
			
			_bitmapData = new BitmapData(_w, _h, true, 0xffFFFFFF);
			_image = new Bitmap(_bitmapData);
			_image.cacheAsBitmap = true;
			addChild(_image);
		}

		public function addMask() : void {
			var mat : Matrix= new Matrix();
			var colors : Array = [0xFFFFFF, 0xFFFFFF];
			var alphas : Array = [.5, 0];
			var ratios : Array = [0, 255];
			mat.createGradientBox(_w, _h);
			var maske : Shape = new Shape();
			maske.graphics.lineStyle();
			maske.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mat);
			maske.graphics.drawEllipse(0, 0, _w, _h);
			maske.graphics.endFill();
			maske.cacheAsBitmap = true;
			addChild(maske);
			_image.mask = maske;
		}

		public function start() : void {
			addEventListener( Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
		}
		
		public function stop() : void {
			removeEventListener( Event.ENTER_FRAME, _onEnterFrame );
		}
		
		private function _onEnterFrame(event : Event) : void 
		{
			_xOffset = _xOffset+1;
			_point = new Point(_xOffset, 0);			//INFO: play around with perlinNoise attributes for different effect
			_bitmapData.perlinNoise(200, 40, 1, 1, true, true, 7, true, [_point, _point]);
		}

	}
}
