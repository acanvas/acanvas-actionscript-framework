package com.jvm.utils {
	import flash.system.Capabilities;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class DeviceDetector {
		public static function get VERSION() : String {
			return Capabilities.version;
		}

		public static function get IS_AIR() : Boolean {
			return IS_MOBILE || IS_DESKTOP;
		}
		
		public static function get IS_MOBILE() : Boolean {
			return IS_IOS || IS_ANDROID;
		}

		public static function get IS_DESKTOP() : Boolean {
			return Capabilities.playerType == "Desktop";
		}

		public static function get IS_IOS() : Boolean {
			return (Capabilities.version).substr(0, 3) == "IOS";
		}

		public static function get IS_ANDROID() : Boolean {
			return  (Capabilities.version).substr(0, 3) == "AND";
		}
	}
}
