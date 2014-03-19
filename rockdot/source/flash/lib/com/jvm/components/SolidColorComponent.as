package com.jvm.components {
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class SolidColorComponent extends SpriteComponent {
		protected var _color : uint;
		public function SolidColorComponent(color : uint) {
			_color = color;
			super();
		}


		override public function render() : void {
			graphics.clear();
			graphics.beginFill(_color);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			super.render();
		}
	}
}
