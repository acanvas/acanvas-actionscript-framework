package com.rockdot.plugin.io.command {
	import jp.shichiseki.exif.ExifUtils;

	import com.rockdot.core.mvc.RockdotEvent;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class IOLoadFileFromBrowserCommand extends AbstractIOCommand {
		private var _file : FileReference;
		private var _fileLoader : Loader;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			_file = new FileReference();
			_file.addEventListener(Event.SELECT, _selectFile);

			var imageFileTypes : FileFilter = new FileFilter("Images (*.jpg, *.png)", "*.jpg;*.png");
			_file.browse([imageFileTypes]);
		}

		private function _selectFile(e : Event) : void {
			_file.addEventListener(Event.COMPLETE, _loadFileReferenceComplete);
			_file.load();
		}

		private function _loadFileReferenceComplete(e : Event) : void {
		    _file.removeEventListener(Event.COMPLETE, _loadFileReferenceComplete);

			_fileLoader = new Loader();
			_fileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onFileLoaded);
			_fileLoader.loadBytes(_file.data);
		}
		
		private function _onFileLoaded(e : Event) : void {
			var eb : ByteArray = new ByteArray();
			_file.data.readBytes(eb, 0, Math.min(_file.data.length, 64 * 1024));

			var bmp : Bitmap = ExifUtils.getEyeOrientedBitmap(_fileLoader.content as Bitmap, eb);

			_ioModel.importedFile = bmp;
			dispatchCompleteEvent(bmp);
		
		}
	}
}