package com.rockdot.library.view.component.common.box {
	import com.greensock.TweenLite;

	import flash.display.DisplayObject;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class VBoxAnimated extends VBox {
		protected var _duration : Number;

		public function VBoxAnimated(padding : int = 10, pixelSnapping : Boolean = true, inverted : Boolean = false, duration : Number = 0.3) {
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
				var targetY : Number;
				child = getChildAt(0);
				targetY = _inverted ? targetY = -child.height : 0;
				if (child.alpha == 0) {
					child.y = targetY;
					TweenLite.to(child, _duration, {alpha:1});
				} else {
					TweenLite.to(child, _duration, {y:targetY, alpha:1});
				}

				for (var i : int = 1;i < n;i++) {
					child = getChildAt(i);
					prevChild = getChildAt(i - 1);
					if (_inverted) {
						if (_pixelSnapping) targetY = Math.round(targetY - child.height - _padding);
						else targetY = targetY + child.height - _padding;
					} else {
						if (_pixelSnapping) targetY = Math.round(targetY + prevChild.height + _padding);
						else targetY = targetY + prevChild.height + _padding;
					}
					if (child.alpha == 0) {
						child.y = targetY;
						TweenLite.to(child, _duration, {alpha:1});
					} else {
						TweenLite.to(child, _duration, {y:targetY, alpha:1});
					}
				}
			}
		}
	}
}
