package com.jvm.utils {
	import flash.utils.Dictionary;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class SortedDictionary extends Object {
		private var _dict : Dictionary;

		public function SortedDictionary() {
			_dict = new Dictionary();
		}


		public function addItem(key : String, value : *) : * {
			_dict[key] = new SortedDictionaryItem(key, value);
			return value;
		}


		public function removeItem(key : String) : * {
			var item : * = getItem(key); 
			delete _dict[key];
			return item;
		}


		public function getItem(key : String) : * {
			var item : * = _dict[key];
			return item == undefined ? null : _dict[key].value;
		}


		public function clear() : void {
			_dict = new Dictionary();
		}


		public function every(callback : Function) : void {
			for (var key : String in _dict) {
				callback(key, _dict[key].value);
			}
		}


		private function _getSortedItems() : Array {
			var a : Array = [];
			for (var key : String in _dict) {
				a.push(_dict[key]);
			}

			a.sortOn("itemCount", Array.NUMERIC);
			return a;
		}


		public function getSortedValues() : Array {
			var a : Array = _getSortedItems();
			var result : Array = [];
			var n : uint = a.length;
			for (var i : int = 0; i < n; i++) {
				result[i] = a[i].value;
			}
			
			return result;
		}


		public function dumpContent() : void {
			var a : Array = _getSortedItems();
			var n : int = a.length;
			
			for (var i : int = 0; i < n; i++) {
				 trace("[SortedDictionary]: INFO: [" + a[i].key + "] = " + a[i].value + " itemCount:" + a[i].itemCount);
			}
		}
	}
}
class SortedDictionaryItem {
	public static var count : uint;
	private var _itemCount : uint;
	private var _key : String;
	private var _value : *;

	public function SortedDictionaryItem(key : String, value : *) {
		_key = key;
		_value = value;
		_itemCount = count++;
	}


	public function get key() : String {
		return _key;
	}


	public function get value() : * {
		return _value;
	}


	public function get itemCount() : uint {
		return _itemCount;
	}
}