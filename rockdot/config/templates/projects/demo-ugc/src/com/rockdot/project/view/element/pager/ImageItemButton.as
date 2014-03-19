package com.rockdot.project.view.element.pager {
	import com.greensock.TweenLite;
	import com.rockdot.library.view.component.common.ComponentImageLoader;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.project.model.Colors;

	import flash.display.Shape;
	import flash.events.MouseEvent;



	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author 	Nils Doehring (nilsdoehring(at)gmail.com)
	 * @since	29.04.2011
	 */
	public class ImageItemButton extends Button {
		private var _bg : Shape;
		private var _image : ComponentImageLoader;
		public function ImageItemButton(href : String, w : int, h : int)
		{
			
			_bg = new Shape();
			addChild(_bg);

			_image = new ComponentImageLoader(href, w-6, h-6);
			addChild(_image);

			super();
			
			setSize(w, h);
		}
		
		
		override public function render() : void {
			_image.x = 3;
			_image.y = 3;
			_image.setSize(_width-6, _height-6);

			_bg.graphics.clear();
			_bg.graphics.beginFill(Colors.GREY);
			_bg.graphics.drawRect(0, 0, _width, _height);
			_bg.graphics.endFill();
			
			super.render();
		}

		override protected function _onRollOver(event : MouseEvent = null) : void
		{
			TweenLite.to(_bg, 0.3, {tint:Colors.HIGHLIGHT});
		}

		override protected function _onRollOut(event : MouseEvent = null) : void
		{
			TweenLite.to(_bg, 0.3, {tint:Colors.GREY});
		}
	}
}
