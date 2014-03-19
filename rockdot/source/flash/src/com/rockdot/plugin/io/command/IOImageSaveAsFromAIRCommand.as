package com.rockdot.plugin.io.command {
	import com.adobe.images.JPGEncoder;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.command.event.vo.IOImageSaveAsVO;
	import com.rockdot.plugin.ugc.command.AbstractUGCCommand;

	import org.as3commons.lang.Assert;

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class IOImageSaveAsFromAIRCommand extends AbstractUGCCommand {
		private var _jpg : ByteArray;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			Assert.instanceOf(event.data, IOImageSaveAsVO, "Command requires an IOImageSaveAsVO as event.data parameter.");

			var vo : IOImageSaveAsVO = event.data;
			_jpg = new JPGEncoder(90).encode(vo.bitmapData);

			var docsDir : File = File.documentsDirectory.resolvePath(vo.fileName);

			try {
				docsDir.browseForSave("Save As");
				docsDir.addEventListener(Event.SELECT, _saveData);
			} catch (error : Error) {
				trace("Failed:", error.message);
			}
		}

		private function _saveData(event : Event) : void {
			var newFile : File = event.target as File;
			if (!newFile.exists) // remove this 'if' if overwrite is OK.
			{
				var stream : FileStream = new FileStream();
				stream.open(newFile, FileMode.WRITE);
				stream.writeBytes(_jpg);
				stream.close();
				dispatchCompleteEvent();
			} else {
				dispatchErrorEvent('Selected path already exists.');
			}
		}
	}
}