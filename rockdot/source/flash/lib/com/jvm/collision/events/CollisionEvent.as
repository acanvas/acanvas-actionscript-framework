package com.jvm.collision.events {
	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class CollisionEvent extends Event {
		public static const COLLISION : String = "CollisionEvent.COLLISION";		public static const COLLISION_STARTED : String = "CollisionEvent.COLLISION_STARTED";		public static const COLLISION_ENDED : String = "CollisionEvent.COLLISION_ENDED";
		public var collisionRect : Rectangle;

		public function CollisionEvent(type : String, collisionRect : Rectangle = null, bubbles : Boolean = false, cancelable : Boolean = false) {
			this.collisionRect = collisionRect;
			super( type, bubbles, cancelable );
		}

		
		override public function clone() : Event {
			return new CollisionEvent( type, collisionRect, bubbles, cancelable );
		}
	}
}
