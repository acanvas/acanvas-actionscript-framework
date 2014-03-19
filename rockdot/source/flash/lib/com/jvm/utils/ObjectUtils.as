package com.jvm.utils {
	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class ObjectUtils {
		public static function concat(obj1 : Object, obj2 : Object) : Object {
			var o : Object = {};
			addProps(o, obj1);
			addProps(o, obj2);
			return o;
		}


		public static function addProps(obj1 : Object, obj2 : Object) : void {
			for (var i : String in obj2) {
				obj1[i] = obj2[i];
			}
		}


		public static function removeProps(obj : Object, keys : Array) : void {
			for (var i : String in keys) {
				delete obj[keys[i]];
			}
		}


		public static function log(obj : Object, logMethod : Function = null, keys : Array = null) : void {
			logMethod ||= trace;
			var values : String;
			for (var key : String in obj) {
				if (keys) {
					values = "[" + key + "]";
					for (var i : int = 0; i < keys.length; i++) {
						values += " [" + keys[i] + "] = " + obj[key][keys[i]] + ", ";
					}
					logMethod(values);
				} else {
					logMethod("[" + key + "] = " + obj[key]);
				}
			}
		}
	}
}
