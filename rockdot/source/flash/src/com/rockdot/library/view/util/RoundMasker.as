package com.rockdot.library.view.util {
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.Shape;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class RoundMasker extends Shape {
		private var _progress : Number;
		private var _g : Graphics;
		private var _h : uint;
		private var _radiusX : Number;
		private var _radiusY : Number;
		private var _centerX : Number;
		private var _centerY : Number;
		private var _density : uint;
		private var _startAngle : Number;

		public function RoundMasker(w : uint, h : uint, density : uint = 1, startAngle : Number = Math.PI * 0.5) {
			_h = h;
			_density = density;
			_startAngle = startAngle;
			_radiusX = w * 0.5;
			_radiusY = h * 0.5;
			_centerX = _radiusX;
			_centerY = _radiusY;
			
			_progress = 0;
			_g = graphics;
		}

		
		public function get progress() : Number {
			return _progress;
		}

		
		public function set progress(progress : Number) : void {
			if (progress < 0) _progress = 0;			else if (progress > 1) _progress = 1;
			else _progress = progress;
			
			_g.clear();
			_g.lineStyle(1, 0, 1, false, "normal", CapsStyle.NONE);
			
			
			var angle : Number;
			for (var i : Number = 0;i < _progress;i += 0.1 / (10*_density)) {
				_g.moveTo(_centerX, _centerY);
				angle = i * Math.PI * 2 - _startAngle;
				_g.lineTo(Math.cos(angle) * _radiusX + _centerX, Math.sin(angle) * _radiusY + _centerY);
			}
		}
	}
}
