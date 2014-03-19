// ________________________________________________________________________
//															 alexmil.de //

package de.alexmilde.data
{
    /**
	* Flash Utilities
	* @author Alexander Milde
	*/
    
	/**
	* Datafile holds information to an urlRequest
	*/
	public class DataFile 
	{
		/**
		* path to the file thepath.fileending
		*/
		private var path_			:String;
		
		/**
		* representative name for the file
		*/
		private var name_			:String;
		
		/**
		* dataobject for any datatype
		*/
		private var data_			:*;
		
		/**
		* type of url content (eg xml jpg)
		*/
		private var contentType_	:String;
		
		/**
		* setup the Datafile
		* @param path			path to the file
		* @param name			representative name
		* @param contentTpe		type of content
		*/
		public function DataFile(path:String, name:String, contentType:String):void
		{
			this.path_ = path;
			this.name_ = name;
			this.contentType_ = contentType;
		}
		
		/**
		* get the path
		*/
		public function get path():String
		{
			return this.path_;
		}
		
		/**
		* get the name
		*/
		public function get name():String
		{
			return this.name_;
		}

		/**
		* get the data
		*/
		public function get data():*
		{
			return this.data_;
		}

		/**
		* get the content type
		*/
		public function get contentType():String
		{
			return this.contentType_;
		}

		/**
		* set the content type
		*/
		public function set data(data:*):void
		{
			this.data_ = data;
		}
	}
}