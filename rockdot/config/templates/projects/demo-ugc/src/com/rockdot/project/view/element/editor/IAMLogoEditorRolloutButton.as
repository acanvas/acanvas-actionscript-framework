package com.rockdot.project.view.element.editor {
	import com.greensock.TweenLite;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.project.model.Colors;

	import flash.display.Shape;
	import flash.events.MouseEvent;

	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class IAMLogoEditorRolloutButton extends Button {
		private var _shaArrow : Shape;

		public function IAMLogoEditorRolloutButton(w : Number = 0, h : Number = BootstrapConstants.HEIGHT_RASTER) {
			
			_shaArrow = new Shape();
			_shaArrow.graphics.lineStyle(2, Colors.WHITE);
			_shaArrow.graphics.moveTo(0, 0);
			_shaArrow.graphics.lineTo(6, 8);
			_shaArrow.graphics.lineTo(12, 0);
			addChild(_shaArrow);
			

			super();
			setSize(w, h);
			enabled = true;
		}
		
		
		override public function render() : void {
			super.render();
			
			graphics.beginFill(Colors.BLACK, 0.7);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			_shaArrow.x = (_width - _shaArrow.width) / 2;
			_shaArrow.y = (_height - _shaArrow.height) / 2;
		}
		
		override protected function _onRollOver(event : MouseEvent = null) : void {
			TweenLite.to(this, 0.1, {colorMatrixFilter:{brightness:0.7}});
		}

		override protected function _onRollOut(event : MouseEvent = null) : void {
			TweenLite.to(this, 0.3, {colorMatrixFilter:{brightness:1.0}});
		}
	}
}
