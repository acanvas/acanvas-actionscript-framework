package com.rockdot.project.view.element.editor {
	import com.greensock.TweenLite;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.project.model.Colors;

	import flash.display.Shape;
	import flash.events.MouseEvent;





	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class IAMPhotoEditorScaleButton extends Button {

		private var _bg : Shape;
		private var _graphic1 : Shape;
		private var _graphic2 : Shape;

		
		public function IAMPhotoEditorScaleButton(data : String) : void {
				
			_bg = new Shape();
			_bg.graphics.beginFill(Colors.WHITE);
			_bg.graphics.drawRoundRect(0, 0, BootstrapConstants.HEIGHT_RASTER - 2*BootstrapConstants.SPACER, BootstrapConstants.HEIGHT_RASTER - 2*BootstrapConstants.SPACER, 4, 4);
			_bg.graphics.endFill();
			addChild(_bg);
			
			_graphic1 = new Shape();
			_graphic1.graphics.beginFill(Colors.GREY_DARK);
			_graphic1.graphics.drawRect(BootstrapConstants.SPACER, _bg.height/2 - 1, _bg.height - 2*BootstrapConstants.SPACER, 2);
			addChild(_graphic1);
			
			if( data == "plus" ) {
				_graphic2 = new Shape();
				_graphic2.graphics.beginFill(Colors.BLACK);
				_graphic2.graphics.drawRect(_bg.width/2 - 1, BootstrapConstants.SPACER,  2, _bg.width - 2*BootstrapConstants.SPACER);
				addChild(_graphic2);
			}
			
			buttonMode = true;
			
			super();
		}

		override protected function _onRollOver(event : MouseEvent=null) : void {
			TweenLite.killTweensOf(_bg);
			TweenLite.to(_bg, .1, {tint:Colors.GREY_LIGHT});
			super._onRollOver(event);
		}

		override protected function _onRollOut(event : MouseEvent=null) : void {
			TweenLite.killTweensOf(_bg);
			TweenLite.to(_bg, .4, {removeTint:true});
			super._onRollOut(event);
		}
	}
}
