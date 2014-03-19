package com.rockdot.library.view.component.common.scrollable {
	import com.jvm.components.Orientation;
	import com.rockdot.library.view.component.common.scrollable.event.SliderEvent;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;


	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Slider extends SpriteComponent {
		protected var POS : String;
		protected var SIZE : String;
		protected var MOUSE_POS : String;
		//
		protected var _orientation : String;
		protected var _min : Number;
		protected var _max : Number;
		protected var _size : Number;
		protected var _continuous : Boolean;
		protected var _thumb : Sprite;
		protected var _thumbSize : uint;
		protected var _background : Sprite;
		protected var _mouseOffset : Number;
		protected var _value : Number;
		// States
		protected var _interaction : Boolean;
		protected var _changing : Boolean;
		// Momentum
		protected var _momentumEnabled : Boolean;
		protected var _momentum : Number = 0;
		protected var _momentumDelta : Number = 0;
		public var momentumFriction : Number = 0.85;
		public var momentumClearThreshold : Number = 1;
		// Mouse Wheel
		protected var _mouseWheelEnabled : Boolean;
		public var mouseWheelSensitivity : Number;

		public function Slider(orientation : String, min : Number, max : Number, size : Number, continuous : Boolean = false) {
			super();
			_orientation = orientation;
			_min = min;
			_max = max;
			_size = size;
			_continuous = continuous;
			_value = _min;

			mouseWheelSensitivity = (_max - min) * 0.01;
			mouseWheelEnabled = true;

			if (_orientation == Orientation.HORIZONTAL) {
				_width = size;
				POS = "x";
				SIZE = "width";
				MOUSE_POS = "mouseX";
			} else {
				_height = size;
				POS = "y";
				SIZE = "height";
				MOUSE_POS = "mouseY";
			}

			thumb ||= new Sprite();
			_background ||= new Sprite();
			_thumbSize = _thumb[SIZE];
			size = _size;
		}

		


		public function interactionStart(preventMomentum : Boolean = false, addMouseListeners : Boolean = true) : void {
			if (!_interaction) {
				_interaction = true;

				clearMomentum();

				if (addMouseListeners) {
					stage.addEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
					stage.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
				}

				if (_momentumEnabled && !preventMomentum) addEventListener(Event.ENTER_FRAME, _calcMomentum);

				dispatchEvent(new SliderEvent(SliderEvent.INTERACTION_START, _value));
				changeStart();
			}
		}


		public function interactionEnd() : void {
			if (_interaction) {
				_interaction = false;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);

				dispatchEvent(new SliderEvent(SliderEvent.INTERACTION_END, _value));

				if (_momentumEnabled) {
					removeEventListener(Event.ENTER_FRAME, _calcMomentum);
					momentumStart();
				} else {
					changeEnd();
				}
			}
		}


		public function momentumStart() : void {
			if (_momentum != 0) {
				dispatchEvent(new SliderEvent(SliderEvent.MOMENTUM_START, _value));
				addEventListener(Event.ENTER_FRAME, _applyMomentum);
			} else {
				changeEnd();
			}
		}


		public function momentumEnd() : void {
			dispatchEvent(new SliderEvent(SliderEvent.MOMENTUM_END, _value));
			changeEnd();
		}


		public function changeStart() : void {
			if (!_changing) {
				_changing = true;
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE_START, _value));
			}
		}


		public function changeEnd() : void {
			if (_changing) {
				_changing = false;
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE_END, _value));
			}
		}


		protected function _onBackgroundMouseDown(event : MouseEvent) : void {
			interactionStart(true);
			var pos : Number = this[MOUSE_POS] - _thumbSize * 0.5 - _background[POS];
			value = convertPositionToValue(pos);
			_mouseOffset = stage[MOUSE_POS] - pos;
		}


		protected function _onThumbMouseDown(event : MouseEvent) : void {
			interactionStart();
			_mouseOffset = stage[MOUSE_POS] - _thumb[POS] + _background[POS];
		}


		protected function _onStageMouseMove(event : MouseEvent) : void {
			value = convertPositionToValue(stage[MOUSE_POS] - _mouseOffset);
			// event.updateAfterEvent();
		}


		protected function _onStageMouseUp(event : MouseEvent) : void {
			interactionEnd();
		}


		/**
		 * 
		 * COMMON
		 *  
		 */
		public function convertPositionToValue(position : Number) : Number {
			return _min + (_max - _min) * (position / (_size - _thumbSize));
		}


		protected function _updateThumbPosition() : void {
			_thumb[POS] = Math.round((_value - _min) / (_max - _min) * (_size - _thumbSize)) + _background[POS];
		}


		public function get value() : Number {
			return _value;
		}


		public function set value(value : Number) : void {
			if (value < _min) value = min;
			else if (value > _max) value = _max;
			if (!_continuous) value = Math.round(value);

			if (value != _value) {
				_value = value;
				_updateThumbPosition();
				dispatchEvent(new SliderEvent(SliderEvent.VALUE_CHANGE, _value));
			}
		}


		
		override public function setSize(w : int, h : int) : void {
			size = _orientation == Orientation.HORIZONTAL ? w : h; 
			super.setSize(w, h);
		}

		public function get size() : Number {
			return _size;
		}


		public function set size(value : Number) : void {
			_size = value;
			_updateThumbPosition();
		}


		public function get min() : Number {
			return _min;
		}


		public function set min(min : Number) : void {
			if (min != _min) {
				_min = min;
				_updateThumbPosition();
			}
		}


		public function get max() : Number {
			return _max;
		}


		public function set max(max : Number) : void {
			if (max != _max) {
				_max = max;
				_updateThumbPosition();
			}
		}


		public function get continuous() : Boolean {
			return _continuous;
		}


		public function set continuous(continuous : Boolean) : void {
			if (continuous != _continuous) {
				_continuous = continuous;
				_updateThumbPosition();
			}
		}


		override public function set enabled(value : Boolean) : void {
			
			if(value == true){
				_background.addEventListener(MouseEvent.MOUSE_DOWN, _onBackgroundMouseDown, false, 0, true);
				_thumb.addEventListener(MouseEvent.MOUSE_DOWN, _onThumbMouseDown, false, 0, true);
			}
			else{
				_background.removeEventListener(MouseEvent.MOUSE_DOWN, _onBackgroundMouseDown);
				_thumb.removeEventListener(MouseEvent.MOUSE_DOWN, _onThumbMouseDown);
			}
			
			super.enabled = mouseChildren = value;
		}


		public function get thumb() : Sprite {
			return _thumb;
		}


		public function set thumb(thumb : Sprite) : void {
			if (thumb != _thumb) {
				_thumb = thumb;
				_thumbSize = _thumb[SIZE];
				_updateThumbPosition();
			}
		}


		/**
		 * 
		 * MOUSE WHEEL
		 *  
		 */
		public function get mouseWheelEnabled() : Boolean {
			return _mouseWheelEnabled;
		}


		public function set mouseWheelEnabled(value : Boolean) : void {
			if (value != _mouseWheelEnabled) {
				_mouseWheelEnabled = value;
				if (_mouseWheelEnabled) addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
				else removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
		}


		public function onMouseWheel(event : MouseEvent) : void {
			if (event.delta < 0 && _value == _max) return;
			if (event.delta > 0 && _value == _min) return;
			
			interactionStart();
			value -= event.delta * mouseWheelSensitivity;
			interactionEnd();
		}


		/**
		 * 
		 * MOMENTUM
		 *  
		 */
		public function get momentumEnabled() : Boolean {
			return _momentumEnabled;
		}


		public function set momentumEnabled(value : Boolean) : void {
			_momentumEnabled = value;
		}


		public function clearMomentum() : void {
			if (_momentumEnabled) {
				removeEventListener(Event.ENTER_FRAME, _calcMomentum);
				removeEventListener(Event.ENTER_FRAME, _applyMomentum);
				_momentum = _momentumDelta = 0;
			}
		}


		protected function _calcMomentum(event : Event) : void {
			_momentum = _value - _momentumDelta;
			_momentumDelta = _value;
		}


		protected function _applyMomentum(event : Event) : void {
			_momentum *= momentumFriction;
			if (Math.abs(_momentum) < momentumClearThreshold) {
				value += _momentum;
				clearMomentum();
				momentumEnd();
			} else {
				value += _momentum;
				if (_value <= _min) {
					clearMomentum();
					value = _min;
					momentumEnd();
				} else if (_value >= _max) {
					clearMomentum();
					value = _max;
					momentumEnd();
				}
			}
		}


		public function get interaction() : Boolean {
			return _interaction;
		}


		public function get changing() : Boolean {
			return _changing;
		}
	}
}
