package com.jvm.geom 
{

	/**
	 * Copyright (c) 2009, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author	Thomas Eckhardt
	 * @since	07.07.2009 16:29:39
	 * 
	 * @version	1.0
	 * 
	 * Diese Klasse repräsentiert eine Dimension die durch ihre
	 * Breite und Höhe definiert wird. Sie stellt die folgenden
	 * Flächenfunktionen zur Verfügung:
	 * - Flächeninhalt
	 * - Umfang
	 * - Diagonalenlänge
	 * - Umkreisradius
	 * - Seitenverhältnis (Breite:Höhe)
	 * 
	 */

	public class Dimension extends Object 
	{
		private var _w : Number;		private var _h : Number;
				private var _area : Number;
		private var _perimeter : Number;
		private var _diagonalLength : Number;
		private var _circumcircleRadius : Number;
		private var _aspectRatio : Number;
		
		public function Dimension ( width : Number = 0, height : Number = 0 )
		{
			_w = width;			_h = height;
		}
		
		public function toString () : String
		{
			return "(w=" + _w + ", h=" + _h + ")";
		}
		
		public function get width () : Number {
			return _w;
		}
		
		public function set width (width : Number) : void {
			_w = width;
		}
		
		public function get height () : Number {
			return _h;
		}
		
		public function set height (height : Number) : void {
			_h = height;
		}
		
		/**
		 * Gibt den Flächeninhalt zurück
		 * 
		 * @return Number	Flächeninhalt
		 */
		public function get area () : Number {
			_area = _w * _h;
			return _area;
		}
		
		/**
		 * Gibt den Umfang zurück
		 * 
		 * @return Number	Umfang
		 */
		public function get perimeter () : Number {
			_perimeter = 2 * ( _w + _h );
			return _perimeter;
		}
		
		/**
		 * Gibt die Diagonalenlänge zurück
		 * 
		 * @return Number	Diagonalenlänge
		 */
		public function get diagonalLength () : Number {
			_diagonalLength = Math.sqrt( _w * _w + _h * _h );
			return _diagonalLength;
		}
		
		/**
		 * Gibt den Umkreisradius zurück
		 * 
		 * @return Number	Umkreisradius
		 */
		public function get circumcircleRadius () : Number {
			_circumcircleRadius = .5 * this.diagonalLength;
			return _circumcircleRadius;
		}
		
		/**
		 * Gibt das Seitenverhältnis Breite : Höhe zurück
		 * 
		 * @return Number	Seitenverhältnis
		 */
		public function get aspectRatio () : Number {
			_aspectRatio = _w / _h;
			return _aspectRatio;
		}
	}
}
