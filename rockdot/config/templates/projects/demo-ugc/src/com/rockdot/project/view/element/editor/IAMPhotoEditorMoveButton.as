package com.rockdot.project.view.element.editor {
	import com.greensock.TweenLite;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.project.model.Assets;
	import com.rockdot.project.model.Colors;

	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;





	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class IAMPhotoEditorMoveButton extends Button {
		
		private var _bg : Shape;
		private var _arrow : Bitmap;

		
		public function IAMPhotoEditorMoveButton( ) {
			
			_bg = new Shape();
			_bg.graphics.beginFill(Colors.BLACK);
			_bg.graphics.drawRoundRect(0, 0, BootstrapConstants.HEIGHT_RASTER, BootstrapConstants.HEIGHT_RASTER, 4, 4);
			_bg.graphics.endFill();
			_bg.x = - _bg.width/2;
			_bg.y = - _bg.height/2;
			_bg.alpha = 0.5;
			addChild(_bg);
			
			_arrow = Assets.picture_editor_arrow;
			_arrow.x = - Math.floor( _arrow.width/2 );
			_arrow.y = - Math.floor( _arrow.height/2 );
			addChild(_arrow);
			
			buttonMode = true;
			
			super();
		}

		

		override protected function _onRollOver(event : MouseEvent=null) : void {
			TweenLite.killTweensOf(_bg);
			TweenLite.to(_bg, .1, {alpha:1});
			super._onRollOver(event);
		}

		override protected function _onRollOut(event : MouseEvent=null) : void {
			TweenLite.killTweensOf(_bg);
			TweenLite.to(_bg, .4, {alpha:.5});
			super._onRollOut(event);
		}

		
	}
}
