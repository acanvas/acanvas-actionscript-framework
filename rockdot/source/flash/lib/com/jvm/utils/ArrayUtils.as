package com.jvm.utils {
	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 * 
	 * @version 1.1, Daniel Huebschmann
	 */
	public class ArrayUtils {
		public static function shuffle(array : Array) : Array {
			var clone : Array = clone(array);
			var shuffle : Array = [];
			while (clone.length > 0) {
				shuffle.push(clone.splice(Math.floor(Math.random() * clone.length), 1)[0]);
			}
			return shuffle;
		}


		public static function clone(array : Array) : Array {
			return array.slice();
		}


		public static function containsItem(array : Array, item : Object) : Boolean {
			return (array.indexOf(item) != -1);
		}


		public static function removeItemFromIndex(array : Array, index : uint) : Array {
			array.splice(index, 1);
			return array;
		}


		public static function removeItemFrom(array : Array, item : Object) : void {
			var len : uint = array.length;
			for (var i : uint = 0; i < len; i++) {
				if (array[i] === item) removeItemFromIndex(array, i);
			}
		}


		public static function areEqual(arr1 : Array, arr2 : Array) : Boolean {
			if (arr1.length != arr2.length) return false;
			var len : uint = arr1.length;
			for (var i : uint = 0; i < len; i++) {
				if (arr1[i] !== arr2[i]) return false;
			}
			return true;
		}
	}
}
