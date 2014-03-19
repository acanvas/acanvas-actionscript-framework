package com.rockdot.library.view.component.common.form {
	import com.greensock.TweenLite;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Shape;
	import flash.events.MouseEvent;

	public class ComponentDropdown extends RockdotSpriteComponent {
		public static const ROLLOUT_OPEN : String = "OPEN";
		public static const ROLLOUT_CLOSE : String = "CLOSE";
		
		protected var _sprRollout : SpriteComponent;
		protected var _shaRolloutMask : Shape;
		protected var _btnRolloutToggle : Button;
		protected var _cmpListFlyout : ComponentList;
		protected var _blnMirrorButtonOnToggle : Boolean = false;
		
		private var _strRolloutState : String;
		private var _onToggleCallback : Function;

		public function ComponentDropdown() {
			super();
			
			_sprRollout = new SpriteComponent();
			addChild(_sprRollout);
			
			if(_cmpListFlyout){
				_cmpListFlyout.submitCallback = _onCellSubmit;
				_sprRollout.addChild(_cmpListFlyout);
				_cmpListFlyout.render();
			}
			
			_shaRolloutMask = new Shape();
			addChild(_shaRolloutMask);
			
			_sprRollout.mask = _shaRolloutMask;
			_strRolloutState = ROLLOUT_CLOSE;

			_btnRolloutToggle.submitCallback = toggleRollout;
			addChild(_btnRolloutToggle);
		}
		
		public function setListSizeMax(w : int, h : int) : void {
			if(_cmpListFlyout){
				_cmpListFlyout.setSize(w, h);
			}
		}

		override public function render() : void {
			super.render();
			
			_btnRolloutToggle.setSize(_width, _height);
			
			_sprRollout.x = _btnRolloutToggle.x + _width - _sprRollout.width;
			_sprRollout.y = -_sprRollout.height;

			_shaRolloutMask.graphics.clear();
			_shaRolloutMask.graphics.beginFill(0xff0000);
			_shaRolloutMask.graphics.drawRect(_sprRollout.x - 10, _height, _sprRollout.width + 20, _sprRollout.height+2);
			_shaRolloutMask.graphics.endFill();
		}

		public function toggleRollout(event : MouseEvent = null) : void {
			if ( _strRolloutState == ROLLOUT_CLOSE) {
				openRollout();
			} else {
				closeRollout();
			}
		}

		public function openRollout(event : MouseEvent = null) : void {
			if ( _strRolloutState == ROLLOUT_CLOSE) {
				if(_blnMirrorButtonOnToggle){
					_btnRolloutToggle.scaleY = -1;
					_btnRolloutToggle.y = _height - 1;
				}

				_sprRollout.visible = true;
				_shaRolloutMask.visible = true;
				_strRolloutState = ROLLOUT_OPEN;
				TweenLite.to(_sprRollout, .5, {y:_height});
				if(_onToggleCallback != null){
					_onToggleCallback.call(null, _strRolloutState);
				}
			}
		}

		public function closeRollout(event : MouseEvent = null) : void {
			if ( _strRolloutState == ROLLOUT_OPEN) {
				if(_blnMirrorButtonOnToggle){
					_btnRolloutToggle.scaleY = 1;
					_btnRolloutToggle.y = -1;
				}
				_strRolloutState = ROLLOUT_CLOSE;
				TweenLite.to(_sprRollout, 0, {y:-_sprRollout.height, onComplete:_onCloseRolloutComplete});
			}
		}

		private function _onCloseRolloutComplete() : void {
			_sprRollout.visible = false;
			_shaRolloutMask.visible = false;
			if(_onToggleCallback != null){
				_onToggleCallback.call(null, _strRolloutState);
			}
		}

		protected function _onCellSubmit(cell : Cell) : void {

			_btnRolloutToggle.setLabel(String(cell.data));

			if (_submitCallback != null) {
				_submitCallback.call(null, cell);
			}
			
			closeRollout();
		}

		public function set onToggleCallback(onToggleCallback : Function) : void {
			_onToggleCallback = onToggleCallback;
		}
	}
}
