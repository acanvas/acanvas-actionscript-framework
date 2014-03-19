package com.jvm.input {
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	/**
	 * Dispatched once when a key is pressed.	 * If there are no keys registered, this event is dispatched repeatedly as long as the key stays down.
	 * @eventType flash.events.KeyboardEvent.KEY_DOWN
	 */	[Event(name="keyDown", type="flash.events.KeyboardEvent")]

	/**
	 * Dispatched once when a key is released.
	 * @eventType flash.events.KeyboardEvent.KEY_UP	 */
	[Event(name="keyUp", type="flash.events.KeyboardEvent")]

	/**
	 * The KeyinputManager ensures that KeyboardEvents are dispatched only once, if keys are registered.
	 * Register keys of interest with the <code>registerKeyCodes()</code> or <code>registerKeyCodesDispatchingCustomKeyCode()</code> method.
	 * @see #registerKeyCodes()	 * @see #registerKeyCodesDispatchingCustomKeyCode()
	 * 
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class KeyinputManager extends EventDispatcher {
		private var _stage : Stage;		private var _keyDict : Dictionary;		private var _active : Boolean;

		public function KeyinputManager(stage : Stage) {
			if (stage) {
				_stage = stage;
			} else {
				_warn("stage is null.");
			}
		}

		
		/**
		 * Register keys of interest with an Array.
		 * 
		 * @example The following code creates an array containing the <code>uint</code> - values of the arrow keys left, down and right. Then we create a KeyinputManager instance and register keys of interest with the <code>keys</code> array. 
		 * <listing version="3.0">		 * var keys : Array = [Keyboard.LEFT, Keyboard.DOWN, Keyboard.RIGHT];
		 * var keyInput : KeyinputManager = new KeyinputManager( stage );
		 * keyInput.registerKeyCodes( keys );
		 * keyInput.activate( );
		 * </listing> 		 * @see #isRegisteredKeyDown()
		 */
		public function registerKeyCodes(keys : Array) : void {
			if (!_keyDict)
				_keyDict = new Dictionary(true);
			
			var n : uint = keys.length;
			for (var i : uint = 0;i < n;i++) {
				_keyDict[keys[i]] = [keys[i], false];
			}
		}

		
		/**
		 * Register keys of interest with a Dictionary. These keys will not dispatch their default keyCode but the custom keyCode.
		 * 
		 * @example
		 * Left key will dispatch "0" instead of Keyboard.LEFT<br />
		 * Down key will dispatch "1" instead of Keyboard.DOWN<br />
		 * Right key will dispatch "2" instead of Keyboard.RIGHT<br />		 * 		 * <listing version="3.0">
		 * var customKeyCodeDict : Dictionary = new Dictionary(true);
		 * customKeyCodeDict[Keyboard.LEFT] = 0;
		 * customKeyCodeDict[Keyboard.DOWN] = 1;
		 * customKeyCodeDict[Keyboard.RIGHT] = 2;
		 * 
		 * var keyInput : KeyinputManager = new KeyinputManager( stage );
		 * keyInput.registerKeyCodesDispatchingCustomKeyCode( customKeyCodeDict );
		 * keyInput.activate( );
		 * </listing> 
		 * @see #isRegisteredKeyDown()
		 */
		public function registerKeyCodesDispatchingCustomKeyCode(keyDict : Dictionary) : void {
			if (!_keyDict)
				_keyDict = new Dictionary(true);
			
			for (var key : String in keyDict) {
				_keyDict[key] = [keyDict[key], false];
			}
		}

		
		/**
		 * Unregisters all keys.
		 */
		public function unregisterAllKeys() : void {
			_keyDict = null;
		}

		
		/**
		 * Activates the KeyinputManager.
		 * @param forceAddEventListener Adds a KeyboardEventListener event if the stage already has a KeyboardEventListener when set to true.
		 * @see #deactivate()
		 * @see #isActive()		 * @see #destroy()		 */
		public function activate(forceAddEventListener : Boolean = false) : void {
			if (!_active) {
				_active = true;
				if (_stage) {
					if (!_stage.hasEventListener(KeyboardEvent.KEY_DOWN) || forceAddEventListener)
						_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);					else
						_debug("stage already has KeyboardEvent.KEY_DOWN listener.");
					
					if (!_stage.hasEventListener(KeyboardEvent.KEY_UP) || forceAddEventListener)						_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					else
						_debug("stage already has KeyboardEvent.KEY_UP listener.");
				} else {					_warn("stage is null.");
				}
			}
		}

		
		/**
		 * Deactivates the KeyinputManager.		 * @see #activate()		 * @see #isActive()		 * @see #destroy()
		 */
		public function deactivate() : void {
			if (_active) {
				_active = false;
				if (_stage) {
					if (_stage.hasEventListener(KeyboardEvent.KEY_DOWN))
						_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
						
					if (_stage.hasEventListener(KeyboardEvent.KEY_UP))
						_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				} else {
					_warn("stage is null.");
				}
				
				for (var key : String in _keyDict) {
					_keyDict[key][1] = false;
				}
			}
		}

		
		/**
		 * Returns a Boolean whether the passed key is down or not.
		 * @param keyCode The keyCode to check if it is down.
		 */		
		public function isRegisteredKeyDown(keyCode : uint) : Boolean {
			if (_keyDict)
				return _keyDict[keyCode][1];
			
			_warn("no keys registered.");
			return false;
		}

		
		/**
		 * Deactivates the KeyinputManager and unregisters all keys.
		 */
		public function destroy() : void {
			deactivate();
			unregisterAllKeys();
		}

		
		/**
		 * Returns a Boolean whether the KeyinputManager is active or not.
		 */
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
						dispatchEvent(e);
					}
				}			} else {
				dispatchEvent(e);
			}
		}

		
		private function onKeyUp(event : KeyboardEvent) : void {
			var e : KeyboardEvent = event;
			if (_keyDict) {
				if (_keyDict[e.keyCode] != undefined) {
					if (_keyDict[e.keyCode][1]) {
						_keyDict[e.keyCode][1] = false;
						e.keyCode = _keyDict[e.keyCode][0];
						dispatchEvent(e);
					}
				}
			} else {
				dispatchEvent(e);
			}
		}

		
		private function _debug(msg : String) : void {
			trace("[KeyinputManager] DEBUG: " + msg);
		}

		
		private function _warn(msg : String) : void {
			trace("[KeyinputManager] WARNING: " + msg);
		}
	}
}
