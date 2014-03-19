package com.rockdot.project.view.element.editor {
	import com.greensock.TweenLite;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Copy;

	import flash.display.Shape;
	import flash.events.MouseEvent;





	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class IAMLogoEditorRolloutContentButton extends Button {
		
		private var _bg : Shape;
		private var _tf : UITextField;
		private var _num : int;
		private var _max : int;
		private var _bgColor : Number;
		private var _bgAlpha : Number;

		
		public function IAMLogoEditorRolloutContentButton(text : String, w:int, h:int, num:int=0, max:int=0) {
			_width = w;
			_height = h;
			_num = num;
			_max = max;
		
			_bgAlpha = .2;
			(_num%2 == 0) ? _bgColor = Colors.BLACK : _bgColor = Colors.WHITE;
			if( _num == _max ) {
				_bgColor = Colors.BLACK;
				_bgAlpha = .6;
			}
			
			if( _num == _max ) {
				_tf = new Copy(text, 20, Colors.WHITE );
			} else {
				_tf = new Copy(text, 24, Colors.WHITE );
			}
			
			_tf.x = 6;
			_tf.y = 4;
			_tf.width = _width;
			_tf.wordWrap = false;
			_tf.multiline = false;
			_tf.mouseEnabled = false;
			addChild(_tf);

			_bg = new Shape();
			_bg.graphics.beginFill( _bgColor );
			_bg.graphics.drawRect(0, 0, _width, _height);
			_bg.graphics.endFill();
			_bg.alpha = _bgAlpha;
			addChildAt(_bg, 0);
			
			buttonMode = true;
			
			super( );
		}

		override protected function _onRollOver(event : MouseEvent = null) : void {
			TweenLite.killTweensOf(_bg);
			TweenLite.to(_bg, .1, {alpha:(_bgAlpha*2)});
			super._onRollOver(event);
		}

		override protected function _onRollOut(event : MouseEvent = null) : void {
			TweenLite.killTweensOf(_bg);
			TweenLite.to(_bg, .4, {alpha:_bgAlpha});
			super._onRollOut(event);
		}
		
		public function get heightFix() : Number {
			return _height;
		}

		
	}
}
