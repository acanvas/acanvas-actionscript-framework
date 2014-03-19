package com.rockdot.library.view.component.common.box {
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.DisplayObject;


	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class HBox extends SpriteComponent {
		protected var _padding : Number;
		protected var _size : uint;
		protected var _pixelSnapping : Boolean;
		protected var _inverted : Boolean;

		public function HBox(padding : int = 10, pixelSnapping : Boolean = true, inverted : Boolean = false) {
			_padding = padding;
			_pixelSnapping = pixelSnapping;
			_inverted = inverted;
			_ignoreCallSetSize = false;
		}


		override public function addChild(child : DisplayObject) : DisplayObject {
			super.addChild(child);
			update();
			return child;
		}


		override public function removeChild(child : DisplayObject) : DisplayObject {
			super.removeChild(child);
			update();
			return child;
		}


		override public function addChildAt(child : DisplayObject, index : int) : DisplayObject {
			super.addChildAt(child, index);
			update();
			return child;
		}


		override public function removeChildAt(index : int) : DisplayObject {
			var c : DisplayObject = super.removeChildAt(index);
			update();
			return c;
		}


		public function get padding() : Number {
			return _padding;
		}


		public function set padding(value : Number) : void {
			if (value != _padding) {
				_padding = value;
				update();
			}
		}


		public function setFixedSize(size : uint) : void {
			if (size != _size) {
				_size = size;
				if (numChildren > 1) {
					_padding = _calcPadding();
					update();
				}
			}
		}


		protected function _calcPadding() : Number {
			var n : uint = numChildren;
			var totalWidth : Number = 0;
			for (var i : int = 0;i < n;i++) {
				if(getChildAt(i) is ISpriteComponent){
					totalWidth += (getChildAt(i) as ISpriteComponent ).getWidth();
				}
				else{
					totalWidth += getChildAt(i).width;
				}
			}

			return (_size - totalWidth) / (numChildren - 1);
		}
		
		
		public function update() : void {
			if (_size != 0)
				_padding = _calcPadding();

			if (numChildren > 0) {
				var n : uint = numChildren;
				var child : DisplayObject;
				var prevChild : DisplayObject;
				child = getChildAt(0);
				child.x = _inverted ? -child.width : 0;
				for (var i : int = 1;i < n;i++) {
					child = getChildAt(i);
					prevChild = getChildAt(i - 1);
					if (_inverted) {
						if (_pixelSnapping) child.x = Math.round(prevChild.x - child.width - _padding);
						else child.x = prevChild.x - child.width - _padding;
					} else {
						if (_pixelSnapping) child.x = Math.round(prevChild.x + prevChild.width + _padding);
						else child.x = prevChild.x + prevChild.width + _padding;
					}
				}
			}
		}


		public function get pixelSnapping() : Boolean {
			return _pixelSnapping;
		}


		public function set pixelSnapping(pixelSnapping : Boolean) : void {
			if (pixelSnapping != _pixelSnapping) {
				_pixelSnapping = pixelSnapping;
				update();
			}
		}


		public function get inverted() : Boolean {
			return _inverted;
		}


		public function set inverted(value : Boolean) : void {
			if (value != _inverted) {
				_inverted = value;
				update();
			}
		}
	}
}
