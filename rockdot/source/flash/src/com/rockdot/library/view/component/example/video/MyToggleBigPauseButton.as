package com.rockdot.library.view.component.example.video {
	import com.rockdot.library.view.component.common.form.button.ToggleButton;

	import flash.display.Shape;


	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 10.06.2011 18:07:07
	 */
	public class MyToggleBigPauseButton extends ToggleButton {

		private var _play : Shape;
		private var _pause : Shape;
		private var _bg : Shape;

		public function MyToggleBigPauseButton() {
			super();
			mouseChildren = false;
			mouseEnabled = false;
			buttonMode = false;
			
			_bg = new Shape();
			_bg.graphics.beginFill(0x5faf1f, 1);
			_bg.graphics.drawRoundRect(0, 0, 50, 50, 4);
			_bg.graphics.endFill();
			addChild(_bg);
			
			_play = new Shape();
			_play.graphics.beginFill(0xFFFFFF, 1);
			_play.graphics.lineTo(0, 20);
			_play.graphics.lineTo(15, 10);
			_play.graphics.lineTo(0, 0);
			_play.graphics.endFill();
			_play.x =  Math.floor( _bg.width*.5 - _play.width*.5 );
			_play.y =  Math.floor( _bg.height*.5 - _play.height*.5 );
			addChild(_play);
			
			_pause = new Shape();
			_pause.graphics.beginFill(0xFFFFFF, 1);
			_pause.graphics.drawRect(0, 0, 5, 20);
			_pause.graphics.drawRect(8, 0, 5, 20);
			_pause.graphics.endFill();
			_pause.x = Math.floor( _bg.width*.5 - _pause.width*.5 );
			_pause.y = Math.floor( _bg.height*.5 - _pause.height*.5 );
			addChild(_pause);
			_pause.visible = false;
			
		}
		
		public function changeState() : void {
			if(isToggled) {
				_play.visible = true;
				_pause.visible = false;
			} else {
				_play.visible = false;
				_pause.visible = true;
			}
		}
		
	}
}
