package com.rockdot.plugin.io.command.event {

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class IOEvents {
		
		//expects nothing
		public static const INIT : String 					= "IOEvents.INIT";
		
		//expects URL String, e.g. "http://url.com/img.jpg", returns _fileLoader.content 
		//sets IOModel.importedFile to _fileLoader, uses URLRequest
		public static const IMAGE_LOAD_WEB : String 		= "IOEvents.IMAGE_LOAD_WEB";

		//expects nothing, returns _fileLoader.content (and sets IOModel.importedFile to _fileLoader)
		public static const IMAGE_LOAD_DISK : String 		= "IOEvents.IMAGE_LOAD_DISK";
		public static const LOAD_MEDIAPROMISE : String 		= "IOEvents.LOAD_MEDIAPROMISE";
		public static const LOAD_JSON : String 				= "IOEvents.LOAD_JSON";

		public static const IMAGE_SAVE_LOCAL : String 		= "IOEvents.IMAGE_SAVE_LOCAL";
		
		//expects Array<DAOUGCImageUpload>, mostly a picture and a thumb. 
		//uploads need to happen within the same command (event phase) to avoid security sandbox violations
		//thus the crappy Array instead of two clean commands.
		
		public static const IMAGE_UPLOAD : String 			= "IOEvents.IMAGE_UPLOAD";
		
		//expects VOIOURLOpen
		public static const URL_OPEN : String 				= "IOEvents.URL_OPEN";
		
		public static const MEMORY_CLEAR : String 			= "IOEvents.MEMORY_CLEAR";

	}
}
