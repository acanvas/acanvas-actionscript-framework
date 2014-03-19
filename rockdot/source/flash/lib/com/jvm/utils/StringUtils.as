package com.jvm.utils {	import flash.text.TextField;	/**	 * Copyright 2009 Jung von Matt/Neckar	 *	 * @author	Thomas Eckhardt	 * @since	15.06.2009 13:21:45	 * 	 * @version 1.1, Simon Schmid (contact(at)sschmid.com)	 * 	 */	public class StringUtils {		public static function addLeadingZeros(num : uint, integerDigits : uint = 2) : String {			var numStr : String = num.toString();			while ( numStr.length < integerDigits ) {				numStr = "0" + numStr;			}			return numStr;		}		public static function trim(text : String, maxChars : int, trimChar : String = "…") : String {			if ( text.length > maxChars ) {				text = text.substring(0, maxChars - trimChar.length) + trimChar;			}			return text;		}		public static function trimTextFieldToWidth(tf : TextField, width : Number) : void {			if (tf.width > width) {				while (tf.width > width) {					tf.text = tf.text.substr(0, tf.text.length - 1);				}				tf.text = tf.text.substr(0, tf.text.length - 1);				tf.appendText("…");			}		}		public static function stripTags(s : String) : String {			var pattern : RegExp = new RegExp("\\<.*?\\>", "ig");			return s.replace(pattern, "");		}		public static function turnBIntoFont(input : String) : String {			var myPattern : RegExp = /<b>/gi;			var myPattern2 : RegExp = /<\/b>/gi;			input = input.replace(myPattern, "<FONT FACE='standard 07_65_8pt_st'>");			input = input.replace(myPattern2, "</FONT>");			return input;		}		public static function removeHtmlBreak(input : String) : String {			var pattern : RegExp = new RegExp("<br ?/>$", "i");			return input.replace(pattern, "");		}	}}