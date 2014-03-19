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
	public class MyTogglePauseButton extends ToggleButton {

		private var _play : Shape;
		private var _pause : Shape;
		private var _bg : Shape;

		public function MyTogglePauseButton() {
			super();
			mouseChildren = false;
			
			_bg = new Shape();
			_bg.graphics.beginFill(0x8d8d8d, 1);
			_bg.graphics.drawRect(0, 0, 20, 20);
			_bg.graphics.endFill();
			addChild(_bg);
			
			_play = new Shape();
			_play.graphics.beginFill(0xFFFFFF, 1);
			_play.graphics.lineTo(0, 8);
			_play.graphics.lineTo(6, 4);
			_play.graphics.lineTo(0, 0);
			_play.graphics.endFill();
			_play.x = _bg.width*.5 - _play.width*.5;
			_play.y = _bg.height*.5 - _play.height*.5;
			addChild(_play);
			
			_pause = new Shape();
			_pause.graphics.beginFill(0xFFFFFF, 1);
			_pause.graphics.drawRect(0, 0, 2, 8);
			_pause.graphics.drawRect(4, 0, 2, 8);
			_pause.graphics.endFill();
			_pause.x = _bg.width*.5 - _pause.width*.5;
			_pause.y = _bg.height*.5 - _pause.height*.5;
			addChild(_pause);
			_pause.visible = false;
		}
		
		
		override protected function _onClick(event : MouseEvent) : void {
			super._onClick(event);
			
			if(isToggled) {
				_play.visible = true;
				_pause.visible = false;
			} else {
				_play.visible = false;
				_pause.visible = true;
			}
		}

		public function changeState() : void {
			_onClick(null);
		}
		
	}
}
