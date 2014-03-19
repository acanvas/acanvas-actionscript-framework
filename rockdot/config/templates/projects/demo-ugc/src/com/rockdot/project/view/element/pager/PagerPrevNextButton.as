package com.rockdot.project.view.element.pager {
	import com.greensock.TweenLite;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.project.model.Assets;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Headline;

	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;

	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class PagerPrevNextButton extends Button {
		private var _bg : Shape;
		private var _label : UITextField;
		private var _color : uint;
		private var _arrow : Bitmap;

		public function PagerPrevNextButton(text : String, w : Number = 0, h : Number = BootstrapConstants.HEIGHT_RASTER, size : uint = 24, color : uint = Colors.YELLOW) {
			_color = color;

			_label = new Headline(String(text), size, Colors.BLACK);
//			addChild(_label);
			
			_bg = new Shape();
			addChildAt(_bg, 0);
			
			_arrow = Assets.picture_editor_arrow;
			addChild(_arrow);

			super();
			setSize(w, h);
			enabled = true;
		}
		
		
		override public function render() : void {
			_label.width = _width - 2*BootstrapConstants.SPACER;
			_label.x = Math.round(_width / 2 - _label.textWidth / 2) - 3;
			_label.y = Math.round(_height / 2 - _label.textHeight / 2) - 3;
			
			_bg.graphics.clear();
			_bg.graphics.beginFill(_color);
			_bg.graphics.drawRect(0, 0,_width, _height);
			_bg.graphics.endFill();
			
//			_arrow.rotation = 90;
			_arrow.x = Math.floor(( _width - _arrow.width)/2) ;
			_arrow.y = Math.floor((_height - _arrow.height)/2);
			
			
			super.render();
		}
		
		override protected function _onRollOver(event : MouseEvent = null) : void {
			TweenLite.to(_bg, 0.1, {colorMatrixFilter:{brightness:0.8}});
		}

		override protected function _onRollOut(event : MouseEvent = null) : void {
			TweenLite.to(_bg, 0.3, {colorMatrixFilter:{brightness:1.0}});
		}
	}
}
