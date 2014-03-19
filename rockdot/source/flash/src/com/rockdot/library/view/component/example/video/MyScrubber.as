package com.rockdot.library.view.component.example.video {
	import com.rockdot.library.view.component.common.scrollable.Slider;
	import com.jvm.components.Orientation;

	import flash.display.Sprite;

	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 09.06.2011 17:06:46
	 */
	public class MyScrubber extends Slider {

		public function MyScrubber(w : Number) {
			super(Orientation.HORIZONTAL, 0, 1, w, true);
			
//			_thumb = new Sprite();
//			_thumb.graphics.beginFill(0x62b221, 1);
//			_thumb.graphics.drawRect(0, 0, 10, 11);
//			_thumb.graphics.endFill();
//			addChild(_thumb);

			_background = new Sprite();
			_background.graphics.beginFill(0xf0efef, 0);
			_background.graphics.drawRect(0, 0, w, 20);
			_background.graphics.endFill();
			addChildAt(_background, 0);
		}

		override public function set size(value : Number) : void {
			super.size = value;
			_background.graphics.clear();
			_background.graphics.beginFill(0xf0efef, 0);
			_background.graphics.drawRect(0, 0, value, 20);
			_background.graphics.endFill();
		}
		
	}
}
