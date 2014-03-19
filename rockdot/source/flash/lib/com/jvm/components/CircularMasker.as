package com.jvm.components {
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Graphics;


	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class CircularMasker extends SpriteComponent {
		private var _progress : Number;
		private var _g : Graphics;
		private var _radiusX : Number;
		private var _radiusY : Number;
		private var _startAngle : Number;
		private var _accuracy : Number;
		private var _step : Number;

		public function CircularMasker(w : uint, h : uint, startAngle : Number = 0, clockwise : Boolean = true, accuracy : uint = 360) {
			_progress = 0;
			_radiusX = w * 0.5;
			_radiusY = h * 0.5;
			_startAngle = -(startAngle / 180) * Math.PI + Math.PI * 0.5;
			_accuracy = accuracy == 0 ? 1 : (1 / (accuracy));
			_step = Math.PI * (clockwise ? 2 : -2);
			_g = graphics;
		}

		
		public function get progress() : Number {
			return _progress;
		}

		
		public function set progress(progress : Number) : void {
			if (progress < 0) progress = 0;
			else if (progress > 1) progress = 1;
			
			if (progress != _progress) {
				_progress = progress;
				_g.clear();				_g.beginFill(0);
				_g.moveTo(_radiusX, _radiusY);
			
				var angle : Number;
				for (var i : Number = 0; i < _progress; i += _accuracy) {
					angle = i * _step - _startAngle;
					_g.lineTo(Math.cos(angle) * _radiusX + _radiusX, Math.sin(angle) * _radiusY + _radiusY);
				}
			}
		}
	}
}
