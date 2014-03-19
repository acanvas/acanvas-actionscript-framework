package com.rockdot.project.view.element.pointlight {
	import flash.geom.Point;

	/**
	 * @author nilsdoehring
	 */
	public class Points {
		private var localX : Number;
		private var localY : Number;
		private var vx : Number = 0;
		private var vy : Number = 0;
		private var _x : Number;
		private var _y : Number;

		public function Points(x : Number, y : Number) {
			_x = localX = x;
			_y = localY = y;
		}

		public function update(mousePoint : Point, Reaction : uint, spring : Number, friction : Number) : void {
			var dx : Number;
			var dy : Number;
			var distance : Number = Point.distance(mousePoint, new Point(localX, localY));
			if (distance < Reaction) {
				var diff : Number = distance * -1 * (Reaction - distance) / Reaction;
				var radian : Number = Math.atan2(mousePoint.y - localY, mousePoint.x - localX);
				var diffPoint : Point = Point.polar(diff, radian);
				dx = localX + diffPoint.x;
				dy = localY + diffPoint.y;
			} else {
				dx = localX;
				dy = localY;
			}
			vx += (dx - _x) * spring;
			vy += (dy - _y) * spring;
			vx *= friction;
			vy *= friction;
			_x += vx;
			_y += vy;
		}

		public function get x() : Number {
			return _x;
		}

		public function get y() : Number {
			return _y;
		}
	}
}
