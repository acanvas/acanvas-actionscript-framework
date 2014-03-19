package com.jvm.components.effects.snow {
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.events.Event;


	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class SnowEffect extends SpriteComponent {
		private var offsetX : int;		private var offsetY : int;

		public function SnowEffect(w : int, h : int, snowflakeSize : uint = 30, numSnowflakes : uint = 50, speed : Number = 10) {
			mouseEnabled = false;
			mouseChildren = false;
			
			_width = w;
			_height = h;
			
			offsetX = -snowflakeSize;
			offsetY = -snowflakeSize;
			
			// Create Snowflakes
			var snowflake : Snowflake;
			for (var i : int = 0;i < numSnowflakes;i++) {
				snowflake = new Snowflake(snowflakeSize);
				_placeSnowflake(snowflake);
				snowflake.y = Math.random() * _height + offsetY;
				
				snowflake.speed = speed * (0.5 + Math.random());
			
				snowflake.scaleX = snowflake.scaleY = (snowflake.speed / speed);
				snowflake.alpha = 0.4 + 0.6 * Math.random();
				addChild(snowflake);
			}
			
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);		}

		
		private function _onEnterFrame(event : Event) : void {
			// Update snowflakes
			var snowflake : Snowflake;
			for (var i : int = 0;i < numChildren;i++) {
				snowflake = Snowflake(getChildAt(i));
				
				snowflake.angle += (snowflake.speed / 180) * Math.PI;
				snowflake.x -= Math.sin(snowflake.angle);
				snowflake.y += snowflake.speed;
				
				if (snowflake.y > _height) {
					_placeSnowflake(snowflake);
				}
				
				if ((snowflake.x > _width) || (snowflake.x < -snowflake.width)) {
					_placeSnowflake(snowflake);				
				}
			}
		}

		
		private function _placeSnowflake(snowflake : Snowflake) : void {
			snowflake.x = Math.round(Math.random() * (_width - offsetX) + offsetX * 0.5);
			snowflake.y = offsetY;
		}
	}
}
