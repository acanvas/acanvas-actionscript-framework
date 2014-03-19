package com.rockdot.plugin.io.command {
	import jp.shichiseki.exif.ExifInfo;
	import jp.shichiseki.exif.ExifUtils;
	import jp.shichiseki.exif.IFD;

	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.command.event.IOEvents;
	import com.rockdot.plugin.screen.common.command.AbstractScreenCommand;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.MediaPromise;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	public class IOLoadMediaPromiseCommand extends AbstractScreenCommand {
		private var _filePromiseLoader : Loader;
		private var _mediaPromise : MediaPromise;
		private var _fileEXIF : IDataInput;
		private var _mediaDispatcher : IEventDispatcher;
		private var _exifBytes : ByteArray;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			log.debug("System memory: " + System.totalMemory);
			log.debug("Free memory: " + System.freeMemory);

			_filePromiseLoader = new Loader();
			_mediaPromise = event.data;
			_exifBytes = new ByteArray();

			if ( _mediaPromise.isAsync ) {
				log.debug("Asynchronous media promise.");
				_mediaDispatcher = _mediaPromise.open() as IEventDispatcher;
				_mediaDispatcher.addEventListener(ProgressEvent.PROGRESS, _onEXIFProgress);
				_mediaDispatcher.addEventListener(Event.COMPLETE, _onPromiseLoaded);
			} else {
				log.debug("Synchronous media promise.");
				var input : IDataInput = _mediaPromise.open();
				input.readBytes(_exifBytes, 0, Math.min(input.bytesAvailable, 64 * 1024));
				_mediaPromise.close();
				_loadFilePromise();
			}
		}

		private function _onEXIFProgress(event : ProgressEvent) : void {
			var input : IDataInput = event.target as IDataInput;
			input.readBytes(_exifBytes, _exifBytes.length, input.bytesAvailable);
			if (_exifBytes.length >= (64 * 1024)) {
				IEventDispatcher(event.target).removeEventListener(ProgressEvent.PROGRESS, _onEXIFProgress);
//				_mediaPromise.close();
//				_loadFilePromise();
			}
		}
		
		private function _onPromiseLoaded(event : Event) : void {
//			event.target.readBytes(_exifBytes, 0, 64 * 1024);;
//			_mediaPromise.close();
			_loadFilePromise();
		}

		private function _loadFilePromise() : void {
			log.debug("Exif loaded.");

			_filePromiseLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onFilePromiseLoaded);
			_filePromiseLoader.addEventListener(IOErrorEvent.IO_ERROR, _onFilePromiseLoadError);
			_filePromiseLoader.loadFilePromise(_mediaPromise);
		}

		private function _onFilePromiseLoaded(event : Event) : void {
			log.debug("System memory before FilePromise: " + System.totalMemory);
			log.debug("Free memory before FilePromise: " + System.freeMemory);

			_filePromiseLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onFilePromiseLoaded);
			_filePromiseLoader.removeEventListener(IOErrorEvent.IO_ERROR, _onFilePromiseLoadError);

			var image : Bitmap = _filePromiseLoader.content as Bitmap;
			var scale : Number = 1;

			if (image.width >= image.height && image.width > RockdotConstants.UPLOAD_WIDTH_MAX) {
				scale = RockdotConstants.UPLOAD_WIDTH_MAX / image.width;
			} else if (image.height > image.width && image.height > RockdotConstants.UPLOAD_HEIGHT_MAX) {
				scale = RockdotConstants.UPLOAD_HEIGHT_MAX / image.height;
			}

			var bmp : Bitmap = ExifUtils.getEyeOrientedBitmap(image, _exifBytes, scale);

			new RockdotEvent(IOEvents.MEMORY_CLEAR).dispatch();

			dispatchCompleteEvent(bmp);
		}

		private function _onFilePromiseLoadError(error : ErrorEvent) : void {
			_callback.call(null, null, null);
			dispatchErrorEvent(error.text);
		}

		private function _parseEXIF(eb : ByteArray) : void {
			var exifInfo : ExifInfo = new ExifInfo(eb);
			if (exifInfo.ifds.thumbnail) {
				var thumbnailLoader : Loader = new Loader();
				var complete : Function = function(e : Event) : void {
					thumbnailLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete);
//					imageDisplay.width = thumbnailLoader.contentLoaderInfo.width;
//					imageDisplay.height = thumbnailLoader.contentLoaderInfo.height;
//					imageDisplay.source = thumbnailLoader;
				};
				thumbnailLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
				thumbnailLoader.loadBytes(exifInfo.thumbnailData);
			}
			var exifData : Array = new Array();
			this.iterateTags(exifInfo.ifds.primary, exifData);
			this.iterateTags(exifInfo.ifds.exif, exifData);
			this.iterateTags(exifInfo.ifds.gps, exifData);
			this.iterateTags(exifInfo.ifds.interoperability, exifData);
			this.iterateTags(exifInfo.ifds.thumbnail, exifData);
		}

		private function iterateTags(ifd : IFD, exifData : Array) : void {
			if (!ifd) return;
			for (var entry:String in ifd) {
				if (entry == "MakerNote") continue;
				exifData.push(entry + ": " + ifd[entry]);
				log.debug(entry + ": " + ifd[entry]);
			}
		}
	}
}