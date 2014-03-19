package com.rockdot.project.view.layer {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.project.view.element.button.YellowButton;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Copyright (c) 2010, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 */
	public class Loading extends AbstractLayer {
		private var _contentHeight : Number;
		private var _cancel : YellowButton;
		private var _circlePreloader : Sprite;

		public function Loading(id : String) {
			super(id);
		}

		override public function init(data : * = null) : void {
			super.init(data);

			_circlePreloader = new Sprite();
			_circlePreloader.addChild(new SWC_mc_preloader_big());
			addChild(_circlePreloader);
			addEventListener(Event.ENTER_FRAME, _onEnterFrameSpinner, false, 0, true);

			// closes this layer
			_cancel = new YellowButton(getProperty("button.back"), _width, BootstrapConstants.HEIGHT_RASTER);
			_cancel.submitCallback = _onCancelClick;
			addChild(_cancel);

			_didInit();
		}

		override public function render() : void {
			// text
			 _circlePreloader.x = (_width - 2 * BootstrapConstants.SPACER) / 2 ;
			 _circlePreloader.y = _headlineY;
			 _circlePreloader.scaleX = .5;
			 _circlePreloader.scaleY = .5;
			 
			_headline.x = BootstrapConstants.SPACER;
			_headline.y = _circlePreloader.y + _circlePreloader.height + BootstrapConstants.SPACER;
			_headline.width = _width - 2 * BootstrapConstants.SPACER;

			// _cancel.x = ApplicationConstants.SPACER;
			_cancel.y = _headline.y + _headline.height + BootstrapConstants.SPACER / 2;
			_cancel.setWidth(_width);

			// update height
			_contentHeight = _cancel.y + _cancel.height + BootstrapConstants.SPACER;

			super.render();

		}

		private function _onCancelClick() : void {
			new RockdotEvent(StateEvents.STATE_VO_BACK).dispatch();
		}

		private function _onEnterFrameSpinner(event : Event) : void {
			_circlePreloader.rotation += 10;
		}
	}
}
