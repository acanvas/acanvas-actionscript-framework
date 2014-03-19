package com.rockdot.library.view.component.common.form.carousel {
	import com.greensock.TweenLite;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.events.Event;


	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Carousel extends SpriteComponent {
		public var speed : Number;
		protected var _scaleRange : int;
		protected var _items : Array;
		protected var _angles : Array;
		protected var _radiusX : Number;
		protected var _radiusY : Number;
		protected var _turnAngle : Number;
		protected var _curItemId : uint;
		protected var _centerAngle : Number;

		public function Carousel(w : uint, h : uint, scaleRange : int = 2, speed : Number = 0.5) {
			_width = w;
			_height = h;
			_scaleRange = scaleRange;
			_radiusX = w * 0.5;
			_radiusY = h * 0.5;
			this.speed = speed;
			_items = [];
			_angles = [];
			_centerAngle = Math.PI * 2.5;
		}


		public function addItem(item : CarouselItem) : void {
			addChild(item);
			item.id = _items.length;
			_items.push(item);
			_arrange();
		}


		private function _arrange() : void {
			var n : uint = _items.length;
			_turnAngle = (Math.PI * 2) / n;
			for (var i : int = 0;i < n;i++) {
				_items[i].angle = _angles[i] = ((n - 1) - i) * _turnAngle;
			}
		}


		public function start() : void {
			addEventListener(Event.ENTER_FRAME, _loop);
		}


		public function pause() : void {
			removeEventListener(Event.ENTER_FRAME, _loop);
		}


		public function nextItem(snapToCenter : Boolean = true, animate : Boolean = true, duration : Number = 0.5) : void {
			turn(-1, snapToCenter, animate, duration);
		}


		public function prevItem(snapToCenter : Boolean = true, animate : Boolean = true, duration : Number = 0.5) : void {
			turn(1, snapToCenter, animate, duration);
		}


		public function turn(steps : Number, snapToCenter : Boolean, animate : Boolean, duration : Number) : void {
			var n : uint = _items.length;
			var item : CarouselItem;

			var offset : Number = snapToCenter ? (_centerAngle - _angles[_curItemId]) % (_turnAngle * _items.length) : 0;
			if (Math.abs(offset) >= _turnAngle) offset = 0;

			for (var i : int = 0;i < n;i++) {
				item = _items[i];
				_angles[i] -= steps * _turnAngle - offset;
				TweenLite.to(item, animate ? duration : 0, {angle:_angles[i]});
			}
			if (animate) {
				addEventListener(Event.ENTER_FRAME, update);
				TweenLite.killDelayedCallsTo(_removeUpdateListener);
				TweenLite.delayedCall(duration, _removeUpdateListener);
			} else {
				update();
			}
		}

		public function stopAnimation() : void {
			TweenLite.killDelayedCallsTo(_removeUpdateListener);
			_removeUpdateListener();
		}

		public function move(offset : Number) : void {
			var n : uint = _items.length;
			for (var i : int = 0;i < n;i++) {
				_items[i].angle = _angles[i] += offset;
			}
			update();
		}


		public function set debug(debug : Boolean) : void {
			if (debug) {
				var xPos : Number;
				var yPos : Number;
				graphics.beginFill(0);
				for (var i : Number = 0;i < 2 * Math.PI;i += 0.05) {
					xPos = Math.cos(i) * _radiusX + _radiusX;
					yPos = Math.sin(i) * _radiusY + _radiusY;
					var scale : Number = 10 - (10 - yPos / _height) * (1 - 1 / _scaleRange);
					graphics.drawCircle(xPos, yPos, scale);
				}
			} else {
				graphics.clear();
			}
		}


		private function _removeUpdateListener() : void {
			removeEventListener(Event.ENTER_FRAME, update);
		}


		private function _loop(event : Event) : void {
			move(speed * 0.1);
		}


		public function centerFirstItem() : void {
			var n : uint = _items.length;

			for (var i : int = 0;i < n;i++) {
				_items[i].angle = _angles[i] += Math.PI * 0.5 + _turnAngle;
			}
			update();
		}


		public function update(event : Event = null) : void {
			var n : uint = _items.length;

			var item : CarouselItem;
			for (var i : int = 0;i < n;i++) {
				item = _items[i];
				item.x = Math.cos(item.angle) * _radiusX + _radiusX;
				item.y = Math.sin(item.angle) * _radiusY + _radiusY;
				item.scaleX = item.scaleY = 1 - (1 - item.y / _height) * (1 - 1 / _scaleRange);
			}

			var zSort : Array = _items.slice();
			zSort.sortOn("scaleX", Array.NUMERIC);
			for (i = 0;i < n;i++) {
				_onItemUpdate(CarouselItem(addChild(zSort[i])), i);
			}
			_curItemId = zSort[zSort.length - 1].id;
		}


		protected function _onItemUpdate(item : CarouselItem, i : int) : void {
			// Override for custom behavior
		}


		public function get currentItemId() : int {
			return _curItemId;
		}


		public function get numItems() : uint {
			return _items.length;
		}
	}
}
