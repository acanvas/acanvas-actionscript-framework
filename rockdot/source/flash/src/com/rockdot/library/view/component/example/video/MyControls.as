package com.rockdot.library.view.component.example.video {
	import ca.turbulent.media.Pyro;
	import ca.turbulent.media.events.PyroEvent;

	import com.greensock.TweenMax;
	import com.rockdot.library.view.component.common.scrollable.event.SliderEvent;
	import com.rockdot.library.view.component.common.video.VideoControls;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 09.06.2011 15:11:13
	 */
	public class MyControls extends VideoControls {
		private const PROGRESSBAR_WIDTH : uint = 278;
		private var _progressBarHolder : Sprite;
		private var _progressBarBackground : Shape;
		private var _progressBarLoader : Shape;
		private var _videoScrubber : MyScrubber;
		private var _videoStatusBeforeScrubbing : String;
		private var _progressBar : Shape;
		private var _togglePauseButton : MyTogglePauseButton;
		private var _toggleFullscreenButton : MyToggleFullscreenButton;
		private var _toggleBigPauseButton : MyToggleBigPauseButton;
		private var _toggleMuteButton : MyToggleMuteButton;

		public function MyControls(video : Pyro) {
			super(video);
		}


		override protected function _onVideoStarted(event : PyroEvent) : void {
			super._onVideoStarted(event);

			_initTogglePauseButton();
			_initToggleBigPauseButton();
			_initToggleMuteButton();
			_initToggleFullscreenButton();
			_initProgressBar();
		}


		/**
		 * 
		 * UI BUTTONS
		 * 
		 */
		private function _initTogglePauseButton() : void {
			_togglePauseButton = new MyTogglePauseButton();
			_togglePauseButton.y = _video.height;
			addChild(_togglePauseButton);
			_togglePauseButton.addEventListener(MouseEvent.CLICK, _togglePauseButtonClick, false, 0, true);
		}


		private function _initToggleBigPauseButton() : void {
			_toggleBigPauseButton = new MyToggleBigPauseButton();
			_toggleBigPauseButton.x = Math.floor(_video.width * .5 - _toggleBigPauseButton.width * .5);
			_toggleBigPauseButton.y = Math.floor(_video.height * .5 - _toggleBigPauseButton.height * .5);
			addChild(_toggleBigPauseButton);
			TweenMax.to(_toggleBigPauseButton, 0, {autoAlpha:0});
		}


		private function _togglePauseButtonClick(event : MouseEvent) : void {
			if (_isVideoCompleted) _playAgain();
			else _video.togglePause();
		}


		private function _initToggleMuteButton() : void {
			_toggleMuteButton = new MyToggleMuteButton();
			_toggleMuteButton.x = _video.width - _toggleMuteButton.width * 2 - 1;
			_toggleMuteButton.y = _video.height;
			addChild(_toggleMuteButton);
			_toggleMuteButton.addEventListener(MouseEvent.CLICK, _onToggleMuteButtonClick, false, 0, true);
		}


		private function _onToggleMuteButtonClick(event : MouseEvent) : void {
			_video.toggleMute();
		}


		private function _initToggleFullscreenButton() : void {
			_toggleFullscreenButton = new MyToggleFullscreenButton();
			_toggleFullscreenButton.x = _video.width - _toggleFullscreenButton.width;
			_toggleFullscreenButton.y = _video.height;
			addChild(_toggleFullscreenButton);
			_toggleFullscreenButton.addEventListener(MouseEvent.CLICK, _onFullscreenButtonClick, false, 0, true);
		}


		private function _onFullscreenButtonClick(event : MouseEvent) : void {
			_video.toggleFullScreen();
		}


		/**
		 * 
		 * PROGRESSBAR
		 * 
		 */
		private function _initProgressBar() : void {
			_progressBarHolder = new Sprite();
			_progressBarHolder.x = _togglePauseButton.width;
			_progressBarHolder.y = _video.height;
			addChild(_progressBarHolder);

			_progressBarBackground = new Shape();
			_progressBarBackground.graphics.beginFill(0xFFFFFF, 1);
			_progressBarBackground.graphics.drawRect(0, 0, 1, 20);
			_progressBarBackground.graphics.endFill();
			_progressBarHolder.addChild(_progressBarBackground);
			_progressBarBackground.width = PROGRESSBAR_WIDTH;

			_progressBarLoader = new Shape();
			_progressBarLoader.graphics.beginFill(0x8d8d8d, .8);
			_progressBarLoader.graphics.drawRect(0, 0, 1, 20);
			_progressBarLoader.graphics.endFill();
			_progressBarHolder.addChild(_progressBarLoader);
			_progressBarLoader.addEventListener(Event.ENTER_FRAME, _onUpdateProgressBarLoader, false, 0, true);

			_progressBar = new Shape();
			_progressBar.graphics.beginFill(0x5faf1f, 1);
			_progressBar.graphics.drawRect(0, 0, 1, 20);
			_progressBar.graphics.endFill();
			_progressBarHolder.addChild(_progressBar);

			_videoScrubber = new MyScrubber(PROGRESSBAR_WIDTH);
			_progressBarHolder.addChild(_videoScrubber);

			_videoScrubber.addEventListener(SliderEvent.VALUE_CHANGE, _onSliderValueChange, false, 0, true);
			_videoScrubber.addEventListener(SliderEvent.CHANGE_START, _onSliderBackgroundDown, false, 0, true);
			_videoScrubber.addEventListener(SliderEvent.CHANGE_END, _onSliderBackgroundUp, false, 0, true);

			addEventListener(Event.ENTER_FRAME, _onUpdateVideoScrubber, false, 0, true);
		}


		private function _onUpdateProgressBarLoader(event : Event) : void {
			var percentLoaded : Number = (_video.bytesLoaded / _video.bytesTotal);
			if (percentLoaded >= 1) {
				removeEventListener(Event.ENTER_FRAME, _onUpdateProgressBarLoader);
				percentLoaded = 1;
			}
			_progressBarLoader.width = _progressBarBackground.width * percentLoaded;
		}


		private function _onSliderBackgroundDown(event : SliderEvent) : void {
			_videoStatusBeforeScrubbing = _video.status;
			if (_video.status == Pyro.STATUS_PLAYING) {
				_video.togglePause();
			}
			_onSliderValueChange(null);
			removeEventListener(Event.ENTER_FRAME, _onUpdateVideoScrubber);
		}


		private function _onSliderBackgroundUp(event : SliderEvent) : void {
			if (_videoStatusBeforeScrubbing == Pyro.STATUS_PLAYING) _video.togglePause();
			addEventListener(Event.ENTER_FRAME, _onUpdateVideoScrubber, false, 0, true);
		}


		private function _onUpdateVideoScrubber(event : Event) : void {
			_videoScrubber.value = _video.progressRatio;
			_progressBar.width = _videoScrubber.size * _videoScrubber.value;
		}


		private function _onSliderValueChange(event : SliderEvent) : void {
			if (_videoScrubber.changing) {
				if (_videoScrubber.value < (_video.bytesLoaded / _video.bytesTotal)) {
					_video.seek(_videoScrubber.value * _video.duration);
					_progressBar.width = _videoScrubber.size * _videoScrubber.value;
				}
			}

			// For TimeDislpay you need
			// _video.formattedTime
			// _video.formattedTimeRemaining
			// _video.formattedDuration
		}


		override protected function _playAgain() : void {
			super._playAgain();
			_togglePauseButton.isToggled = true;
			_togglePauseButton.changeState();
			_toggleBigPauseButton.isToggled = true;
			_toggleBigPauseButton.changeState();
		}


		override protected function _onVideoPaused(event : PyroEvent) : void {
			super._onVideoPaused(event);
			if (!_videoScrubber.changing) {
				_togglePauseButton.isToggled = false;
				_togglePauseButton.changeState();
				_toggleBigPauseButton.isToggled = false;
				_toggleBigPauseButton.changeState();
			}
		}


		override protected function _onVideoUnPaused(event : PyroEvent) : void {
			super._onVideoUnPaused(event);
			if (!_videoScrubber.changing) {
				_togglePauseButton.isToggled = true;
				_togglePauseButton.changeState();
				_toggleBigPauseButton.isToggled = true;
				_toggleBigPauseButton.changeState();
			}
		}


		override protected function _onVideoStopped(event : PyroEvent) : void {
			super._onVideoStopped(event);
			if (!_videoScrubber.changing) {
				_togglePauseButton.isToggled = false;
				_togglePauseButton.changeState();
				_toggleBigPauseButton.isToggled = false;
				_toggleBigPauseButton.changeState();
			}
		}


		override protected function _onVideoClick(event : MouseEvent) : void {
			super._onVideoClick(event);
			if (!TweenMax.isTweening(_toggleBigPauseButton)) {
				TweenMax.to(_toggleBigPauseButton, .4, {autoAlpha:1, yoyo:true, repeat:1});
				_toggleBigPauseButton.changeState();
			}
		}


		/**
		 * 
		 * FULLSCREEN
		 * 
		 */
		override protected function _onFullscreen(event : Event) : void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				if (_toggleFullscreenButton.isToggled) {
					_toggleFullscreenButton.changeState();
				}

				_video.resize(_defaultVideoWidth, _defaultVideoHeight);

				// Adjust Controls
				_progressBarHolder.y = _video.height;
				_toggleFullscreenButton.x = _defaultVideoWidth - _toggleFullscreenButton.width;
				_toggleFullscreenButton.y = _video.height;
				_toggleMuteButton.x = _defaultVideoWidth - _toggleMuteButton.width * 2 - 1;
				_toggleMuteButton.y = _defaultVideoHeight;
				_togglePauseButton.y = _defaultVideoHeight;
				_toggleBigPauseButton.x = Math.floor(_defaultVideoWidth * .5 - _toggleBigPauseButton.width * .5);
				_toggleBigPauseButton.y = Math.floor(_defaultVideoHeight * .5 - _toggleBigPauseButton.height * .5);

				_progressBarBackground.width = PROGRESSBAR_WIDTH;
				_videoScrubber.size = _progressBarBackground.width;
			} else {
				_video.resize(stage.fullScreenWidth, stage.fullScreenHeight - 20);

				// Adjust Controls
				_progressBarHolder.y = stage.fullScreenHeight - _progressBarHolder.height;
				_toggleFullscreenButton.x = stage.fullScreenWidth - _toggleFullscreenButton.width;
				_toggleFullscreenButton.y = stage.fullScreenHeight - _toggleFullscreenButton.height;
				_toggleMuteButton.x = stage.fullScreenWidth - _toggleMuteButton.width * 2 - 1;
				_toggleMuteButton.y = stage.fullScreenHeight - _toggleMuteButton.height;
				_togglePauseButton.y = stage.fullScreenHeight - _togglePauseButton.height;
				_toggleBigPauseButton.x = Math.floor(stage.fullScreenWidth * .5 - _toggleBigPauseButton.width * .5);
				_toggleBigPauseButton.y = Math.floor(stage.fullScreenHeight * .5 - _toggleBigPauseButton.height * .5);

				_progressBarBackground.width = stage.fullScreenWidth - _togglePauseButton.width - _toggleMuteButton.width - _toggleFullscreenButton.width - 2;
				_videoScrubber.size = _progressBarBackground.width;
			}
		}
	}
}
