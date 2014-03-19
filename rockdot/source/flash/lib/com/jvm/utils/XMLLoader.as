package com.jvm.utils {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class XMLLoader extends URLLoader {
		private var _xml : XML;
		private var _onComplete : Function;
		private var _onError : Function;

		public function XMLLoader() {
			XML.ignoreWhitespace = true;
			XML.ignoreComments = true;
		}

		
		public function loadXML(url : String, onComplete : Function, onError : Function = null) : void {
			if (url == "" || url == null) {
				_errorHandler("URL must not be null or ''.");
				return;
			}
			
			_onComplete = onComplete;
			_onError = onError;
			
			addEventListener(Event.COMPLETE, _onXMLLoaded);
			addEventListener(IOErrorEvent.IO_ERROR, _onXMLIOError);
		
			try {
				load(new URLRequest(url));
			}
            catch (error : SecurityError) {
				_errorHandler("A SecurityError has occurred.\n" + error.message);
			}
		}

		
		private function _onXMLLoaded(event : Event) : void {
			var sucess : Boolean;
			try {				_xml = new XML(event.target.data);
				sucess = true;			}
			catch (error : TypeError) {
				sucess = false;
				_errorHandler("Loaded file is corrupt /not a valid XML.\n" + error.message);
			}
			
			if (sucess)				_onComplete(_xml);		}

		
		private function _onXMLIOError(event : IOErrorEvent) : void {
			_errorHandler(event.text);		}

		
		private function _errorHandler(msg : String) : void {
			trace("[XMLLoader]: ERROR - " + msg);
			if (_onError != null) {
				_onError(msg);
			}
		}

		
		public function get xml() : XML {
			return _xml;
		}
	}
}
