package com.jvm.geom {

	public class Vector2d {
		public var x : Number;
		public var y : Number;

		public function Vector2d( x : Number, y : Number ) {
			this.x = x || 0;
			this.y = y || 0;
		}

		
		public function length() : Number {
			return Math.sqrt(x * x + y * y);
		}

		
		public function angle() : Number {
			return Math.atan2(y, x);
		}

		
		public function dot( v : Vector2d ) : Number {
			return x * v.x + y * v.y;
		}

		
		public function cross( v : Vector2d ) : Number {
			return x * v.y - y * v.x;
		}

		
		public function angleBetween( v : Vector2d ) : Number {
			return Math.acos(dot(v) / ( this.length() * v.length() ));
		}

		
		public function reflect( normal : Vector2d ) : void {
			var dp : Number = 2 * dot(normal);
			
			x -= normal.x * dp;
			y -= normal.y * dp;
		}

		
		public function getReflect( normal : Vector2d ) : Vector2d {
			var dp : Number = 2 * dot(normal);
			
			return new Vector2d(x - normal.x * dp, y - normal.y * dp);
		}

		
		public function negate() : void {
			x = -x;
			y = -y;
		}

		
		public function getNegate() : Vector2d {
			return new Vector2d(-x, -y);
		}

		
		public function orth() : void {
			var tx : Number = -y;
			
			y = x;
			x = tx;
		}

		
		public function getOrth() : Vector2d {
			return new Vector2d(-y, x);
		}

		
		public function normalize() : void {
			var ln : Number = this.length();
			
			x /= ln;
			y /= ln;
		}

		
		public function getNormalize() : Vector2d {
			var ln : Number = this.length();
			
			return new Vector2d(x / ln, y / ln);
		}

		
		public function normal() : void {
			var ln : Number = this.length();
			var tx : Number = -y / ln;
	
			y = x / ln;
			x = tx;
		}

		
		public function getNormal() : Vector2d {
			var ln : Number = this.length();
			
			return new Vector2d(-y / ln, x / ln);
		}

		
		public function rotateBy( angle : Number ) : void {
			var ca : Number = Math.cos(angle);
			var sa : Number = Math.sin(angle);
			var rx : Number = x * ca - y * sa;
			y = x * sa + y * ca;
			x = rx;
		}

		
		public function getRotateBy( angle : Number ) : Vector2d {
			var ca : Number = Math.cos(angle);
			var sa : Number = Math.sin(angle);
			var rx : Number = x * ca - y * sa;
			
			return new Vector2d(rx, x * sa + y * ca);
		}

		
		public function rotateTo( angle : Number ) : void {
			var ln : Number = this.length();
			x = Math.cos(angle) * ln;
			y = Math.sin(angle) * ln;
		}

		
		public function getRotateTo( angle : Number ) : Vector2d {
			var ln : Number = this.length();
			
			return new Vector2d(Math.cos(angle) * ln, Math.sin(angle) * ln);
		}

		
		public function newLength( len : Number ) : void {
			var ln : Number = this.length();
			
			x /= ln / len;
			y /= ln / len;
		}

		
		public function getNewLength( len : Number ) : Vector2d {
			var ln : Number = this.length();
			
			return new Vector2d(x / ln * len, y / ln * len);
		}

		
		public function plus( v : Vector2d ) : void {
			x += v.x;
			y += v.y;
		}

		
		public function getPlus( v : Vector2d ) : Vector2d {
			return new Vector2d(x + v.x, y + v.y);
		}

		
		public function minus( v : Vector2d ) : void {
			x -= v.x;
			y -= v.y;
		}

		
		public function getMinus( v : Vector2d ) : Vector2d {
			return new Vector2d(x - v.x, y - v.y);
		}

		
		public function multiply( f : Number ) : void {
			x *= f;
			y *= f;
		}

		
		public function getMultiply( f : Number ) : Vector2d {
			return new Vector2d(x * f, y * f);
		}

		
		public function divide( d : Number ) : void {
			x /= d;
			y /= d;
		}

		
		public function getDivide( d : Number ) : Vector2d {
			return new Vector2d(x / d, y / d);
		}

		
		public function getClone() : Vector2d {
			return new Vector2d(x, y);
		}

		
		public function getOrientation( v1 : Vector2d, v2 : Vector2d ) : Number {
			return ( v1.x - x ) * ( v1.y - y ) - ( v1.y - y ) * ( v2.x - x );
		}

		
		public function toString() : String {
			var rx : Number = Math.round(x * 1000) / 1000;
			var ry : Number = Math.round(y * 1000) / 1000;
			
			return '[Vector2d x: ' + rx + ' y: ' + ry + ']';
		}
	}
}