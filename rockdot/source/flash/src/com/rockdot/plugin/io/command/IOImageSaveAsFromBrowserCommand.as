package com.rockdot.plugin.io.command {
	import com.adobe.images.JPGEncoder;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.command.event.vo.IOImageSaveAsVO;
	import com.rockdot.plugin.ugc.command.AbstractUGCCommand;

	import org.as3commons.lang.Assert;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class IOImageSaveAsFromBrowserCommand extends AbstractUGCCommand {
		private var _jpg : ByteArray;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			Assert.instanceOf(event.data, IOImageSaveAsVO, "Command requires an IOImageSaveAsVO as event.data parameter.");

			var vo : IOImageSaveAsVO = event.data;
			_jpg = new JPGEncoder(90).encode(vo.bitmapData);

			var saveFile : FileReference = new FileReference();
			saveFile.addEventListener(Event.COMPLETE, _onSaveComplete);
			saveFile.addEventListener(IOErrorEvent.IO_ERROR, _onSaveIOError);
			saveFile.save(_jpg, vo.fileName);
		}

		private function _onSaveComplete(event : Event) : void {
				dispatchCompleteEvent();
		}
		
		private function _onSaveIOError(event : IOErrorEvent) : void {
			dispatchErrorEvent('IOError: ' + event.text);
		}

	}
}