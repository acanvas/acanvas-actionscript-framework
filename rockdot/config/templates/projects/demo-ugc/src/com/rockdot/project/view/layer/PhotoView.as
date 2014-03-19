package com.rockdot.project.view.layer {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.component.common.ComponentImageLoader;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.ugc.model.vo.UGCImageItemVO;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.button.YellowButton;
	import com.rockdot.project.view.text.Copy;



	/**
	 * @author nilsdoehring
	 */
	public class PhotoView extends AbstractLayer {
		private var _buttonClose : YellowButton;
		private var _copy : Copy;
		private var _pic : ComponentImageLoader;

		public function PhotoView(id : String) {
			super(id);
		}

		override public function init(data : * = null) : void {
			super.init(data);
			
			_headline.htmlText = getProperty("headline").toLocaleUpperCase() + " TODO";// + _appModel.currentUGCItem.creator.name;
			
			// copy
			_copy = new Copy(getProperty("copy").toLocaleUpperCase() + " TODO", 18, Colors.GREY_MIDDLE);// + _appModel.currentUGCItem.timestamp, 11, Colors.GREY);
			addChild(_copy);
						
			_pic = new ComponentImageLoader((_appModel.currentUGCItem.type_dao as UGCImageItemVO).url_big, LAYER_WIDTH_MAX, LAYER_WIDTH_MAX);
			addChild(_pic);

			_buttonClose = new YellowButton(getProperty("button.back"));
			_buttonClose.submitEvent = new RockdotEvent(StateEvents.STATE_VO_BACK);
			addChild(_buttonClose);

			_didInit();
		}

		override public function render() : void {

			var w : Number = _width - 2 * BootstrapConstants.SPACER;
			
			_kamera.visible = false;
			_headlineY = 60;
			
			//text
			_headline.x = BootstrapConstants.SPACER;
			_headline.y = _headlineY;
			_headline.width = w;
			
			_copy.x = BootstrapConstants.SPACER;
			_copy.y = _headlineY + _headline.textHeight + BootstrapConstants.SPACER;
			_copy.width = w;
			
			_pic.y = _copy.y + _copy.textHeight + BootstrapConstants.SPACER;

			_buttonClose.y = _pic.y + _pic.height;
			_buttonClose.setSize(_width, BootstrapConstants.HEIGHT_RASTER);

			super.render();

			_pic.x = -_pic.width/2;
		}

	}
}
