// ________________________________________________________________________
//															 alexmil.de //

package de.alexmilde.data {
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
    /**
	* Flash Utilities
	* @author Alexander Milde
	*/

	
	/**
	* The DataLoader Class Dispatches when a file is Loaded
	* The fileformat is fully flexible (eg.XML HTML CSS TXT jpg png ...)
	*/
	public class DataLoader extends EventDispatcher
	{	
		/**
		* Event Constant single file loaded
		*/
		public static const ONE_FILE_LOADED:String = "oneFileLoaded";
		
		/**
		* Loader Constant media
		*/
		public static const CONTENTTYPE_MEDIA:String = "media";
		
		/**
		* The data that will be returned
		*/	
		private var data_ 			:*;
		
		/**
		* UrlRequest
		*/
		private var urlRequest		:URLRequest;
		
		/**
		* UrlLoader
		*/
		private var textLoader		:URLLoader;
		
		/**
		* Media Loader currently not supportet
		*/
		private var mediaLoader		:Loader;
		
		/**
		*  Data Loader constructor
		*/
		public function DataLoader()
		{
		}
		
		/**
		* loadfile function manages the loading of a file
		* loader switch wether the file ist textbased or not
		*
		* @param path Path of the File
		* @param contentType Type of Media
		*/
		public function loadFile(path:String, contentType:String):void
		{
			// parse as text when it has no media strin as tag
			if(contentType != DataLoader.CONTENTTYPE_MEDIA)
			{
				this.urlRequest = new URLRequest(path);
				this.textLoader = new URLLoader();
				this.textLoader.load(this.urlRequest);
				this.textLoader.addEventListener(Event.COMPLETE, textfileLoaded);
				this.textLoader.addEventListener(IOErrorEvent.IO_ERROR, nullFile);	
			}
			else
			{
				this.urlRequest = new URLRequest(path);
				this.mediaLoader = new Loader();
				this.mediaLoader.contentLoaderInfo.addEventListener(Event.INIT, mediafileLoaded);	
				this.mediaLoader.load(this.urlRequest);
				this.mediaLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, nullFile);	
			}
		}
		
		/**
		*  textfile loaded
		*/
		private function textfileLoaded(event:Event):void
		{
			this.data_ = textLoader.data;
			dispatchEvent(new Event(DataLoader.ONE_FILE_LOADED));
		}
		
		/**
		*  mediafile loaded
		*/
		private function mediafileLoaded(event:Event):void
		{
			this.data_ = mediaLoader.content;	
			dispatchEvent(new Event(DataLoader.ONE_FILE_LOADED));
		}		

		/**
		*  file wasnt loaded -> filecontent = 0
		*/
		private function nullFile(event:ErrorEvent):void
		{
			this.data_ = null;
			dispatchEvent(new Event(DataLoader.ONE_FILE_LOADED));
		}
		
		/**
		* returns the loaded datafile
		*/
		public function get data():*
		{
			return this.data_;
		}
	}
}
