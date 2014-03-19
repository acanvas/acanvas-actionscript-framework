package com.rockdot.library.view.component.common {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.command.event.IOEvents;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;
	import com.rockdot.plugin.state.command.event.StateEvents;

	import org.as3commons.lang.Assert;

	import flash.display.Bitmap;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MediaEvent;
	import flash.media.CameraUI;
	import flash.media.MediaType;
	import flash.system.System;





	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author 	Nils Doehring (nilsdoehring(at)gmail.com)
	 * @since	04.05.2011
	 */
	public class ComponentCameraUI extends SpriteComponent {
		private var _bandwidth : uint;
		private var _quality : uint;
		private var _fps : uint;
		private var _camUI : CameraUI;

		public function ComponentCameraUI(bandwith : uint = 0, quality : uint = 0, fps : uint = 15) {
			super();
			
			_bandwidth = bandwith;
			_quality = quality;
			_fps = fps;

			if ( CameraUI.isSupported ) {
				_camUI = new CameraUI();

				_camUI.addEventListener(MediaEvent.COMPLETE, imageCaptured);
				_camUI.addEventListener(Event.CANCEL, captureCanceled);
				_camUI.addEventListener(ErrorEvent.ERROR, cameraError);
				_camUI.launch(MediaType.IMAGE);
			} else {
				_log.debug("No camera is installed.");
			}
		}

		private function imageCaptured(event : MediaEvent) : void {
			(event.target as IEventDispatcher).removeEventListener(MediaEvent.COMPLETE, imageCaptured);
			new RockdotEvent(IOEvents.LOAD_MEDIAPROMISE, event.data, _onMediaPromiseLoaded).dispatch();
		}

		private function _onMediaPromiseLoaded(image : Bitmap) : void {
			Assert.notNull(image, "Loaded image is null");
			new RockdotEvent(IOEvents.MEMORY_CLEAR).dispatch();
			
//			addChild(image);
			
//			var matrix : Matrix = new Matrix();
//			var scale : Number = 1;
//			if(image.width > image.height && image.width>_width) {
//				scale = _width / image.width;
//			} else if(image.height > image.width && image.height>_height) {
//				scale = _height / image.height;
//			}
//			matrix.scale(scale, scale);
//			
//			var bmd : BitmapData = new BitmapData(image.width * scale, image.height * scale, false);
//			bmd.draw(image, matrix);
//			addChild(new Bitmap(bmd, PixelSnapping.ALWAYS, true));
//			
//			image.bitmapData.dispose();
			_log.debug("System memory: " + System.totalMemory);
			_log.debug("Free memory: " + System.freeMemory);
			_submitCallback.call(null, image);
		}

		private function captureCanceled(event : Event) : void {
			_log.debug("Media capture canceled.");
			new RockdotEvent(StateEvents.ADDRESS_SET, "/").dispatch();
		}

		private function cameraError(error : ErrorEvent) : void {
			_log.debug("Error:" + error.text);
			new RockdotEvent(StateEvents.ADDRESS_SET, "/").dispatch();
		}
	}
}
