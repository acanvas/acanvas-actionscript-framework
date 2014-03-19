package com.rockdot.project.view.element.editor {
	import com.greensock.TweenLite;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.project.model.Colors;

	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;




	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class IAMLogoEditorDragButton extends Button {

		private var _arrow : Shape;
		private var _dragging : Boolean;

		
		public function IAMLogoEditorDragButton() {
		
			this.graphics.beginFill(Colors.BLACK, 0);
			this.graphics.drawRect(0, 0, 50, 50);
			
			_arrow = new Shape();
			_arrow.graphics.beginFill(Colors.YELLOW);
			_arrow.graphics.moveTo(0, 0);
			_arrow.graphics.lineTo(13, 11);
			_arrow.graphics.lineTo(26, 0);
			_arrow.graphics.lineTo(0, 0);
			
			_arrow.filters = [new DropShadowFilter(0, 45, Colors.BLACK, .8, 8, 8)];
			
			_arrow.x = ( this.width - _arrow.width ) / 2;
//			_arrow.y = ( this.height - _arrow.height ) / 2;
			_arrow.y =  10;
			
			addChild(_arrow);
			
			buttonMode = true;
			
			super( );
		}

		override protected function _onRollOver(event : MouseEvent = null) : void {
			TweenLite.killTweensOf(_arrow);
			TweenLite.to(_arrow, .1, {tint:Colors.GREY_LIGHT});
			super._onRollOver(event);
		}

		override protected function _onRollOut(event : MouseEvent = null) : void {
			if( !_dragging ) {
				TweenLite.killTweensOf(_arrow);
				TweenLite.to(_arrow, .4, {removeTint:true});
				super._onRollOut(event);
			}
		}

		public function doOver() : void {
			TweenLite.killTweensOf(_arrow);
			TweenLite.to(_arrow, .1, {tint:Colors.GREY_LIGHT});
		}

		public function doOut() : void {
			TweenLite.killTweensOf(_arrow);
			TweenLite.to(_arrow, 0, {removeTint:true});
		}

		public function set dragging( drag : Boolean ) : void {
			_dragging = drag;
		}
	}
}
