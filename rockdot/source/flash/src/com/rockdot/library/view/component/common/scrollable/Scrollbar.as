package com.rockdot.library.view.component.common.scrollable {
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.rockdot.library.view.component.common.scrollable.event.SliderEvent;
	import com.jvm.utils.NumericStepper;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Scrollbar extends Slider {
		public static var firstPageScrollIntervall : uint = 300;
		public static var pageScrollIntervall : uint = 50;
		protected var _pageScrollDuration : Number;
		protected var _pageScrollDistance : Number;
		protected var _isTweening : Boolean;
		protected var _pageStepper : NumericStepper;
		protected var _pages : Number;
		protected var _snapToPage : Boolean;
		protected var _bounce : Boolean;
		protected var _timer : Timer;

		public function Scrollbar(orientation : String, max : Number, size : Number, pageScrollDuration : Number = 0.7) {
			super(orientation, 0, max, size, false);
			_pageScrollDuration = pageScrollDuration;
			_pageStepper = new NumericStepper(0, 0, 1, false);
			_timer = new Timer(firstPageScrollIntervall);
			_timer.addEventListener(TimerEvent.TIMER, _onTimer, false, 0, true);
			mouseWheelEnabled = false;
			pages ||= 1;
		}


		override public function interactionStart(preventMomentum : Boolean = false, addMouseListeners : Boolean = true) : void {
			if (!_interaction) {
				killPageTween();
				super.interactionStart(preventMomentum, addMouseListeners);
			}
		}


		override public function interactionEnd() : void {
			if (_interaction) {
				_interaction = false;
				if(stage){
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
					stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
				}

				dispatchEvent(new SliderEvent(SliderEvent.INTERACTION_END, _value));

				if (_momentumEnabled) {
					removeEventListener(Event.ENTER_FRAME, _calcMomentum);
					if (_snapToPage) {
						if (!_isTweening) snapToCurrentPage();
					} else if (_bounce) {
						if (!checkOuterFrame() && !_isTweening) momentumStart();
					} else momentumStart();
				} else {
					if (_snapToPage) {
						if (!_isTweening) snapToCurrentPage();
					} else if (_bounce) {
						if (!checkOuterFrame() && !_isTweening) momentumStart();
					} else if (!_isTweening) {
						changeEnd();
					}
				}
			}
		}


		public function pageUp() : void {
			if (_snapToPage) {
				scrollToPage(_pageStepper.value - 1);
			} else {
				changeStart();
				var val : Number = Math.max(0, value - _pageScrollDistance);
				if (_pageScrollDuration == 0) {
					value = val;
					changeEnd();
				} else {
					_isTweening = true;
					TweenMax.to(this, _pageScrollDuration, {value:val, ease:Expo.easeOut, onComplete:_onTweenComplete});
				}
			}
		}


		public function pageDown() : void {
			if (_snapToPage) {
				scrollToPage(_pageStepper.value + 1);
			} else {
				changeStart();
				var val : Number = Math.min(_max, value + _pageScrollDistance);
				if (_pageScrollDuration == 0) {
					value = val;
					changeEnd();
				} else {
					_isTweening = true;
					TweenMax.to(this, _pageScrollDuration, {value:val, ease:Expo.easeOut, onComplete:_onTweenComplete});
				}
			}
		}


		public function scrollToPage(page : int, offset : Number = 0, force : Boolean = false) : void {
			_pageStepper.jumpTo(page);
			if (page == _pageStepper.value || offset != 0 || force) {
				changeStart();
				var val : Number = _pageStepper.value * _pageScrollDistance + offset;
				if (_pageScrollDuration == 0) {
					value = val;
					changeEnd();
				} else {
					_isTweening = true;
					TweenMax.to(this, _pageScrollDuration, {value:val, ease:Expo.easeOut, onComplete:_onTweenComplete});
				}
			}
		}


		private function _onTweenComplete() : void {
			_isTweening = false;
			changeEnd();
		}


		public function get currentPage() : uint {
			return _pageStepper.jumpTo(Math.round(_value / _pageScrollDistance));
		}


		private function get _rawPagePos() : Number {
			return _value / _pageScrollDistance;
		}


		private function _startPageScrollTimer() : void {
			_pageScroll();
			_timer.delay = firstPageScrollIntervall;
			_timer.start();
		}


		private function _stopPageScrollTimer() : void {
			_timer.reset();
		}


		private function _pageScroll() : void {
			if (_snapToPage) {
				var thumbPos : int = Math.round((currentPage * _pageScrollDistance - _min) / (_max - _min) * (_size - _thumbSize));
				if (thumbPos > this[MOUSE_POS]) pageUp();
				else if (thumbPos + _thumbSize < this[MOUSE_POS]) pageDown();
			} else {
				if (_thumb[POS] > this[MOUSE_POS]) pageUp();	
				else if (_thumb[POS] + _thumbSize < this[MOUSE_POS]) pageDown();
			}
		}


		private function _onTimer(event : TimerEvent) : void {
			_timer.delay = pageScrollIntervall;
			_pageScroll();
		}


		override protected function _onThumbMouseDown(event : MouseEvent) : void {
			killPageTween();
			super._onThumbMouseDown(event);
		}


		public function killPageTween() : void {
			if (_pageScrollDuration != 0) {
				TweenMax.to(this, 0, {value: _value});
				_isTweening = false;
			}
		}


		override protected function _onBackgroundMouseDown(event : MouseEvent) : void {
			interactionStart(true, false);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
			_startPageScrollTimer();
		}


		override protected function _onStageMouseUp(event : MouseEvent) : void {
			_stopPageScrollTimer();
			interactionEnd();
		}


		/**
		 * 
		 * MOMENTUM
		 *  
		 */
		override protected function _applyMomentum(event : Event) : void {
			_momentum *= momentumFriction;
			if (Math.abs(_momentum) < momentumClearThreshold) {
				// Stop momentum
				value += _momentum;
				clearMomentum();
				if (_value < _min) value = _min;
				else if (_value > _max) value = _max;
				momentumEnd();
			} else {
				// Apply momentum
				value += _momentum;
				if (!_bounce) {
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
		}


		public function snapToCurrentPage() : void {
			if (_momentum < 0) scrollToPage(currentPage - (_rawPagePos - currentPage < 0 ? 1 : 0), 0, true);
			else if (_momentum > 0) scrollToPage(currentPage + (_rawPagePos - currentPage > 0 ? 1 : 0), 0, true);
			else scrollToPage(currentPage);
		}


		public function checkOuterFrame() : Boolean {
			if (_value < _min) {
				scrollToPage(0);
				return true;
			} else if (_value > _max) {
				scrollToPage(Math.ceil(pages), 0, true);
				return true;
			}
			return false;
		}


		public function get pages() : Number {
			return _pages;
		}


		public function set pages(pages : Number) : void {
			if (pages != _pages) {
				_pages = Math.max(pages, 1);
				_pageStepper.max = _pages - 1;
				_pageScrollDistance = _max / (_pages - 1);
				_thumb[SIZE] = _thumbSize = Math.max(10, Math.round(_size / _pages));
//				render();
			}
		}


		override public function set value(value : Number) : void {
			if (value < _min) value = _bounce ? _min + (value - _min) * 0.5 : _min;
			else if (value > _max) value = _bounce ? _max + (value - _max) * 0.5 : _max;
			if (!_continuous) value = Math.round(value);
			
			if (value != _value) {
				_value = value;
				render();
				dispatchEvent(new SliderEvent(SliderEvent.VALUE_CHANGE, _value));
			}
		}


		override public function render() : void {
			var pos : int;
			var offset : int;
			var maxPos : uint;
			var thumbSize : uint;
			maxPos = _size - _thumbSize;
			pos = Math.round((_value - _min) / (_max - _min) * maxPos);
			if (pos < 0) {
				offset = -pos;
				thumbSize = Math.max(10, Math.round(_size / _pages) - offset * 4);
				pos = 0;
			} else if (pos > maxPos) {
				offset = pos - maxPos;
				thumbSize = Math.max(10, Math.round(_size / _pages) - offset * 4);
				pos = _size - thumbSize;
			}
			else{
				offset = 0;
				thumbSize = Math.max(10, Math.round(_size / _pages) - offset * 4);
			}
			_thumb[SIZE] = _thumbSize = thumbSize;
			_thumb[POS] = pos;
		}


		override public function set max(max : Number) : void {
			super.max = Math.max(0, Math.round(max));
			_pageScrollDistance = _max / (_pages - 1);
		}


		public function get snapToPage() : Boolean {
			return _snapToPage;
		}


		public function set snapToPage(value : Boolean) : void {
			_snapToPage = value;
		}


		public function get bounce() : Boolean {
			return _bounce;
		}


		public function set bounce(value : Boolean) : void {
			_bounce = value;
		}
	}
}
