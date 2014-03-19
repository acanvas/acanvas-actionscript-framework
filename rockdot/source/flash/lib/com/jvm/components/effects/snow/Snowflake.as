package com.jvm.components.effects.snow {
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class Snowflake extends Shape {
		public var speed : Number = 0;		public var angle : Number = 0;

		public function Snowflake(size : uint = 30) {
			var matrix : Matrix = new Matrix();
			var colors : Array = [0xFFFFFF,0xFFFFFF];
			var alphas : Array = [1,0];
			var ratios : Array = [80,255];
			matrix.createGradientBox(size, size);
            
			graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, matrix);
			graphics.drawCircle(size * 0.5, size * 0.5, size);
			graphics.endFill();
		}
	}
}
