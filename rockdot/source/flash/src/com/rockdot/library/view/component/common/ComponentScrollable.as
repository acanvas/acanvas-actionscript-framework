package com.rockdot.library.view.component.common {
	import com.greensock.TweenMax;
	import com.jvm.components.Orientation;
	import com.rockdot.library.view.component.common.scrollable.Scrollbar;
	import com.rockdot.library.view.component.common.scrollable.event.ScrollViewEvent;
	import com.rockdot.library.view.component.common.scrollable.event.SliderEvent;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ComponentScrollable extends SpriteComponent {
		protected var POS : String;
		protected var SIZE : String;
		protected var MOUSE_POS : String;
		protected var SCROLLER : String;
		// _onKeyDown (UP, DOWN, LEFT, RIGHT)
		public var scrollStep : uint = 10;
		//
		protected var _view : SpriteComponent;
		protected var _frame : Shape;
		protected var _scrollbarClass : Class;
		protected var _hScrollbar : Scrollbar;
		protected var _vScrollbar : Scrollbar;
		protected var _bounce : Boolean;
		protected var _touchEnabled : Boolean;
		protected var _keyboardEnabled : Boolean;
		protected var _mouseWheelEnabled : Boolean;
		protected var _snapToPage : Boolean;
		protected var _hideScrollbarsOnIdle : Boolean;
		// Zoom
		protected var _doubleClickToZoom : Boolean;
		protected var _viewZoomed : Boolean;
		protected var _zoomOutValue : Number = 1;
		protected var _zoomInValue : Number = 2;
		protected var _normalizedValueH : Number;
		protected var _normalizedValueV : Number;
		// Touch enabled
		protected var _touching : Boolean;
		protected var _mouseOffsetX : Number;
		protected var _mouseOffsetY : Number;
		// States
		protected var _orientation : String;
		protected var _interaction : Boolean;
		protected var _changing : Boolean;
		protected var _interactionH : Boolean;
		protected var _changingH : Boolean;
		protected var _interactionV : Boolean;
		protected var _changingV : Boolean;

		public function ComponentScrollable(orientation : String, view : SpriteComponent, scrollbarClass : Class) {
			_orientation = orientation;
			_scrollbarClass = scrollbarClass;

			if (_orientation == Orientation.HORIZONTAL) {
				POS = "x";
				SIZE = "width";
				MOUSE_POS = "mouseX";
				SCROLLER = "_hScrollbar";
			} else {
				POS = "y";
				SIZE = "height";
				MOUSE_POS = "mouseY";
				SCROLLER = "_vScrollbar";
			}

			_frame = new Shape();
			var g : Graphics = _frame.graphics;
			g.beginFill(0xff0000);
			g.drawRect(0, 0, 10, 10);
			g.endFill();
			addChild(_frame);

			super();

			_addScrollbars();

			this.view = view;
			keyboardEnabled = true;
		}

		protected function _addScrollbars() : void {
			// H
			if (!_hScrollbar) {
				_hScrollbar = new _scrollbarClass(Orientation.HORIZONTAL, 0, _width);
				_hScrollbar.ignoreCallSetSize = false;
				_hScrollbar.y = Math.round(_frame.y + _height);
				_hScrollbar.addEventListener(SliderEvent.VALUE_CHANGE, _onHScrollbarChange, false, 0, true);
				_hScrollbar.mouseWheelSensitivity = 10;
				_hScrollbar.addEventListener(SliderEvent.INTERACTION_START, _onScrollbarInteractionStart, false, 0, true);
				_hScrollbar.addEventListener(SliderEvent.INTERACTION_END, _onScrollbarInteractionEnd, false, 0, true);
				_hScrollbar.addEventListener(SliderEvent.CHANGE_START, _onScrollbarChangeStart, false, 0, true);
				_hScrollbar.addEventListener(SliderEvent.CHANGE_END, _onScrollbarChangeEnd, false, 0, true);
				addChild(_hScrollbar);
			} else {
				_hScrollbar.max = _view.width - _width;
				trace("[ScrollView] WARNING: ScrollbarH already created.");
			}

			// V
			if (!_vScrollbar) {
				_vScrollbar = new _scrollbarClass(Orientation.VERTICAL, 0, _height);
				_vScrollbar.ignoreCallSetSize = false;
				_vScrollbar.x = Math.round(_frame.x + _width);
				_vScrollbar.addEventListener(SliderEvent.VALUE_CHANGE, _onVScrollbarChange, false, 0, true);
				_vScrollbar.mouseWheelSensitivity = 10;
				_vScrollbar.addEventListener(SliderEvent.INTERACTION_START, _onScrollbarInteractionStart, false, 0, true);
				_vScrollbar.addEventListener(SliderEvent.INTERACTION_END, _onScrollbarInteractionEnd, false, 0, true);
				_vScrollbar.addEventListener(SliderEvent.CHANGE_START, _onScrollbarChangeStart, false, 0, true);
				_vScrollbar.addEventListener(SliderEvent.CHANGE_END, _onScrollbarChangeEnd, false, 0, true);
				addChild(_vScrollbar);
			} else {
				_vScrollbar.max = _view.height - _height;
				trace("[ScrollView] WARNING: ScrollbarV already created.");
			}
		}

		protected function _onScrollbarInteractionStart(event : SliderEvent) : void {
			if (event.target == _hScrollbar) _interactionH = true;
			else _interactionV = true;
			interactionStart();
		}

		protected function _onScrollbarInteractionEnd(event : SliderEvent) : void {
			if (event.target == _hScrollbar) _interactionH = false;
			else _interactionV = false;
			if (!_interactionH && !_interactionV) interactionEnd();
		}

		protected function _onScrollbarChangeStart(event : SliderEvent) : void {
			if (event.target == _hScrollbar) _changingH = true;
			else _changingV = true;
			changeStart();
		}

		protected function _onScrollbarChangeEnd(event : SliderEvent) : void {
			if (event.target == _hScrollbar) _changingH = false;
			else _changingV = false;
			if (!_changingH && !_changingV) changeEnd();
		}

		protected function interactionStart() : void {
			if (!_interaction) {
				_interaction = true;
				dispatchEvent(new ScrollViewEvent(ScrollViewEvent.INTERACTION_START));
			}
		}

		protected function interactionEnd() : void {
			if (_interaction) {
				_interaction = false;
				dispatchEvent(new ScrollViewEvent(ScrollViewEvent.INTERACTION_END));
			}
		}

		protected function changeStart() : void {
			if (!_changing) {
				_changing = true;
				if (_hideScrollbarsOnIdle) {
					if (_hScrollbar.enabled) TweenMax.to(_hScrollbar, 0.2, {autoAlpha:1});
					if (_vScrollbar.enabled) TweenMax.to(_vScrollbar, 0.2, {autoAlpha:1});
				}
				dispatchEvent(new ScrollViewEvent(ScrollViewEvent.CHANGE_START));
			}
		}

		protected function changeEnd() : void {
			if (_changing) {
				_changing = false;
				if (_hideScrollbarsOnIdle) {
					if (_hScrollbar.enabled) TweenMax.to(_hScrollbar, 0.2, {autoAlpha:0});
					if (_vScrollbar.enabled) TweenMax.to(_vScrollbar, 0.2, {autoAlpha:0});
				}
				dispatchEvent(new ScrollViewEvent(ScrollViewEvent.CHANGE_END));
			}
		}

		public function updateScrollbars() : void {
			_hScrollbar.enabled = _view.width > _width;
			_hScrollbar.max = _view.width - _width;

			_vScrollbar.enabled = _view.height > _height;
			_vScrollbar.max = _view.height - _height;
			_updateThumbs();
		}

		protected function _updateThumbs() : void {
			_hScrollbar.pages = _view.width / _width;
			_vScrollbar.pages = _view.height / _height;
		}

		public function get view() : SpriteComponent {
			return _view;
		}

		public function set view(view : SpriteComponent) : void {
			if (view != _view) {
				clearMomentum();
				if (_view) removeChild(_view);
				_view = view;
				_view.mask = _frame;
				_view.doubleClickEnabled = _doubleClickToZoom;
				touchEnabled = _touchEnabled;
				doubleClickToZoom = _doubleClickToZoom;
				addChildAt(_view, 0);
				updateScrollbars();
				_hScrollbar.value = _vScrollbar.value = 0;
			}
		}

		public function get keyboardEnabled() : Boolean {
			return _keyboardEnabled;
		}

		public function set keyboardEnabled(value : Boolean) : void {
			_keyboardEnabled = value;
			if (_keyboardEnabled) addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, false, 0, true);
			else removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		}

		protected function _onKeyDown(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case Keyboard.UP:
					if (_vScrollbar.enabled) {
						clearMomentum();
						_vScrollbar.interactionStart(true, false);
						_vScrollbar.value -= scrollStep;
						_vScrollbar.interactionEnd();
					}
					break;
				case Keyboard.DOWN:
					if (_vScrollbar.enabled) {
						clearMomentum();
						_vScrollbar.interactionStart(true, false);
						_vScrollbar.value += scrollStep;
						_vScrollbar.interactionEnd();
					}
					break;
				case Keyboard.LEFT:
					if (_hScrollbar.enabled) {
						clearMomentum();
						_hScrollbar.interactionStart(true, false);
						_hScrollbar.value -= scrollStep;
						_hScrollbar.interactionEnd();
					}
					break;
				case Keyboard.RIGHT:
					if (_hScrollbar.enabled) {
						clearMomentum();
						_hScrollbar.interactionStart(true, false);
						_hScrollbar.value += scrollStep;
						_hScrollbar.interactionEnd();
					}
					break;
				case Keyboard.SPACE:
					if (_vScrollbar.enabled) {
						clearMomentum();
						if (!event.shiftKey) _vScrollbar.pageDown();
						else _vScrollbar.pageUp();
					}
					break;
				case Keyboard.PAGE_DOWN:
					if (_vScrollbar.enabled) {
						clearMomentum();
						_vScrollbar.pageDown();
					}
					break;
				case Keyboard.PAGE_UP:
					if (_vScrollbar.enabled) {
						clearMomentum();
						_vScrollbar.pageUp();
					}
					break;
				case Keyboard.HOME:
					if (this[SCROLLER].enabled) {
						this[SCROLLER].killPageTween();
						clearMomentum();
						this[SCROLLER].scrollToPage(0);
					}
					break;
				case Keyboard.END:
					if (this[SCROLLER].enabled) {
						this[SCROLLER].killPageTween();
						clearMomentum();
						this[SCROLLER].scrollToPage(this[SCROLLER].pages, 0, true);
					}
					break;
				default:
			}
		}

		public function get mouseWheelEnabled() : Boolean {
			return _mouseWheelEnabled;
		}

		public function set mouseWheelEnabled(value : Boolean) : void {
			_mouseWheelEnabled = value;
			if (_mouseWheelEnabled) addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel, false, 0, true);
			else removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}

		private function _onMouseWheel(event : MouseEvent) : void {
			clearMomentum();
			if (event.shiftKey) {
				if (_hScrollbar.enabled) _hScrollbar.onMouseWheel(event);
				else if (_vScrollbar.enabled) _vScrollbar.onMouseWheel(event);
			} else {
				if (_vScrollbar.enabled) _vScrollbar.onMouseWheel(event);
				else if (_hScrollbar.enabled) _hScrollbar.onMouseWheel(event);
			}
		}

		protected function _onHScrollbarChange(event : SliderEvent) : void {
			_view.x = -event.value;
		}

		protected function _onVScrollbarChange(event : SliderEvent) : void {
			_view.y = -event.value;
		}

		public function get hScrollbar() : Scrollbar {
			return _hScrollbar;
		}

		public function get vScrollbar() : Scrollbar {
			return _vScrollbar;
		}

		override public function set enabled(value : Boolean) : void {
			if (value != _enabled) {
				super.enabled = value;
				if (_enabled) {
					keyboardEnabled = _keyboardEnabled;
					mouseWheelEnabled = _mouseWheelEnabled;
					updateScrollbars();
				} else {
					removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
					removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
				}
			}
		}

		override public function render() : void {
			_hScrollbar.y = _height - _hScrollbar.height;
			_vScrollbar.x = _width - _vScrollbar.width;
			_frame.width = _width;
			_frame.height = _height;
			updateScrollbars();
		}

		public function get bounce() : Boolean {
			return _bounce;
		}

		public function set bounce(value : Boolean) : void {
			if (value != _bounce) _bounce = _hScrollbar.bounce = _vScrollbar.bounce = value;
		}

		public function get snapToPage() : Boolean {
			return _snapToPage;
		}

		public function set snapToPage(value : Boolean) : void {
			if (value != _snapToPage) _snapToPage = _hScrollbar.snapToPage = _vScrollbar.snapToPage = value;
		}

		public function get doubleClickToZoom() : Boolean {
			return _doubleClickToZoom;
		}

		public function set doubleClickToZoom(value : Boolean) : void {
			_doubleClickToZoom = _view.doubleClickEnabled = value;
			if (_doubleClickToZoom) _view.addEventListener(MouseEvent.DOUBLE_CLICK, _onViewDoubleClick, false, 0, true);
			else _view.removeEventListener(MouseEvent.DOUBLE_CLICK, _onViewDoubleClick);
		}

		private function _onViewDoubleClick(event : MouseEvent) : void {
			zoom(_viewZoomed ? _zoomOutValue : _zoomInValue, event.target.mouseX, event.target.mouseY);
			_viewZoomed = !_viewZoomed;
		}

		public function zoom(scale : Number, xPos : Number, yPos : Number) : void {
			if (_hScrollbar.enabled) _normalizedValueH = _hScrollbar.value / _hScrollbar.max;
			if (_vScrollbar.enabled) _normalizedValueV = _vScrollbar.value / _vScrollbar.max;

			interactionStart();
			changeStart();

			_normalizedValueH = (xPos - _width / (2 * scale)) / ((_view.width / _view.scaleX) - _width / scale);
			_normalizedValueV = (yPos - _height / (2 * scale)) / ((_view.height / _view.scaleY) - _height / scale);
			TweenMax.to(_view, 0.3, {scaleX:scale, scaleY:scale, onUpdate:_keepPos, onComplete:_onZoomConplete});
			interactionEnd();
		}

		public function get zoomInValue() : Number {
			return _zoomInValue;
		}

		public function set zoomInValue(zoomInValue : Number) : void {
			_zoomInValue = zoomInValue;
		}

		private function _keepPos() : void {
			updateScrollbars();

			var valH : int = _normalizedValueH * _hScrollbar.max;
			if (valH < 0) valH = 0;
			else if (valH > _hScrollbar.max) valH = _hScrollbar.max;

			var valV : int = _normalizedValueV * _vScrollbar.max;
			if (valV < 0) valV = 0;
			else if (valV > _vScrollbar.max) valV = _vScrollbar.max;

			_hScrollbar.value = valH;
			_vScrollbar.value = valV;
		}

		private function _onZoomConplete() : void {
			changeEnd();
		}

		public function get touchEnabled() : Boolean {
			return _touchEnabled;
		}

		public function set touchEnabled(value : Boolean) : void {
			_touchEnabled = value;

			_hScrollbar.momentumEnabled = _touchEnabled;
			_vScrollbar.momentumEnabled = _touchEnabled;
			if (_touchEnabled) _view.addEventListener(MouseEvent.MOUSE_DOWN, _onViewMouseDown, false, 0, true);
			else _view.removeEventListener(MouseEvent.MOUSE_DOWN, _onViewMouseDown);
		}

		protected function _onViewMouseDown(event : MouseEvent) : void {
			_touching = true;
			if (_hScrollbar.enabled) _hScrollbar.interactionStart(false, false);
			if (_vScrollbar.enabled) _vScrollbar.interactionStart(false, false);
			_mouseOffsetX = stage.mouseX - _view.x;
			_mouseOffsetY = stage.mouseY - _view.y;
			stage.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove, false, 0, true);
		}

		protected function _onStageMouseUp(event : MouseEvent) : void {
			_touching = false;
			if (_hScrollbar.enabled) _hScrollbar.interactionEnd();
			if (_vScrollbar.enabled) _vScrollbar.interactionEnd();
			if (stage) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
			}
		}

		public function clearMomentum() : void {
			_hScrollbar.clearMomentum();
			_vScrollbar.clearMomentum();
		}

		protected function _onStageMouseMove(event : MouseEvent) : void {
			if (_hScrollbar.enabled) _hScrollbar.value = _mouseOffsetX - stage.mouseX;
			if (_vScrollbar.enabled) _vScrollbar.value = _mouseOffsetY - stage.mouseY;
			// event.updateAfterEvent();
		}

		public function get zoomOutValue() : Number {
			return _zoomOutValue;
		}

		public function set zoomOutValue(zoomOutValue : Number) : void {
			_zoomOutValue = zoomOutValue;
		}

		public function get hideScrollbarsOnIdle() : Boolean {
			return _hideScrollbarsOnIdle;
		}

		public function set hideScrollbarsOnIdle(value : Boolean) : void {
			_hideScrollbarsOnIdle = value;
			if (_hScrollbar.enabled) TweenMax.to(_hScrollbar, 0.2, {autoAlpha:_hideScrollbarsOnIdle ? 0 : 1});
			if (_vScrollbar.enabled) TweenMax.to(_vScrollbar, 0.2, {autoAlpha:_hideScrollbarsOnIdle ? 0 : 1});
		}
	}
}
