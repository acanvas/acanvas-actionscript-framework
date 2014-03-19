package com.rockdot.plugin.io.command {
	import com.rockdot.core.mvc.RockdotEvent;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;


	public class IOLoadImageCommand extends AbstractIOCommand {
		private var _fileLoader : Loader;

		override public function execute(event : RockdotEvent = null) : * {
			_fileLoader = new Loader();
			_fileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onFileLoaded);
			_fileLoader.load(new URLRequest(event.data), new LoaderContext(true));
			//TODO check security, show or load fallbacks
		}

		private function _onFileLoaded(event : Event) : void {
			if(_fileLoader.content) {
				_ioModel.importedFile = _fileLoader.content as Bitmap;
				dispatchCompleteEvent(_fileLoader.content);
			} else {
				
				dispatchErrorEvent("file could not be loaded.");
			}
		}
	}
}