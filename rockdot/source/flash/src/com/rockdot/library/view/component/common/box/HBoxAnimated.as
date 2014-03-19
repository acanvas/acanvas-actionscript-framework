package com.rockdot.library.view.component.common.box {
	import com.greensock.TweenLite;

	import flash.display.DisplayObject;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class HBoxAnimated extends HBox {
		protected var _duration : Number;

		public function HBoxAnimated(padding : int = 10, pixelSnapping : Boolean = true, inverted : Boolean = false, duration : Number = 0.3) {
			super(padding, pixelSnapping, inverted);
			_duration = duration;
		}


		override public function addChild(child : DisplayObject) : DisplayObject {
			child.alpha = 0;
			return super.addChild(child);
		}


		override public function addChildAt(child : DisplayObject, index : int) : DisplayObject {
			child.alpha = 0;
			return super.addChildAt(child, index);
		}


		override public function update() : void {
			if (_size != 0)
				_padding = _calcPadding();

			if (numChildren > 0) {
				var n : uint = numChildren;
				var child : DisplayObject;
				var prevChild : DisplayObject;
				var targetX : Number;
				child = getChildAt(0);
				targetX = _inverted ? targetX = -child.width : 0;
				if (child.alpha == 0) {
					child.x = targetX;
					TweenLite.to(child, _duration, {alpha:1});
				} else {
					TweenLite.to(child, _duration, {x:targetX, alpha:1});
				}

				for (var i : int = 1;i < n;i++) {
					child = getChildAt(i);
					prevChild = getChildAt(i - 1);
					if (_inverted) {
						if (_pixelSnapping) targetX = Math.round(targetX - child.width - _padding);
						else targetX = targetX + child.width - _padding;
					} else {
						if (_pixelSnapping) targetX = Math.round(targetX + prevChild.width + _padding);
						else targetX = targetX + prevChild.width + _padding;
					}
					if (child.alpha == 0) {
						child.x = targetX;
						TweenLite.to(child, _duration, {alpha:1});
					} else {
						TweenLite.to(child, _duration, {x:targetX, alpha:1});
					}
				}
			}
		}
	}
}
