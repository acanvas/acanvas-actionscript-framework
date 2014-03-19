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
	public class MyToggleFullscreenButton extends ToggleButton {

		private var _bg : Shape;
		private var _enterFullscreenIcon : Shape;
		private var _exitFullscreenIcon : Shape;

		public function MyToggleFullscreenButton() {
			super();
			mouseChildren = false;
			
			_bg = new Shape();
			_bg.graphics.beginFill(0x8d8d8d, 1);
			_bg.graphics.drawRect(0, 0, 20, 20);
			_bg.graphics.endFill();
			addChild(_bg);
			
			_enterFullscreenIcon = new Shape();
			_enterFullscreenIcon.graphics.beginFill(0xFFFFFF, 1);
			_enterFullscreenIcon.graphics.drawRect(0, 0, 4, 1);
			_enterFullscreenIcon.graphics.drawRect(0, 1, 1, 3);
			_enterFullscreenIcon.graphics.drawRect(6, 0, 4, 1);
			_enterFullscreenIcon.graphics.drawRect(9, 1, 1, 3);
			_enterFullscreenIcon.graphics.drawRect(0, 6, 1, 3);
			_enterFullscreenIcon.graphics.drawRect(0, 9, 4, 1);
			_enterFullscreenIcon.graphics.drawRect(9, 6, 1, 3);
			_enterFullscreenIcon.graphics.drawRect(6, 9, 4, 1);
			_enterFullscreenIcon.graphics.endFill();
			_enterFullscreenIcon.x = 5;
			_enterFullscreenIcon.y = 5;
			addChild(_enterFullscreenIcon);
			
			_exitFullscreenIcon = new Shape();
			_exitFullscreenIcon.graphics.beginFill(0xFFFFFF, .6);
			_exitFullscreenIcon.graphics.drawRect(0, 0, 4, 1);
			_exitFullscreenIcon.graphics.drawRect(0, 1, 1, 3);
			_exitFullscreenIcon.graphics.drawRect(6, 0, 4, 1);
			_exitFullscreenIcon.graphics.drawRect(9, 1, 1, 3);
			_exitFullscreenIcon.graphics.drawRect(0, 6, 1, 3);
			_exitFullscreenIcon.graphics.drawRect(0, 9, 4, 1);
			_exitFullscreenIcon.graphics.drawRect(9, 6, 1, 3);
			_exitFullscreenIcon.graphics.drawRect(6, 9, 4, 1);
			_exitFullscreenIcon.graphics.endFill();
			_exitFullscreenIcon.x = 5;
			_exitFullscreenIcon.y = 5;
			addChild(_exitFullscreenIcon);
			
			_exitFullscreenIcon.visible = false;
		}
		
		
		override protected function _onClick(event : MouseEvent) : void {
			super._onClick(event);
			
			if(!isToggled) {
				_enterFullscreenIcon.visible = true;
				_exitFullscreenIcon.visible = false;
			} else {
				_enterFullscreenIcon.visible = false;
				_exitFullscreenIcon.visible = true;
			}
		}

		public function changeState() : void {
			_onClick(null);
		}
		
	}
}
