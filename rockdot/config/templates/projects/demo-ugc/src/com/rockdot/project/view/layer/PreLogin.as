package com.rockdot.project.view.layer {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.ugc.model.vo.UGCUserVO;
	import com.rockdot.project.command.event.ProjectEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.button.YellowButton;
	import com.rockdot.project.view.text.Copy;
	import com.rockdot.project.view.text.Headline;

	import flash.events.Event;

	/**
	 * Copyright (c) 2010, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 */
	public class PreLogin extends AbstractLayer {
		private var _contentHeight : Number;
		private var _copy : Copy;
		private var _reasonTitle : UITextField;
		private var _reasonCopy : UITextField;
		private var _databaseTitle : UITextField;
		private var _databaseCopy : UITextField;
		private var _login : YellowButton;
		private var _cancel : YellowButton;
		private var _spinner : swc_trojanlib_loadcircle;

		public function PreLogin(id : String) {
			super(id);
		}

		override public function init(data : * = null) : void {
			super.init(data);

			// copy
			_copy = new Copy(getProperty("copy.cta"), 11, Colors.GREY);
			addChild(_copy);

			_reasonTitle = new Headline(getProperty("copy.reason"), 14, Colors.GREY);
			addChild(_reasonTitle);

			_reasonCopy = new Copy(getProperty("copy.reason." + _data.prompt), 11, Colors.GREY);
			addChild(_reasonCopy);

			_databaseTitle = new Headline(getProperty("copy.database"), 14, Colors.GREY);
			addChild(_databaseTitle);

			_databaseCopy = new Copy(getProperty("copy.database." + _data.prompt), 11, Colors.GREY);
			addChild(_databaseCopy);

			_login = new YellowButton(getProperty("button.login"), _width, BootstrapConstants.HEIGHT_RASTER);
			_login.submitCallback = _onLoginClick;
			addChild(_login);

			// closes this layer
			_cancel = new YellowButton(getProperty("button.back"), _width, BootstrapConstants.HEIGHT_RASTER);
			_cancel.submitCallback = _onCancelClick;
			addChild(_cancel);

			_didInit();
		}

		private function _getPropertyFormatted(string : String) : String {
			return '<p align="center"><body>' + getProperty(string) + '</body></p>';
		}

		override public function render() : void {
			// text
			_headline.x = BootstrapConstants.SPACER;
			_headline.y = _headlineY;
			_headline.width = _width - 2 * BootstrapConstants.SPACER;

			_copy.x = BootstrapConstants.SPACER;
			_copy.y = _headlineY + _headline.textHeight + BootstrapConstants.SPACER;
			_copy.width = _width - 2 * BootstrapConstants.SPACER;

			_reasonTitle.x = BootstrapConstants.SPACER;
			_reasonTitle.y = _copy.y + _copy.textHeight + 2 * BootstrapConstants.SPACER;
			_reasonTitle.width = _width - 2 * BootstrapConstants.SPACER;

			_reasonCopy.x = BootstrapConstants.SPACER;
			_reasonCopy.y = _reasonTitle.y + _reasonTitle.textHeight + BootstrapConstants.SPACER;
			_reasonCopy.width = _width - 2 * BootstrapConstants.SPACER;

			_databaseTitle.x = BootstrapConstants.SPACER;
			_databaseTitle.y = _reasonCopy.y + _reasonCopy.textHeight + 2 * BootstrapConstants.SPACER;
			_databaseTitle.width = _width - 2 * BootstrapConstants.SPACER;

			_databaseCopy.x = BootstrapConstants.SPACER;
			_databaseCopy.y = _databaseTitle.y + _databaseTitle.textHeight + BootstrapConstants.SPACER;
			_databaseCopy.width = _width - 2 * BootstrapConstants.SPACER;

			// buttons

			// _login.x = ApplicationConstants.SPACER;
			_login.y = _databaseCopy.y + _databaseCopy.textHeight + 2 * BootstrapConstants.SPACER;
			_login.setWidth(_width);

			// _cancel.x = ApplicationConstants.SPACER;
			_cancel.y = _login.y + _login.height + BootstrapConstants.SPACER / 2;
			_cancel.setWidth(_width);

			// update height
			_contentHeight = _cancel.y + _cancel.height + BootstrapConstants.SPACER;

			super.render();

			// _spinner.x = LAYER_WIDTH / 2 ;
			// _spinner.y = 30;
			// _spinner.scaleX = .5;
			// _spinner.scaleY = .5;
		}

		private function _onCancelClick() : void {
			new RockdotEvent(StateEvents.STATE_VO_BACK).dispatch();
		}

		private function _onLoginClick() : void {
			_copy.htmlText = _getPropertyFormatted("copy.loading");
			render();
			_login.enabled = false;
			_login.ignoreSetEnabled = true;
			
			new RockdotEvent(ProjectEvents.APP_LOGIN, {prompt:_data.prompt, next:_data.next}, _onLogin).dispatch();
		}

		private function _onLogin(dao : UGCUserVO) : void {
			// some permission prompts have special operations. most of them want to go to the _data.next address
			new RockdotEvent(ProjectEvents.APP_AFTERLOGIN_DISPATCH, _data).dispatch();

			_copy.htmlText = "Name: " + dao.name + "<br/>";
			_copy.htmlText += "Locale: " + dao.locale + "<br/>";
			_copy.htmlText += "Device: " + dao.device + "<br/>";
		}

		private function _onEnterFrameSpinner(event : Event) : void {
			_spinner.rotation += 10;
		}
	}
}
