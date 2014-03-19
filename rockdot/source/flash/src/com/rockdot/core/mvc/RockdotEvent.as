package com.rockdot.core.mvc {
	import org.as3commons.eventbus.singleton.StaticEventBus;

	import flash.events.Event;

	/**
	 * @author nilsdoehring
	 */
	public class RockdotEvent extends Event {
		private var _callBack : Function;
		private var _data : *;
		
		public function RockdotEvent(type : String, data : * = null, callBack : Function = null) {
			_data = data;
			_callBack = callBack;
			super(type, false, false);
		}
		
		public function dispatch() : void {
			
			StaticEventBus.dispatchEvent(new RockdotEvent( type , _data, _callBack));
		}
		
		public function get completeCallBack() : Function {
			return _callBack;
		}

		public function get data() : * {
			return _data;
		}

		public function listen() : void {
			StaticEventBus.addEventListener(type , _callBack);
		}

		public function unlisten() : void {
			StaticEventBus.removeEventListener(type , _callBack);
		}
	}
}
