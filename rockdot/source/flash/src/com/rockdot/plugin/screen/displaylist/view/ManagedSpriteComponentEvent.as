package com.rockdot.plugin.screen.displaylist.view {
	import flash.events.Event;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ManagedSpriteComponentEvent extends Event {
		public static const INIT_START			: String = "ViewEvent.WILL_INIT";
		public static const INIT_COMPLETE			: String = "ViewEvent.DID_INIT";

		public static const LOAD_START 			: String = "ViewEvent.WILL_LOAD";
		public static const LOAD_COMPLETE 			: String = "ViewEvent.DID_LOAD";
		public static const LOAD_ERROR 			: String = "ViewEvent.LOAD_ERROR";
		
		public static const APPEAR_START 		: String = "ViewEvent.WILL_APPEAR";
		public static const APPEAR_COMPLETE 			: String = "ViewEvent.DID_APPEAR";
		
		public static const DISAPPEAR_START 		: String = "ViewEvent.WILL_DISAPPEAR";
		public static const DISAPPEAR_COMPLETE 		: String = "ViewEvent.DID_DISAPPEAR";
		
		public static const DESTROY_START 		: String = "ViewEvent.WILL_DESTROY";
		public static const DESTROY_COMPLETE	 		: String = "ViewEvent.DID_DESTROY";

		public static const WILL_ACTIVATE 		: String = "ViewEvent.WILL_ACTIVATE";
		public static const DID_ACTIVATE		: String = "ViewEvent.DID_ACTIVATE";
		public static const WILL_DEACTIVATE 	: String = "ViewEvent.WILL_DEACTIVATE";
		public static const DID_DEACTIVATE 		: String = "ViewEvent.DID_DEACTIVATE";
		
		public var data : *;

		public function ManagedSpriteComponentEvent(type : String, data : * = null, bubbles : Boolean = false, cancelable : Boolean = false) {
			this.data = data;
			super(type, bubbles, cancelable);
		}

		
		override public function clone() : Event {
			return new ManagedSpriteComponentEvent(type, data, bubbles, cancelable);
		}
	}
}
