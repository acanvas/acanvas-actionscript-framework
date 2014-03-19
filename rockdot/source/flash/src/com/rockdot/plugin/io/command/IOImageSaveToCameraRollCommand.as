package com.rockdot.plugin.io.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.command.AbstractUGCCommand;

	import org.as3commons.lang.Assert;

	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.CameraRoll;
	import flash.utils.ByteArray;

	public class IOImageSaveToCameraRollCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			//TODO make this take BitmapData, as with Desktop
			Assert.instanceOf(event.data, LoaderInfo, "On Mobile, we save LoaderInfo");			
			
			var loaderInfo : LoaderInfo = event.data;

			if (CameraRoll.supportsAddBitmapData) {
		 
				var bitmapData:BitmapData = new BitmapData(loaderInfo.width, loaderInfo.height);
				bitmapData.draw(loaderInfo.loader);
				var file:File = File.applicationStorageDirectory.resolvePath("image" + new Date().time + ".jpg");
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				var bytes:ByteArray = bitmapData.encode(bitmapData.rect, new flash.display.JPEGEncoderOptions());
				stream.writeBytes(bytes, 0, bytes.bytesAvailable);
				stream.close();
		 
			}
			
			dispatchCompleteEvent();
		}

	}
}