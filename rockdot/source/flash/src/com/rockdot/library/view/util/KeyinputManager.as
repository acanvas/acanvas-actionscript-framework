package com.rockdot.library.view.util {
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	[Event(name="keyDown", type="flash.events.KeyboardEvent")]

	[Event(name="keyUp", type="flash.events.KeyboardEvent")]

	/**
	 * The KeyinputManager ensures that KeyboardEvents are dispatched only once.
	 * Register keys of interest with the registerKeyCodes() or registerKeyCodesDispatchingCustomKeyCode() method.
	 * 
	 * @author Nils Doehring (nilsdoehring(at)gmail.com) - mail@Nils Doehring (nilsdoehring(at)gmail.com).com
	 */
	public class KeyinputManager extends EventDispatcher {
		private var _stage : Stage;		private var _keyDict : Dictionary;		private var _active : Boolean;

		public function init(stage : Stage) :void{
			if (stage) {
				_stage = stage;
			} else {
				trace( "KeyinputManager: WARNING: stage is null." );
			}
		}

		 
		/**
		 * Register keys of interest with an Array.
		 * 
		 * @example
		 * Register Left, Down and Right arrow key
		 * 
		 * var keys : Array = [Keyboard.LEFT, Keyboard.DOWN, Keyboard.RIGHT];
		 */
		public function registerKeyCodes(keys : Array) : void {
			if (!_keyDict)
				_keyDict = new Dictionary( true );
			
			var n : uint = keys.length;
			for (var i : uint = 0; i < n; i++) {
				_keyDict[keys[i]] = [keys[i], false];
			}
		}

		public function registerGridKeyCode(key : int) : void {
			if (!_keyDict)
				_keyDict = new Dictionary( true );
			
			_keyDict[key+48] = [key, false];
		}

		
		/**
		 * Register keys of interest with a Dictionary. These keys will not dispatch their default keyCode but the custom keyCode.
		 * 
		 * @example
		 * Left key will dispatch "0" instead of Keyboard.LEFT		 * Down key will dispatch "1" instead of Keyboard.DOWN		 * Right key will dispatch "2" instead of Keyboard.RIGHT
		 * 
		 * var customKeyCodeDict : Dictionary = new Dictionary(true);
		 * customKeyCodeDict[Keyboard.LEFT] = 0;
		 * customKeyCodeDict[Keyboard.DOWN] = 1;
		 * customKeyCodeDict[Keyboard.RIGHT] = 2;
		 */
		public function registerKeyCodesDispatchingCustomKeyCode(keyDict : Dictionary) : void {
			if (!_keyDict)
				_keyDict = new Dictionary( true );
			
			for (var key : String in keyDict) {
				_keyDict[key] = [keyDict[key], false];
			}
		}

		
		public function unregisterAllKeys() : void {
			_keyDict = null;
		}

		
		/**
		 * @param forceAddEventListener Adds a KeyboardEventListener event if the stage already has a KeyboardEventListener when set to true.
		 */
		public function start(forceAddEventListener : Boolean = false) : void {
			if (!_active) {
				_active = true;
				if (_stage) {
					if (!_stage.hasEventListener( KeyboardEvent.KEY_DOWN ) || forceAddEventListener)
						_stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
					else						trace( "KeyinputManager: stage already has KeyboardEvent.KEY_DOWN listener." );
					
					if (!_stage.hasEventListener( KeyboardEvent.KEY_UP ) || forceAddEventListener)
						_stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );					else
						trace( "KeyinputManager: stage already has KeyboardEvent.KEY_UP listener." );
				} else {
					trace( "KeyinputManager: WARNING: stage is null." );				}
			}
		}

		
		public function suspend() : void {
			if (_active) {
				_active = false;
				if (_stage) {
					if (_stage.hasEventListener( KeyboardEvent.KEY_DOWN ))
						_stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
						
					if (_stage.hasEventListener( KeyboardEvent.KEY_UP ))
						_stage.removeEventListener( KeyboardEvent.KEY_UP, onKeyUp );
				} else {
					trace( "KeyinputManager: WARNING: stage is null." );
				}
			}
		}

		
		/**
		 * Returns a Boolean whether the passed key is down or not.
		 */		
		public function isRegisteredKeyDown(keyCode : uint) : Boolean {
			if (_keyDict)
				return _keyDict[keyCode][1];
			
			trace( "KeyinputManager: WARNING: no keys registered." );
			return false;
		}

		
		public function dispose() : void {
			suspend( );
			_keyDict = null;
		}

		
		public function get isActive() : Boolean {
			return _active;
		}

		
		private function onKeyDown(event : KeyboardEvent) : void {
			var e : KeyboardEvent = event;
			if (_keyDict) {
				if (_keyDict[e.keyCode] != undefined) {
					if (!_keyDict[e.keyCode][1]) {
						_keyDict[e.keyCode][1] = true;
						e.keyCode = _keyDict[e.keyCode][0];
						dispatchEvent( e );
					}
				}			} else {
//				dispatchEvent( e );
			}
		}

		
		private function onKeyUp(event : KeyboardEvent) : void {
			var e : KeyboardEvent = event;
			if (_keyDict) {
				if (_keyDict[e.keyCode] != undefined) {
					if (_keyDict[e.keyCode][1]) {
						_keyDict[e.keyCode][1] = false;
						e.keyCode = _keyDict[e.keyCode][0];
						dispatchEvent( e );
					}
				}
			} else {
//				dispatchEvent( e );
			}
		}
	}
}
