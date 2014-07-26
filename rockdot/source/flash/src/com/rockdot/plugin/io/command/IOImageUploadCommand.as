package com.rockdot.plugin.io.command {
	import com.quietless.utils.CustomEvent;
	import com.quietless.utils.DynamicBitmap;
	import com.quietless.utils.DynamicBitmapData;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.command.event.vo.IOImageUploadVO;
	import com.rockdot.plugin.ugc.command.AbstractUGCCommand;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.system.System;




	public class IOImageUploadCommand extends AbstractUGCCommand {
		private static const UPLOAD_QUALITY : Number = 90;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			var vos : Array = event.data;
				_upload(vos[0], false);
				_upload(vos[1], true);
//			for (var i:int = 0; i<vos.length;i++){
//				_upload(vos[i], i == vos.length-1);
//			}
		}

		private function _upload(vo : IOImageUploadVO, dispatch : Boolean) : void {
			
			log.debug("System memory: " + System.totalMemory);
			log.debug("Free memory: " + System.freeMemory);
			
			var image : DisplayObject = vo.displayobject;
			var scale : Number = 1;
			if(image.width >= image.height && image.width>vo.width) {
				scale = vo.width / image.width;
			} else if(image.height > image.width && image.height>vo.height) {
				scale = vo.height / image.height;
			}
			
			var dbmp : DynamicBitmapData;

			if(scale != 1){
				
				var matrix : Matrix = new Matrix();
				matrix.scale(scale, scale);
			
				var bmd : BitmapData = new BitmapData(image.width * scale, image.height * scale, false);
				bmd.draw(image, matrix);
				
				dbmp = new DynamicBitmapData(bmd, vo.fileName, UPLOAD_QUALITY);
			}
			else{
				if(image is Bitmap){
					dbmp = new DynamicBitmapData((image as Bitmap).bitmapData, vo.fileName, UPLOAD_QUALITY);
				}
				else{
					dbmp = new DynamicBitmap(image, vo.fileName, UPLOAD_QUALITY);
				}
			}

			
			log.debug("System memory: " + System.totalMemory);
			log.debug("Free memory: " + System.freeMemory);

			// optional listeners to help debug any errors //	
			dbmp.addEventListener('onLoadSuccess', dispatch ? dispatchCompleteEvent : _onLoadedEvent);
			dbmp.addEventListener('onLoadFailure', dispatchErrorEvent);
			dbmp.addEventListener('onSecurityError', dispatchErrorEvent);
			dbmp.addEventListener('ImageConversionFailure', dispatchErrorEvent);

			var script : String = getProperty("project.host.upload");
			dbmp.upload(script);
			
			
		}

		private function _onLoadedEvent(e : CustomEvent) : void {
			log.info("object loaded");
			//dispatchCompleteEvent is called on last element of array, see above
		}
	}
}