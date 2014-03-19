package com.rockdot.library.view.component.common.box {
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import flash.display.DisplayObject;
	import flash.text.TextField;


	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class VBox extends HBox {
		public function VBox(padding : int = 10, pixelSnapping : Boolean = true, inverted : Boolean = false) {
			_padding = padding;
			_pixelSnapping = pixelSnapping;
			_inverted = inverted;
			_ignoreCallSetSize = false;
		}

		override public function setSize(w : int, h : int) : void {
			var child : DisplayObject;
			for (var i : int = 0; i < numChildren; i++) {
				child = getChildAt(i);
				if (child is TextField) (child as TextField).width = w;
			}
			_height = h;
			super.setSize(w, 0);//sets only width of children
		}
		
		
		override public function setFixedSize(size : uint) : void {
			if (size != _size) {
				_size = size;
				if (numChildren > 1) {
					_padding = _calcPadding();
					update();
				}
			}
		}


		override protected function _calcPadding() : Number {
			var n : uint = numChildren;
			var totalHeight : Number = 0;
			for (var i : int = 0;i < n;i++) {
				if(getChildAt(i) is ISpriteComponent){
					totalHeight += (getChildAt(i) as ISpriteComponent ).getHeight();
				}
				else{
					totalHeight += getChildAt(i).height;
				}
			}

			return (_size - totalHeight) / (numChildren - 1);
		}


		override public function update() : void {
			if (_size != 0)
				_padding = _calcPadding();

			if (numChildren > 0) {
				var n : uint = numChildren;
				var child : DisplayObject;
				var prevChild : DisplayObject;
				child = getChildAt(0);
				var h : int = child is ISpriteComponent ? (child as ISpriteComponent).getHeight() : child.height;
				child.y = _inverted ? - h : 0;
				for (var i : int = 1;i < n;i++) {
					child = getChildAt(i);
					prevChild = getChildAt(i - 1);
					if (_inverted) {
						h = child is ISpriteComponent ? (child as ISpriteComponent).getHeight() : child.height;
						if (_pixelSnapping) child.y = Math.round(prevChild.y - h - _padding);
						else child.y = prevChild.y + h - _padding;
					} else {
						h = prevChild is ISpriteComponent ? (prevChild as ISpriteComponent).getHeight() : prevChild.height;
						if (_pixelSnapping) child.y = Math.round(prevChild.y + h + _padding);
						else child.y = prevChild.y + h + _padding;
					}
				}
			}
		}
	}
}
