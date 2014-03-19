package com.jvm.utils {

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class MathUtils {
		/*
		 * ####################################################################################################
		 * P O I N T S		 * ####################################################################################################
		 */
		public static function distanceBetweenTwoPoints(p1x : Number, p1y : Number, p2x : Number, p2y : Number) : Number {
			return Math.sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y));
		}

		
		public static function relativedistanceBetweenTwoPoints(p1x : Number, p1y : Number, p2x : Number, p2y : Number) : Number {
			if (p1x > p2x) return -Math.sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y));
			else if (p1y > p2y) return -Math.sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y));
			return Math.sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y));
		}

		
		public static function shortAngleBetweenTwoPoints(p1x : Number, p1y : Number, p2x : Number, p2y : Number) : Number {
			return Math.atan((p2y - p1y) / (p2x - p1x));
		}

		
		public static function angleBetweenTwoPoints(p1x : Number, p1y : Number, p2x : Number, p2y : Number) : Number {
			if (p1x > p2x) return Math.PI + Math.atan((p2y - p1y) / (p2x - p1x));
			else if (p1y > p2y) return Math.PI + Math.PI + Math.atan((p2y - p1y) / (p2x - p1x));
			return Math.atan((p2y - p1y) / (p2x - p1x));
		}

		
		public static function angleRADtoDEG(angle : Number) : Number {			return angle * 180 / Math.PI;		}

		
		public static function angleDEGtoRAD(angle : Number) : Number {
			return angle / 180 * Math.PI;
		}

		
		public static function randomNumBetween(min : int, max : int) : Number {
			return min + Math.random() * (max - min);
		}

		
		public static function randomIntBetween(min : int, max : int) : int {
			return min + Math.round(Math.random() * (max - min));
		}

		
		public static function round(value : Number, digits : uint = 0) : Number {
			return Math.round(value * Math.pow(10, digits)) / Math.pow(10, digits);
		}
		
		/**
		 * @return Ob es sich um eine Primzahl handelt oder nicht.
		 */
		public static function isPrime(num : uint) : Boolean {
			if(num < 2) return false;
			var i : int = 2;
			while(i < num) {
				if(num % i == 0) return false;
				i++;
			}
			return true;
		}

		/**
		 * @return Array mit Primzahlen innerhalb der angegebenen Grenzen
		 */
		public static function calcPrimes(from : int = 0, to : uint = 1000) : Array {
			var primes : Array = [];
			var num : int = from < 2 ? 2 : from;
			var i : int;
			var isPrime : Boolean;

			while(num < to) {
				isPrime = true; 
				i = 2;
				while(i < num) {
					if(num % i == 0) {
						isPrime = false;
						break;
					}
					i++;
				}
				if (isPrime) primes.push(num);
				num++;
			}
			return primes;
		}
	}
}
