package com.rockdot.library.view.component.common.form.button {
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.events.MouseEvent;


	public class Button extends SpriteComponent {
		private var _label : String;

		public function Button() : void {
			super();
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			enabled = true;
			ignoreSetEnabled = true;
		}
		
		
		override public function set enabled(value : Boolean) : void {
			super.enabled = value;
			mouseChildren = false;
			if(value == true){
				addEventListener(MouseEvent.CLICK, _onClick, false, 0, true);
				addEventListener(MouseEvent.ROLL_OVER, _onRollOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, _onRollOut, false, 0, true);
				_onRollOut();
			}
			else{
				removeEventListener(MouseEvent.CLICK, _onClick);
				removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
				removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
				_onRollOver();
			}
		}
		
		public function setLabel(label : String):void{
			_label = label;
		}


		protected function _onClick(event : MouseEvent = null) : void {
			if(_submitCallback != null){
				_submitCallback.apply( this, _submitCallbackParams );
			}
			if(_submitEvent){
				_submitEvent.dispatch();
			}
		}
		
		protected function _onRollOver(event : MouseEvent = null) : void {
			// Override this method
		}


		protected function _onRollOut(event : MouseEvent = null) : void {
			// Override this method
		}
	}
}