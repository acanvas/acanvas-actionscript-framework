package com.jvm.utils {
	import flash.utils.Dictionary;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class Cache extends Object {
		private var _cache : Dictionary;

		public function Cache() {
			_cache = new Dictionary();
		}


		public function addItem(key : String, value : *) : * {
			_cache[key] = value;
			return value;
		}


		public function removeItem(key : String) : * {
			var item : * = getItem(key);
			delete _cache[key];
			return item;
		}


		public function getItem(key : String) : * {
			return _cache[key];
		}


		public function clear() : void {
			_cache = new Dictionary();
		}


		public function every(callback : Function) : void {
			for (var key : String in _cache) {
				callback(key, _cache[key]);
			}
		}


		public function dumpContent() : void {
			for (var key : String in _cache) {
				trace("[Cache]: INFO: [" + key + "] = " + _cache[key]);
			}
		}
	}
}
