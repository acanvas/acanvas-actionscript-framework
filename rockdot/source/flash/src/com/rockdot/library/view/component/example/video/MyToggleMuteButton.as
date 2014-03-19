package com.rockdot.library.view.component.example.video {
	import com.rockdot.library.view.component.common.form.button.ToggleButton;

	import flash.display.Shape;
	import flash.events.MouseEvent;


	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 10.06.2011 18:07:07
	 */
	public class MyToggleMuteButton extends ToggleButton {

		private var _off : Shape;
		private var _bg : Shape;
		private var _on : Shape;

		public function MyToggleMuteButton() {
			super();
			mouseChildren = false;
			
			_bg = new Shape();
			_bg.graphics.beginFill(0x8d8d8d, 1);
			_bg.graphics.drawRect(0, 0, 20, 20);
			_bg.graphics.endFill();
			addChild(_bg);
			
			_on = new Shape();
			_on.graphics.beginFill(0xFFFFFF, 1);
			_on.graphics.drawRect(0, 3, 1, 4);
			_on.graphics.drawRect(2, 2, 1, 6);
			_on.graphics.drawRect(4, 1, 1, 8);
			_on.graphics.drawRect(6, 0, 1, 10);
			_on.graphics.endFill();
			_on.x = 5;
			_on.y = 5;
			addChild(_on);
			
			_off = new Shape();
			_off.graphics.beginFill(0xFFFFFF, .6);
			_off.graphics.drawRect(0, 3, 1, 4);
			_off.graphics.drawRect(2, 2, 1, 6);
			_off.graphics.drawRect(4, 1, 1, 8);
			_off.graphics.drawRect(6, 0, 1, 10);
			_off.graphics.endFill();
			_off.x = 5;
			_off.y = 5;
			addChild(_off);
			_off.visible = false;
		}
		
		
		override protected function _onClick(event : MouseEvent) : void {
			super._onClick(event);
			
			if(!isToggled) {
				_on.visible = true;
				_off.visible = false;
			} else {
				_on.visible = false;
				_off.visible = true;
			}
		}

		public function changeState() : void {
			_onClick(null);
		}
		
	}
}
