package com.rockdot.project.view.element.pointlight {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author nilsdoehring
	 */
	/**
	 * Copyright k3lab ( http://wonderfl.net/user/k3lab )
	 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
	 * Downloaded from: http://wonderfl.net/c/ptmi
	 */
	public class Grid extends Sprite {
		private var lines : Sprite;
		private  var Arrays : Array;
		private  var SQ : Array;
		private var Reaction : uint = 175;
		private var spring : Number = 0.3;
		private var friction : Number = 0.68;
		private var _x : int;
		private var _y : int;

		public function Grid() : void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Arrays = [];
			SQ = [];
			for (var i : int = 0; i < 6; i++ ) {
				for (var j : int = 0; j < 6; j++ ) {
					var _point : Points = new Points(95 * i, 95 * j);
					Arrays.push(_point);
					var test : Sprite = addChild(new Sprite()) as Sprite;
					test.graphics.beginFill(0x101010);
					test.graphics.drawCircle(0, 0, 20);
					test.graphics.endFill();
					SQ.push(test);
				}
			}
			lines = addChild(new Sprite()) as Sprite;
			addEventListener(Event.ENTER_FRAME, enter);
		}

		private function enter(e : Event) : void {
			var mousePoint : Point;
			if(_x && _y){
				mousePoint = new Point(_x, _y);
			}
			else{
				mousePoint = new Point(mouseX, mouseY);
			}
			var i : int;
			for each (var _point:Points in Arrays) {
				_point.update(mousePoint, Reaction, spring, friction);
				SQ[i].x = _point.x;
				SQ[i].y = _point.y;
				i++;
			}
			lines.graphics.clear();
			lines.graphics.lineStyle(20, 0x101010, 1);
			for (var n : int = 0; n < 36; n++ ) {
				lines.graphics.beginFill(0x000000, Math.min(1, distance / 350));
				lines.graphics.moveTo(SQ[n].x, SQ[n].y);
				var distance : Number = Point.distance(mousePoint, new Point(SQ[n].x + 47, SQ[n].y + 47));
				if (n < 30) {
					lines.graphics.lineTo(SQ[(n + 6)].x, SQ[n + 6].y);
					if (n % 6) {
						lines.graphics.lineTo(SQ[(n + 5 )].x, SQ[n + 5].y);
						lines.graphics.lineTo(SQ[(n - 1 )].x, SQ[n - 1].y);
					}
					if (n == 2 || n == 1) {
						lines.graphics.lineTo(SQ[(n - 1)].x, SQ[n - 1].y);
						lines.graphics.lineTo(SQ[n].x, SQ[n].y);
					}
				}
			}
			lines.graphics.endFill();
		}

		public function setCursor(x : int, y : int) : void {
			_y = y;
			_x = x;
		}
	}
}
