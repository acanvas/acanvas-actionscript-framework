package com.rockdot.project.view.element.editor {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.library.view.component.common.form.ComponentDropdown;
	import com.rockdot.project.model.Colors;

	import flash.display.Shape;


	/**
	 * @author nilsdoehring
	 */
	public class IAMLogoEditorRollout extends ComponentDropdown {
		private static const ROLLOUT_WIDTH : Number = 260;
		
		private var _arrRolloutContent : Array;

		public function IAMLogoEditorRollout(id : String) {
			name = id;
			
			_blnMirrorButtonOnToggle = true;
			_btnRolloutToggle = new IAMLogoEditorRolloutButton();

			_shaRolloutMask = new Shape();
			addChild(_shaRolloutMask);
			
			super();

			_arrRolloutContent = [getProperty("option_1"), getProperty("option_2"), getProperty("option_3"), getProperty("option_4"), getProperty("option_5"), getProperty("option_6"), getProperty("option_7")];
			
			var btnRolloutElement : IAMLogoEditorRolloutContentButton;
			for (var i : int = 0;i < _arrRolloutContent.length;i++) {
				btnRolloutElement = new IAMLogoEditorRolloutContentButton(_arrRolloutContent[i], ROLLOUT_WIDTH, 30, i, _arrRolloutContent.length - 1);
				btnRolloutElement.submitCallbackParams = [i];
				btnRolloutElement.submitCallback = _onRolloutItemClicked;
				btnRolloutElement.y = i * btnRolloutElement.height;
				_sprRollout.addChild(btnRolloutElement);
			}

			var shaRolloutBorder : Shape = new Shape();
			shaRolloutBorder.graphics.lineStyle(2, Colors.YELLOW, 1, false, "none");
			shaRolloutBorder.graphics.drawRect(0, 0, ROLLOUT_WIDTH, _arrRolloutContent.length*btnRolloutElement.heightFix );
			_sprRollout.addChild(shaRolloutBorder);
		}
		
		override public function render() : void {
			super.render();
			
			_sprRollout.x = _btnRolloutToggle.x - _sprRollout.width;
			_sprRollout.y = -_sprRollout.height;

			_shaRolloutMask.graphics.clear();
			_shaRolloutMask.graphics.beginFill(Colors.BLACK);
			_shaRolloutMask.graphics.drawRect(_sprRollout.x - 10, _height - 2, _sprRollout.width + BootstrapConstants.HEIGHT_RASTER, _sprRollout.height+2);
			_shaRolloutMask.graphics.endFill();
			
			_btnRolloutToggle.setSize(BootstrapConstants.HEIGHT_RASTER, _height);
			_btnRolloutToggle.x = 0;
			_btnRolloutToggle.y = 0;
		}
		
		private function _onRolloutItemClicked(num : int) : void
		{
			if ( num == _arrRolloutContent.length - 1 ) {
				
				_submitCallback.call(null, num, "", true);
			} else {
				_submitCallback.call(null, num, getProperty("option_" + (num+1)),  false);
			}

			closeRollout();
		}
		
	}
}
