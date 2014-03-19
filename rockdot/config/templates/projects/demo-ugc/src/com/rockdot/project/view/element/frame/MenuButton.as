package com.rockdot.project.view.element.frame {
	import com.greensock.TweenLite;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Headline;

	import flash.display.Shape;
	import flash.events.MouseEvent;

	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class MenuButton extends Button {
		private var _label : String;
		private var _bg : Shape;

		
		private var _fontSize : int;

		public function MenuButton(label : String, fontSize : int = 18) {
			_fontSize = fontSize;
			_label = label;
			initialize();
			super();
		}

		private function initialize() : void {
			
			var tf : Headline = new Headline(_label, _fontSize, Colors.BLACK);
			tf.x = 3;
			
			tf.wordWrap = false;
			tf.multiline = false;
			tf.mouseEnabled = false;
			addChild(tf);
			
			_bg = new Shape();
			_bg.graphics.beginFill(Colors.WHITE, 1);
			_bg.graphics.drawRect(0, 0, Math.ceil(tf.x + tf.width) + 8, BootstrapConstants.HEIGHT_RASTER);
			_bg.graphics.endFill();
			_bg.alpha = 0;
			addChildAt(_bg, 0);
			
			tf.y = Math.floor(_bg.height/2 - tf.textHeight/2);
			tf.width = tf.textWidth +3;
			
			buttonMode = true;
			
		}

		override protected function _onRollOver(event : MouseEvent = null) : void {
			TweenLite.killTweensOf(_bg);
			TweenLite.to(_bg, .2, {alpha:1});
			super._onRollOver(event);
		}

		override protected function _onRollOut(event : MouseEvent = null) : void {
			TweenLite.killTweensOf(_bg);
			TweenLite.to(_bg, .4, {alpha:0});
			super._onRollOut(event);
		}

		
	}
}
