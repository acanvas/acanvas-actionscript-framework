package com.rockdot.project.view.screen {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.SimpleButton;
	import com.rockdot.project.view.text.Copy;
	import com.rockdot.project.view.text.Headline;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class Home extends AbstractScreen{

		private var _pageHeadline : Headline;
		private var _pageCopy : Copy;
		private var _button : SimpleButton;

		public function Home(id : String)
		{
				super(id);
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);
			
			
			_pageHeadline = new Headline(getProperty("headline"), 18, Colors.BLACK);
			addChild(_pageHeadline);

			_pageCopy = new Copy(getProperty("copy"), 18, Colors.GREY_DARK);
			addChild(_pageCopy);
			
			_button = new SimpleButton(getProperty("button.test"), _width, BootstrapConstants.HEIGHT_RASTER);
			_button.submitEvent = new RockdotEvent(StateEvents.ADDRESS_SET, getProperty("screen.test.url", true));
			addChild(_button);
						
			_didInit();
		}

		override public function render() : void {
			super.render();

			_pageHeadline.x = 0;
			_pageHeadline.y = 2*BootstrapConstants.SPACER;
			_pageHeadline.width = _width - BootstrapConstants.SPACER;

			_pageCopy.x = _pageHeadline.x + BootstrapConstants.SPACER;
			_pageCopy.y = _pageHeadline.y + _pageHeadline.textHeight + BootstrapConstants.SPACER;
			_pageCopy.width = _width - 2*BootstrapConstants.SPACER;

			_button.x = _pageCopy.x + BootstrapConstants.SPACER;
			_button.y = _pageCopy.y + _pageCopy.textHeight + BootstrapConstants.SPACER;
			_button.setSize(_width - 4*BootstrapConstants.SPACER, BootstrapConstants.HEIGHT_RASTER);
			
		}
		
		override public function setSize(w : int, h : int) : void {
			super.setSize(BootstrapConstants.WIDTH_STAGE - 2*BootstrapConstants.X_PAGES, BootstrapConstants.HEIGHT_STAGE - BootstrapConstants.Y_PAGES - BootstrapConstants.HEIGHT_RASTER - 2*BootstrapConstants.SPACER);
		}
		
		override public function appear(duration : Number = 0.5) : void {
//			super.appear(duration);
//			TweenLite.to(this, duration, {autoAlpha:1});
			_onAppear();
		}

		override public function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void {
//			super.disappear(duration, autoDestroy);
//			TweenLite.to(this, duration, {autoAlpha:0});
			_onDisappear();
		}
		
	}
}
