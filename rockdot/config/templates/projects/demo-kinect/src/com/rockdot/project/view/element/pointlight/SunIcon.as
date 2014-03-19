package com.rockdot.project.view.element.pointlight {
	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	/**
	 * @author nilsdoehring
	 */
	public class SunIcon extends Sprite {
		public function SunIcon() {
			buttonMode = true;
			graphics.beginFill(0, 0);
			graphics.drawCircle(0, 0, 14);
			graphics.endFill();
			graphics.lineStyle(1, 0xffc040);
			graphics.drawCircle(0, 0, 4);
			filters = [new GlowFilter(0, 1, 4, 4, 8)];
			for (var i : int = 0; i < 10; i++) {
				var sin : Number = Math.sin(Math.PI * 2 * i / 10);
				var cos : Number = Math.cos(Math.PI * 2 * i / 10);
				graphics.moveTo(sin * 7, cos * 7);
				graphics.lineTo(sin * 12, cos * 12);
			}
		}
	}
}
