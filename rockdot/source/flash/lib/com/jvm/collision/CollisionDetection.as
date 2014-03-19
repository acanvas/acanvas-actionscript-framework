package com.jvm.collision {
	import com.jvm.collision.events.CollisionEvent;

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class CollisionDetection extends EventDispatcher {
		protected const MATRIX : Matrix = new  Matrix();
		protected const COLOR_TRANSFORM : ColorTransform = new ColorTransform();
		protected const BLEND_MODE : String = BlendMode.LIGHTEN;
		protected const POINT : Point = new Point(0, 0);
		// 		protected var _collEvent : CollisionEvent;
		protected var _collEventStarted : CollisionEvent;
		protected var _collEventEnded : CollisionEvent;
		//
		protected var _collPt : Point = new Point(0, 0);
		protected var _alphaMatrix : Matrix = new Matrix();
		protected var _collision : Boolean;
		//
		protected var _lastCollRect : Rectangle;

		public function CollisionDetection() {
			_collEvent = new CollisionEvent(CollisionEvent.COLLISION);
			_collEventStarted = new CollisionEvent(CollisionEvent.COLLISION_STARTED);
			_collEventEnded = new CollisionEvent(CollisionEvent.COLLISION_ENDED);
		}


		public function collisionTest(target1 : DisplayObject, target2 : DisplayObject, alphaTollerance : Number = 0, dispEvent : Boolean = true) : Boolean {
			var collRect : Rectangle = getCollisionRect(target1, target2, alphaTollerance);

			if (collRect != null && collRect.size.length > 0) {
				if (!dispEvent) return true;

				// Prepare events
				
				// Collision started
				if (!_collision) {
					_collision = true;
					_collEventStarted.collisionRect = collRect;
					dispatchEvent(_collEventStarted);
				}

				// Collision
				_collEvent.collisionRect = _lastCollRect = collRect;
				dispatchEvent(_collEvent);
			} else {
				if (!dispEvent) return false;

				// Collision ended
				if (_collision) {
					_collision = false;
					_collEventEnded.collisionRect = _lastCollRect;
					dispatchEvent(_collEventEnded);
				}
			}
			return _collision;
		}


		public function getCollisionRect(target1 : DisplayObject, target2 : DisplayObject, alphaTollerance : Number = 0) : Rectangle {
			if (target1.parent == target2.parent) {
				var collRect : Rectangle;
				var par : DisplayObjectContainer = target1.parent;
				var rect1 : Rectangle = target1.getBounds(par);
				var rect2 : Rectangle = target2.getBounds(par);

				// isIntersecting?
				if (rect1.intersects(rect2)) {
					var combinedrect : Rectangle = rect1.union(rect2);

					var alpha1 : BitmapData = _getAlphaMap(target1, combinedrect, BitmapDataChannel.RED, rect1);
					var alpha2 : BitmapData = _getAlphaMap(target2, combinedrect, BitmapDataChannel.GREEN, rect2);
					alpha1.draw(alpha2, MATRIX, COLOR_TRANSFORM, BLEND_MODE);

					if (alphaTollerance > 1)
						alphaTollerance = 1;
					else if (alphaTollerance < 0)
						alphaTollerance = 0;

					var colorsearch : uint;

					if (alphaTollerance == 0) {
						colorsearch = 0x010100;
					} else {
						var tollByte : Number = Math.round(alphaTollerance * 255);
						colorsearch = (tollByte << 16) | (tollByte << 8) | 0;
					}

					collRect = alpha1.getColorBoundsRect(colorsearch, colorsearch);
					collRect.x += combinedrect.x;
					collRect.y += combinedrect.y;

					return collRect;
				}
			}
			trace("[CollisionDetection] ERROR: target1.parent != target2.parent! Must be same parent!");
			return null;
		}


		protected function _getAlphaMap(target : DisplayObject, rect : Rectangle, channel : uint, myrect : Rectangle) : BitmapData {
			var bmd : BitmapData = new BitmapData(rect.width, rect.height, true, 0x0);

			var offX : Number = target.x - myrect.x;
			var offY : Number = target.y - myrect.y;
			var xpos : Number = myrect.x + offX - rect.x;
			var ypos : Number = myrect.y + offY - rect.y;

			_alphaMatrix.identity();
			_alphaMatrix.translate(xpos, ypos);

			bmd.draw(target, _alphaMatrix);

			var alphachannel : BitmapData = new BitmapData(rect.width, rect.height, false, 0);
			alphachannel.copyChannel(bmd, bmd.rect, POINT, BitmapDataChannel.ALPHA, channel);
			bmd.dispose();

			return alphachannel;
		}


		public function getCollisionPoint(target1 : DisplayObject, target2 : DisplayObject, alphaTollerance : Number = 0) : Point {
			var collisionRect : Rectangle = getCollisionRect(target1, target2, alphaTollerance);

			if (collisionRect != null && collisionRect.size.length > 0) {
				_collPt.x = (collisionRect.left + collisionRect.right) * 0.5;
				_collPt.y = (collisionRect.top + collisionRect.bottom) * 0.5;
				return _collPt;
			}
			return null;
		}


		public function isColliding(target1 : DisplayObject, target2 : DisplayObject, alphaTollerance : Number = 0) : Boolean {
			var collisionRect : Rectangle = getCollisionRect(target1, target2, alphaTollerance);
			if (collisionRect != null && collisionRect.size.length > 0) return true;
			return false;
		}
	}
}
