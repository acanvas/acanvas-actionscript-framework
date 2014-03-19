package com.jvm.utils {
	/**
	 * @author thomas.eckhardt
	 * @since 19.01.2009 10:34:34
	 * 
	 * @version 1.1, Simon Schmid 
	 * @version 1.2, Simon Schmid
	 * @version 1.3, Simon Schmid (contact(at)sschmid.com)
	 */
	public class UrlUtils {
		protected static var _prefixes : Array = ["http://", "https://", "ftp://", "mailto:"];

		/**
		 * @see addHyperlinkPrefix()
		 */
		public static function isHyperlink(str : String) : Boolean {
			var temp : String;
			for each (var prefix : String in _prefixes) {
				temp = str;
				if (temp.substr(0, prefix.length) == prefix)
					return true;
			}

			return false;
		}


		/**
		 * add prefixes to indicate hyperlinks
		 * e.g.: "pdf/"
		 * 
		 * Already added by default:
		 * "http://", "ftp://", "mailto:"
		 */
		public static function addHyperlinkPrefix(prefix : String) : void {
			_prefixes.push(prefix);
		}


		public static function equalizeURL(str : String) : String {
			if (str.length > 1) {
				if (str.charAt(str.length - 1) == "/") {
					str = str.substr(0, str.length - 1);
				}
			}
			return str.toLowerCase();
		}


		/**
		 * INFO - Gibt von einer übergebenen baseUrl das Ziel der gewünschten Ebene zurück
		 * 
		 * ("", 0)						returns "/"
		 * ("", 1)						returns null
		 * ("/", 0) 					returns "/"
		 * ("/", 1) 					returns null
		 * ("/level1/level2/level3", 0)	returns "/"
		 * ("/level1/level2/level3", 1) returns "/level1"
		 * ("/level1/level2/level3", 2)	returns "/level2"
		 * ("/level1/level2/level3", 3)	returns "/level3"
		 * ("/level1/level2/level3", 4)	returns null
		 */
		public static function getUrlByLevel(url : String, level : uint) : String {
			if ( url == null ) {
				return null;
			}

			var levelUrls : Array = url.split("/");
			if ( levelUrls.length <= level ) {
				return null;
			} else {
				return  "/" + levelUrls[ level ];
			}
		}


		/**
		 * INFO - Gibt von einer übergebenen baseUrl die Ziele bis zur gewünschten Ebene zurück
		 * 
		 * ("", 0) 						returns "/"
		 * ("", 1) 						returns null
		 * ("/", 0) 					returns "pflege/"
		 * ("/", 1) 					returns null
		 * ("/level1/level2/level3", 0)	returns "/"
		 * ("/level1/level2/level3", 1)	returns "/level1"
		 * ("/level1/level2/level3", 2)	returns "/level1/level2"
		 * ("/level1/level2/level3", 3)	returns "/level1/level2/level3"
		 * ("/level1/level2/level3", 4)	returns null
		 */
		public static function getUrlUpToLevel(url : String, level : uint) : String {
			if ( url == null ) {
				return null;
			}

			var levelUrls : Array = url.split("/");
			var returningUrl : String = "";

			if ( level >= levelUrls.length ) {
				trace("[UrlUtils] WARNING: Level [" + level + "] not available:::url = " + url);
				return null;
			}
			returningUrl = levelUrls.slice(0, level + 1).join("/");

			return returningUrl.length == 0 ? "/" : returningUrl;
		}


		public static function getUrlLevel(url : String) : uint {
			return url.split("/").length - 1;
		}
	}
}
