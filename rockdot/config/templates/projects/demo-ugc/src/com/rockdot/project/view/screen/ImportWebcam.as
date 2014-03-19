package com.rockdot.project.view.screen {
	import com.jvm.utils.BitmapUtils;
	import com.jvm.utils.DeviceDetector;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.component.common.ComponentCamera;
	import com.rockdot.library.view.component.common.ComponentCameraUI;
	import com.rockdot.plugin.io.inject.IIOModelAware;
	import com.rockdot.plugin.io.model.IOModel;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.project.view.element.button.YellowButton;


	/**
	 * @author nilsdoehring
	 */
	public class ImportWebcam extends AbstractScreen implements IIOModelAware{
		private var _cam : SpriteComponent;
		private var _button : YellowButton;

		private var _ioModel : IOModel;
		public function set ioModel(ioModel : IOModel) : void {
			_ioModel = ioModel;
		}

		public function ImportWebcam(id : String) {
			super(id);
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);
			
			if(DeviceDetector.IS_MOBILE){
				_cam = new ComponentCameraUI(512, 128, 20);
				_cam.submitCallback = _onSnapShot;
			}
			else{
				_cam = new ComponentCamera(512, 128, 20);
			}
			addChild(_cam);

			_button = new YellowButton(getProperty("button.snapshot"), _width - 2*BootstrapConstants.SPACER);
			_button.submitCallback = _onSnapShot;
			_button.x = BootstrapConstants.SPACER;
			addChild(_button);
			
			_didInit();
		}
		
		
		override public function render() : void {
			_button.setWidth(_width - 2*BootstrapConstants.SPACER);
			_button.y =( _height - BootstrapConstants.HEIGHT_RASTER ) - BootstrapConstants.SPACER;

			_cam.setSize(_width, _button.y);
			
			super.render();
		}

		private function _onSnapShot() : void {
			_ioModel.importedFile = BitmapUtils.getBitmapFromDisplayObject(_cam);
			new RockdotEvent(StateEvents.ADDRESS_SET, "/image/edit").dispatch();
		}


	}
}
