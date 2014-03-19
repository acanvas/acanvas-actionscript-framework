package com.jvm.collision {
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class CachedCollisionDetection extends CollisionDetection {
		private var _cachedTarget : DisplayObject;		private var _cachedBounds : Rectangle;

		public function CachedCollisionDetection(cachedTarget : DisplayObject) {
			super();
			_cachedTarget = cachedTarget;
			_cachedBounds = _cachedTarget.getBounds(_cachedTarget.parent);
		}

		
		public function collisionTestCached(target1 : DisplayObject, alphaTollerance : Number = 0, dispEvent : Boolean = true) : Boolean {
			var collRect : Rectangle = getCollisionRectCached( target1, alphaTollerance );
			
			if (collRect != null && collRect.size.length > 0) {
				if(!dispEvent) return true;
				
				//Collision started
				if(!_collision) {
					_collision = true;
					_collEventStarted.collisionRect = collRect;
					dispatchEvent( _collEventStarted );
				}
				
				//Collision
				_collEvent.collisionRect = _lastCollRect = collRect;
				dispatchEvent( _collEvent );
				
			} else {
				if(!dispEvent) return false;
				
				//Collision ended
				if(_collision) {
					_collision = false;
					_collEventEnded.collisionRect = _lastCollRect;
					dispatchEvent( _collEventEnded );
				}			
			}
			return _collision;
		}

		
		public function getCollisionPointCached(target : DisplayObject, alphaTollerance : Number = 0) : Point {
			var collisionRect : Rectangle = getCollisionRectCached( target, alphaTollerance );

			if (collisionRect != null && collisionRect.size.length > 0) {
				_collPt.x = (collisionRect.left + collisionRect.right) * 0.5;
				_collPt.y = (collisionRect.top + collisionRect.bottom) * 0.5;
				return _collPt;
			}
			return null;
		}

		
		public function getCollisionRectCached(target : DisplayObject, tollerance : Number = 0) : Rectangle {
			if (target.parent == _cachedTarget.parent) {
				var collRect : Rectangle;
				var par : DisplayObjectContainer = target.parent;
				var rect1 : Rectangle = target.getBounds( par );

				var isIntersecting : Boolean = rect1.intersects( _cachedBounds );
				if (isIntersecting) {
					var combinedrect : Rectangle = rect1.union( _cachedBounds );
					
					var alpha1 : BitmapData = _getAlphaMap( target, combinedrect, BitmapDataChannel.RED, rect1);
					var alpha2 : BitmapData = _getAlphaMap(_cachedTarget, combinedrect, BitmapDataChannel.GREEN, _cachedBounds );
					alpha1.draw( alpha2, MATRIX, COLOR_TRANSFORM, BLEND_MODE );

					if (tollerance > 1)
						tollerance = 1;
					else if (tollerance < 0)
						tollerance = 0;

					var colorsearch : uint;

					if (tollerance == 0) {
						colorsearch = 0x010100;
					} else {
						var tollByte : Number = Math.round( tollerance * 255 );
						colorsearch = (tollByte << 16) | (tollByte << 8) | 0;
					}

					collRect = alpha1.getColorBoundsRect( colorsearch, colorsearch );
					collRect.x += combinedrect.x;
					collRect.y += combinedrect.y;
				}
			}
			trace("[CollisionDetection] ERROR: target1.parent != target2.parent! Must be same parent!");
			return null;
		}
	}
}
