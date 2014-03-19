// ________________________________________________________________________
//														 	 alexmil.de //

package de.alexmilde.data {
	import flash.events.Event;
	import flash.events.EventDispatcher;
    /**
	* Flash Utilities
	* @author Alexander Milde
	*/

    
	/**
	* The DataQueue Class Manages the loading of an unlimited number of
	* Url Requests
	* The getFile Method returns the loaded File
	*/
	public class DataQueue extends EventDispatcher
	{		
		/**
		* Event Constant all files loaded
		*/
		public static const All_FILES_LOADED:String = "allFilesLoaded";
		
		/**
		* Array for The DataFile.as Objects
		*/
		private var dataFileQueue 	:Array = new Array();
		
		/**
		* Object to store url name ande more in
		*/
		private var dataFile		:DataFile;
		
		/**
		* Data Loader Object to handle the Url request
		*/
		private var dataLoader		:DataLoader = new DataLoader();
		
		/**
		* Counter for the amount of urls
		*/
		private var fileAmount		:uint = 0;
		
		/**
		* Counter for the already loaded url requests
		*/
		private var fileAmountLoaded:uint = 0;
		
		
		/**
		* construct
		*/
		public function DataQueue():void
		{
			this.dataLoader.addEventListener(DataLoader.ONE_FILE_LOADED, loadNext);
		}
		
		/**
		* Adding an url to the queue
		*/
		public function addFile(path:String, name:String, contentType:String) : void
		{
			this.dataFile = new DataFile(path, name, contentType);
			this.dataFileQueue.push(dataFile);
			this.fileAmount++;
		}
		
		/**
		* Startfunction for the queue
		*/
		public function startLoading() : void
		{	
			// file to load and media type
			this.dataLoader.loadFile(this.dataFileQueue[fileAmountLoaded].path, 
										this.dataFileQueue[fileAmountLoaded].contentType);
		}
		
		/**
		* load loop
		*/
		private function loadNext(e:Event):void
		{
			// write data in array
			this.dataFileQueue[fileAmountLoaded].data = this.dataLoader.data;
			
			this.fileAmountLoaded++;
			if(fileAmountLoaded < fileAmount)
			{
				this.startLoading();
			}
			else
			{
				this.dispatchEvent(new Event(DataQueue.All_FILES_LOADED));
			}
		}
		
		/**
		* Returns a file by a represantive name
		*/
		public function getFile(name : String):*
		{
			var iMax:uint = dataFileQueue.length;
			for(var i : int = 0;i < iMax; i++)
			{
				if(this.dataFileQueue[i].name == name)
				{
					return this.dataFileQueue[i].data;
				}
			}			
			return 0;
		}
	}
}
