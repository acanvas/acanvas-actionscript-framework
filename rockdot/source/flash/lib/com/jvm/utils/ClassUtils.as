package com.jvm.utils {
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class ClassUtils {
		public static function getClassName(obj : *) : String {
			return getQualifiedClassName(obj).split("::")[1];		}

		
		public static function getPackage(obj : *) : String {			return getQualifiedClassName(obj).split("::")[0];
		}
	}
}
