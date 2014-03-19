package com.rockdot.library.view.util {

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class FormValidation {
		public static function isValidMail( s : String ) : Boolean {
			var pattern : RegExp = /(\w|[_.\-])+@((\w|-)+\.)+\w{2,4}+/;
			var result : * = pattern.exec(s);
			if (result)
				return true;
			return false;
		}

		
		public static function multiPartMailCheck(name : String, domain : String) : Boolean {
			var seperator : String = "@";
			if (name.charAt(name.length - 1) == seperator) name = name.substr(0, name.length - 1);
			if (domain.charAt(0) == seperator) domain = domain.substr(1);
			return isValidMail(name + seperator + domain);
		}

		
		public static function isValidDate(year : uint, month : uint, day : uint) : Boolean {
			var date : Date = new Date(year, month, day);
			return (date.getMonth() == month && date.getFullYear() == year);
		}

		
		public static function timeDifference(olderDate : Date, newerDate : Date) : Date {
			var date : Date = new Date(newerDate.time - olderDate.time);
			date.fullYear -= 1970;
			return date;
		}

		
		public static function ageCheck(birthday : Date, targetAge : uint, maxAge : uint = 100) : Boolean {
			var age : int = timeDifference(birthday, new Date()).getFullYear();
			return (age >= targetAge && age < maxAge);
		}
	}
}
