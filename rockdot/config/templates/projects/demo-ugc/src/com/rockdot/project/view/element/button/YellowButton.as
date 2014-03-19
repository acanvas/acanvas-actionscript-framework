package com.rockdot.project.view.element.button {
	import com.greensock.TweenLite;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Headline;

	import flash.display.Shape;
	import flash.events.MouseEvent;

	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class YellowButton extends Button {
		private static const LABEL_MAX_WIDTH : Number = 400;
		private var _bg : Shape;
		private var _label : UITextField;
		private var _color : uint;

		public function YellowButton(text : String, w : Number = 0, h : Number = BootstrapConstants.HEIGHT_RASTER, size : uint = 24, color : uint = Colors.YELLOW) {
			_color = color;

			_label = new Headline(String(text).toLocaleUpperCase(), size, Colors.BLACK);
			_label.width = LABEL_MAX_WIDTH;
//			_label.filters = [new GlowFilter(Colors.GREY_DARK, .5, 6, 6, .5)];
			addChild(_label);
			
			_bg = new Shape();
//			_bg.filters = [new GlowFilter(Colors.BLACK, .5, 6, 6, 1)];
			addChildAt(_bg, 0);

			super();
			setSize(w, h);
			enabled = true;
		}
		
		
		override public function render() : void {

			if (_width > 30) {
				_label.x = Math.round(_width / 2 - _label.textWidth / 2) - 3;
			} else {
				_width = _label.textWidth +  4*BootstrapConstants.SPACER;
				_label.x = Math.round(_width / 2 - _label.textWidth / 2) - 3;
//				_label.x =  BootstrapConstants.SPACER;
			}
			
			_label.width = _width - BootstrapConstants.SPACER;
			_label.y = Math.round(_height / 2 - _label.textHeight / 2);
			
			_bg.graphics.clear();
			_bg.graphics.beginFill(_color);
			_bg.graphics.drawRect(0, 0,_width, _height);
			_bg.graphics.endFill();
			
			super.render();
		}
		
		override public function setLabel(label : String):void{
			super.setLabel(label);
			_label.htmlText = label;
			render();
		}
		
		override protected function _onRollOver(event : MouseEvent = null) : void {
			TweenLite.to(_bg, 0.1, {colorMatrixFilter:{brightness:0.7}});
		}

		override protected function _onRollOut(event : MouseEvent = null) : void {
			TweenLite.to(_bg, 0.3, {colorMatrixFilter:{brightness:1.0}});
		}
	}
}
