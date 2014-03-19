package com.rockdot.project.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.inject.IIOModelAware;
	import com.rockdot.plugin.io.model.IOModel;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;



	public class ProcessImageCommand extends AbstractCommand implements IIOModelAware{
		private var _ioModel : IOModel;

		override public function execute(event : RockdotEvent = null) : * {
			
			super.execute(event);
			
			//copy mask properties
			var image : Bitmap = event.data;
			var maskWidth : Number = image.parent.mask.width;
			var maskHeight : Number = image.parent.mask.height;
			var imageClipRect : Rectangle = new Rectangle(0, 0, maskWidth, maskHeight);
			
			//kill mask (masks skrew up translations)
			image.mask = null;	

			//draw background image
			var bmd : BitmapData = new BitmapData(maskWidth, maskHeight, true, 0xFFFFFF);
			var matrix : Matrix = new Matrix();
			matrix.scale(image.scaleX, image.scaleY);
			matrix.translate( image.x , image.y );
			bmd.draw(image, matrix, null, null, imageClipRect, true);
			
			// draw masked headline onto background image
			var spr : Sprite = _appModel.quote;
			bmd.draw(spr, null, null, BlendMode.LAYER, null, true);

			//create and save bitmap to model
			var bmp : Bitmap = new Bitmap(bmd, PixelSnapping.ALWAYS, true);
			_appModel.image = bmp;
			_ioModel.importedFile.bitmapData.dispose();
			_ioModel.importedFile = null;
			
			//tidy up
			image.bitmapData.dispose();
			image = null;
			
			dispatchCompleteEvent();
			
			return null;
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			if(_appModel.quote){
				_appModel.quote.destroy();
				_appModel.quote = null;
			}
			return super.dispatchCompleteEvent(result);
		}

		public function set ioModel(ioModel : IOModel) : void {
			_ioModel = ioModel;
		}
		
	}
}