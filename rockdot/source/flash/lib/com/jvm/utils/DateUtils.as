package com.jvm.utils {

	/**
	 * Copyright (c) 2009, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author	Thomas Eckhardt
	 * @since	29.07.2009 10:43:27
	 */
	public class DateUtils {
		/**
		 * Gibt die Zeit eines Date Objekts in Millisekunden zurück
		 *  
		 * @param	date		ein Date Objekt
		 * @return	Number		die Anzahl der Millisekunden
		 */
		public static function getTimeInMilliseconds( date : Date ) : Number {
			return date.hours * 60 * 60 * 1000 + date.minutes * 60 * 1000 + date.seconds * 1000 + date.milliseconds;
		}

		
		/**
		 * Gibt die Zeit eines Date Objekts in Sekunden zurück
		 *  
		 * @param	date		ein Date Objekt
		 * @return	Number		die Anzahl der Sekunden
		 */
		public static function getTimeInSeconds( date : Date ) : Number {
			return date.hours * 60 * 60 + date.minutes * 60 + date.seconds + date.milliseconds / 1000;
		}

		
		/**
		 * Gibt die Zeit eines Date Objekts in Minuten zurück
		 *  
		 * @param	date		ein Date Objekt
		 * @return	Number		die Anzahl der Minuten
		 */
		public static function getTimeInMinutes( date : Date ) : Number {
			return date.hours * 60 + date.minutes + date.seconds / 60 + date.milliseconds / 1000 / 60;
		}

		
		/**
		 * Gibt die Zeit eines Date Objekts in Stunden zurück
		 *  
		 * @param	date		ein Date Objekt
		 * @return	Number		die Anzahl der Stunden
		 */
		public static function getTimeInHours( date : Date ) : Number {
			return date.hours + date.minutes / 60 + date.seconds / 60 / 60 + date.milliseconds / 1000 / 60 / 60;
		}
		
	}
}
