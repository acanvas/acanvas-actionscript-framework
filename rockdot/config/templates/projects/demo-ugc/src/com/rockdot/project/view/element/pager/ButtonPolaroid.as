package com.rockdot.project.view.element.pager {
	import com.rockdot.library.view.component.common.ComponentImageLoader;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.plugin.ugc.model.vo.UGCImageItemVO;
	import com.rockdot.project.model.Colors;

	import flash.display.Shape;

	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class ButtonPolaroid extends Button {
		public var xPos : int;
		public var yPos : int;
		public var rot : int;
		private var _bg : Shape;
		private var _image : ComponentImageLoader;
		private var _vo : UGCImageItemVO;

		public function get vo() : UGCImageItemVO {
			return _vo;
		}

		public function ButtonPolaroid(dao : UGCImageItemVO = null, w : int = 0, h : int = 0) {
			// TODO implement setSize/render

			_bg = new Shape();
			addChild(_bg);

			if (dao) {
				_vo = dao;
				_image = new ComponentImageLoader(_vo.url_big, w - 6, h - 6);
				addChild(_image);
			}

			super();

			// setSize(_image.width, _image.height);
		}

		override public function render() : void {
			_image.scaleX = 2 / 3;
			_image.scaleY = 2 / 3;
			_image.x = -_image.width / 2;
			_image.y = -_image.height / 2;
			// _image.setSize(_width-6, _height-6);

			_bg.graphics.clear();
			_bg.graphics.beginFill(Colors.WHITE);
			_bg.graphics.drawRect(0, 0, _image.width + 14, _image.height + 14);
			_bg.graphics.endFill();

			super.render();
		}
	}
}
