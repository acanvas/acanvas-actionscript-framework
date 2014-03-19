package com.rockdot.project.view.layer {
	import com.jvm.utils.DeviceDetector;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.command.event.FBEvents;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.io.command.event.IOEvents;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.project.command.event.ProjectEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.button.YellowButton;
	import com.rockdot.project.view.text.Copy;

	import flash.display.DisplayObject;



	/**
	 * @author nilsdoehring
	 */
	public class PhotoImportOptions extends AbstractLayer implements IFBModelAware {
		private var _buttonDisk : YellowButton;
		private var _buttonFacebook : YellowButton;
		private var _buttonLogout : YellowButton;
		private var _buttonClose : YellowButton;
		private var _fbModel : FBModel;
		private var _copy : Copy;

		public function PhotoImportOptions(id : String) {
			super(id);
		}

		override public function init(data : * = null) : void {
			super.init(data);
			
			// copy
			_copy = new Copy(getProperty("copy"), 11, Colors.GREY);
			addChild(_copy);
						
			_buttonDisk = new YellowButton(getProperty("button.disk"));
			_buttonDisk.submitEvent = new RockdotEvent(IOEvents.IMAGE_LOAD_DISK, null, _onImageImported);
			addChild(_buttonDisk);

			_buttonFacebook = new YellowButton(getProperty("button.facebook"));
			_buttonFacebook.submitEvent = new RockdotEvent(ProjectEvents.APP_LOGIN_DISPATCH, {prompt:"facebook.albums", next:"/import/facebook/albums"});
			addChild(_buttonFacebook);
			if (RockdotConstants.LOCAL) {
				_buttonFacebook.enabled = false;
			}

			if (RockdotConstants.DEBUG || DeviceDetector.IS_AIR) {
				_buttonLogout = new YellowButton(getProperty("button.logout"));
				_buttonLogout.submitEvent = new RockdotEvent(FBEvents.USER_LOGOUT);
				addChild(_buttonLogout);
				if (_fbModel.userIsAuthenticated) {
					_buttonLogout.enabled = false;
				}
			}

			_buttonClose = new YellowButton(getProperty("button.back"));
			_buttonClose.submitEvent = new RockdotEvent(StateEvents.STATE_VO_BACK);
			addChild(_buttonClose);

			_didInit();
		}

		override public function render() : void {

			var w : Number = _width;
			
			//text
			_headline.x = BootstrapConstants.SPACER;
			_headline.y = _headlineY;
			_headline.width = w;
			
			_copy.x = BootstrapConstants.SPACER;
			_copy.y = _headlineY + _headline.textHeight + BootstrapConstants.SPACER;
			_copy.width = w - 2 * BootstrapConstants.SPACER;

//			_buttonDisk.x = ApplicationConstants.SPACER;
			_buttonDisk.y = 3*BootstrapConstants.SPACER + _copy.y + _copy.textHeight;
			_buttonDisk.setSize(w, BootstrapConstants.HEIGHT_RASTER);
			
//			_buttonFacebook.x = ApplicationConstants.SPACER;
			_buttonFacebook.y = _buttonDisk.y + _buttonDisk.height + BootstrapConstants.SPACER/2;
			_buttonFacebook.setSize(w, BootstrapConstants.HEIGHT_RASTER);
			
//			_buttonClose.x = ApplicationConstants.SPACER;
			_buttonClose.y = _buttonFacebook.y + _buttonFacebook.height + BootstrapConstants.SPACER/2;
			_buttonClose.setSize(w, BootstrapConstants.HEIGHT_RASTER);
			
			if (_buttonLogout) {
//				_buttonLogout.x = ApplicationConstants.SPACER;
				_buttonLogout.y = _buttonClose.y + _buttonClose.height + BootstrapConstants.SPACER/2;
				_buttonLogout.setSize(w, BootstrapConstants.HEIGHT_RASTER);
			}

			super.render();
		}

		private function _onImageImported(image : DisplayObject) : void {
			//image was saved here: _ioModel.importedFile
			new RockdotEvent(StateEvents.ADDRESS_SET, "/image/edit").dispatch();
		}

		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}
	}
}
