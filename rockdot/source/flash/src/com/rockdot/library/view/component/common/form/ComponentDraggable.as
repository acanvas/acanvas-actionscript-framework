package com.rockdot.library.view.component.common.form {
	import com.rockdot.library.view.component.common.form.button.Button;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	/**
	 * @author nilsdoehring
	 */
	public class ComponentDraggable extends Button {
		private var _hitObject : Sprite;
		private var _frameCount : int;
		private var _constraints : Rectangle;
		private var _lockHorizontal : Boolean;
		private var _onDragTimer : Timer;

		public function set lockHorizontal(lockHorizontal : Boolean) : void {
			_lockHorizontal = lockHorizontal;
		}

		private var _lockVertical : Boolean;

		public function set lockVertical(lockVertical : Boolean) : void {
			_lockVertical = lockVertical;
		}

		private var _releaseOutside : Boolean;

		public function set releaseOutside(releaseOutside : Boolean) : void {
			_releaseOutside = releaseOutside;
		}

		public function ComponentDraggable(constraints : Rectangle, hitObject : Sprite = null) {
			_constraints = constraints;
			_hitObject = hitObject;
			_lockHorizontal = false;
			_lockVertical = false;
			_releaseOutside = false;
			useHandCursor = true;
			buttonMode = true;
			
			super();
			
			removeEventListener(MouseEvent.CLICK, _onClick);
		}

		override public function set enabled(value : Boolean) : void {
			if(value==true){
				addEventListener(MouseEvent.MOUSE_DOWN, _onDragStart);
			}
			else{
				removeEventListener(MouseEvent.MOUSE_DOWN, _onDragStart);
				if (_releaseOutside) {
					stage.removeEventListener(MouseEvent.MOUSE_UP, _onDragStop);
				} else {
					removeEventListener(MouseEvent.MOUSE_UP, _onDragStop);
				}
	
				if (_onDragTimer != null) {
					_onDragTimer.stop();
					_onDragTimer.reset();
				}
			}
		}

		protected function _onDragStart(event : Event) : void {
			_frameCount = 0;

			if (_onDragTimer != null) {
				_onDragTimer.stop();
				_onDragTimer.reset();
			} else {
				_onDragTimer = new Timer(50, 9999);
				_onDragTimer.addEventListener(TimerEvent.TIMER, _onDragging);
			}
			_onDragTimer.start();

			if (_releaseOutside) {
				stage.addEventListener(MouseEvent.MOUSE_UP, _onDragStop);
			} else {
				addEventListener(MouseEvent.MOUSE_UP, _onDragStop);
			}

			stage.addEventListener(Event.MOUSE_LEAVE, _onDragStop, false, 0, true);
		}

		private function _onDragging(event : Event) : void {
			var xNew : Number = parent.mouseX - width / 2;
			var yNew : Number = parent.mouseY - height / 2;

			if (xNew < _constraints.left) {
				xNew = _constraints.left;
			}
			if (xNew > _constraints.right) {
				xNew = _constraints.right;
			}
			if ( !_lockHorizontal ) {
				x = xNew ;
			}

			if (yNew < _constraints.top) {
				yNew = _constraints.top;
			}
			if (yNew > _constraints.bottom) {
				yNew = _constraints.bottom;
			}
			if (_lockVertical) {
				y = yNew ;
			}

			if (_hitObject && hitTestObject(_hitObject)) {
				x = _hitObject.x + _hitObject.width / 2 - width / 2;
				y = _hitObject.y + _hitObject.height / 2 - height / 2;
				_onDragStop();
				_submitCallback.call(null);
			}
		}

		protected function _onDragStop(event : Event = null) : void {
			_onDragTimer.stop();
			_onDragTimer.reset();

			if (_releaseOutside) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, _onDragStop);
			} else {
				removeEventListener(MouseEvent.MOUSE_UP, _onDragStop);
			}
		}

		public function set constraints(constraints : Rectangle) : void {
			_constraints = constraints;
		}

		

	}
}
