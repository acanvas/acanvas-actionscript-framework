package com.rockdot.project.view.layer {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.plugin.facebook.command.event.FBEvents;
	import com.rockdot.plugin.facebook.command.event.vo.VOFBShare;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.button.YellowButton;
	import com.rockdot.project.view.text.Copy;

	/**
	 * @author nilsdoehring
	 */
	public class SubmitSuccess extends AbstractLayer {
		private var _copy : UITextField;
		private var _buttonShare : YellowButton;
		private var _buttonOK : YellowButton;

		
		public function SubmitSuccess(id : String) {
			super(id);
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);
			
			_copy = new Copy(getProperty("copy"), 22, Colors.BLACK);
			addChild(_copy);

			_buttonShare = new YellowButton(getProperty("button.share"));
			_buttonShare.submitEvent = new RockdotEvent(FBEvents.PROMPT_SHARE, new VOFBShare(getProperty("share.title"), getProperty("share.message"), getProperty("project.facebook.share.image", true), getProperty("share.link"), getProperty("share.actiontext")));
			addChild(_buttonShare);
			
			
			_buttonOK = new YellowButton(getProperty("button.ok"));
			_buttonOK.submitEvent = new RockdotEvent(StateEvents.ADDRESS_SET, "/");
			addChild(_buttonOK);
			
			_didInit();
		}
		
		
		override public function render() : void {
			
			//text
			_headline.x = BootstrapConstants.SPACER;
			_headline.y = _headlineY;
			_headline.width = _width - 2*BootstrapConstants.SPACER;
			
			_copy.x = BootstrapConstants.SPACER;
			_copy.y = _headlineY + _headline.textHeight + BootstrapConstants.SPACER;
			_copy.width = _width - 2 * BootstrapConstants.SPACER;

			_buttonShare.x = BootstrapConstants.SPACER;
			_buttonShare.y = _copy.y + _copy.textHeight + BootstrapConstants.SPACER;
			_buttonShare.setWidth( _width - 2 * BootstrapConstants.SPACER);

//			_buttonOK.x = ApplicationConstants.SPACER;
			_buttonOK.y = _buttonShare.y + _buttonShare.height + BootstrapConstants.SPACER;
			_buttonOK.setWidth( _width);
			
			super.render();
		}



	}
}
