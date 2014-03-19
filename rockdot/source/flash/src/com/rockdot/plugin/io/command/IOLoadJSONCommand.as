package com.rockdot.plugin.io.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;


	public class IOLoadJSONCommand extends AbstractIOCommand {
		private var _jsonLoader : URLLoader;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			_jsonLoader = new URLLoader();
			_jsonLoader.addEventListener(Event.COMPLETE, _onFileLoaded);
			_jsonLoader.load(new URLRequest(event.data));
			//TODO check security, show or load fallbacks
		}

		private function _onFileLoaded(event : Event) : void {
			var loader:URLLoader = URLLoader(event.target);
			var jsonObject:Object = JSON.parse(loader.data);
			dispatchCompleteEvent(jsonObject);
		}
	}
}