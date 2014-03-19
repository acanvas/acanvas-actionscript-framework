package com.rockdot.plugin.io.model {
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	import flash.display.Bitmap;








	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class IOModel{

		protected var _log : ILogger = getLogger(IOModel);

		private var _importedFile : Bitmap;
		public function get importedFile() : Bitmap {
			return _importedFile;
		}
		public function set importedFile(importedFile : Bitmap) : void {
			_importedFile = importedFile;
		}

		public function IOModel() {
		}

	}
}
