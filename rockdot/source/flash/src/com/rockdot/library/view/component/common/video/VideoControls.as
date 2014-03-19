package com.rockdot.library.view.component.common.video {
	import ca.turbulent.media.Pyro;
	import ca.turbulent.media.events.PyroEvent;

	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;



	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 09.06.2011 13:37:14
	 */
	public class VideoControls extends SpriteComponent {

		protected var _video : Pyro;
		
//		private var _preloader : SWC_sprite_AppPreloader;
		protected var _isVideoCompleted : Boolean;
		protected var _isVideoFlushed : Boolean;
		protected var _defaultVideoWidth : Number;
		protected var _defaultVideoHeight : Number;
		
		public function VideoControls(video : Pyro) {
			super();
			_video = video;
			_defaultVideoWidth = _video.width;
			_defaultVideoHeight = _video.height;
			_initPreloader();
			
			_video.addEventListener(PyroEvent.NEW_STREAM_INIT, _onNewStreamInit, false, 0, true);
			_video.addEventListener(PyroEvent.STARTED, _onVideoStarted, false, 0, true);
			_video.addEventListener(PyroEvent.STOPPED, _onVideoStopped, false, 0, true);
			_video.addEventListener(PyroEvent.PAUSED, _onVideoPaused, false, 0, true);
			_video.addEventListener(PyroEvent.UNPAUSED, _onVideoUnPaused, false, 0, true);
			_video.addEventListener(PyroEvent.SEEKED, _onVideoSeeked, false, 0, true);
			_video.addEventListener(PyroEvent.VOLUME_UPDATE, _onVideoVolumeUpdate, false, 0, true);
			_video.addEventListener(PyroEvent.BUFFER_EMPTY, _onVideoBufferEmpty, false, 0, true);
			_video.addEventListener(PyroEvent.BUFFER_FLUSH, _onVideoBufferFlush, false, 0, true);
			_video.addEventListener(PyroEvent.BUFFER_FULL, _onVideoBufferFull, false, 0, true);
			_video.addEventListener(PyroEvent.BUFFER_TIME_ADJUSTED, _onVideoBufferTimeAdjusted, false, 0, true);
			_video.addEventListener(PyroEvent.METADATA_RECEIVED, _onVideoMetadataReceived, false, 0, true);	
			_video.addEventListener(PyroEvent.COMPLETED, _onVideoCompleted, false, 0, true);
			_video.addEventListener(PyroEvent.MUTED, _onVideoMuted, false, 0, true);
			_video.addEventListener(PyroEvent.UNMUTED, _onVideoUnMuted, false, 0, true);
			_video.addEventListener(PyroEvent.STARTED, _onVideoUnMuted, false, 0, true);
			
			_video.doubleClickEnabled = true;
			_video.addEventListener(MouseEvent.CLICK, _onVideoClick, false, 0, true);
			_video.addEventListener(MouseEvent.DOUBLE_CLICK, _onVideoDoubleClick, false, 0, true);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyboardDown, false, 0, true);
			stage.addEventListener(Event.FULLSCREEN, _onFullscreen, false, 0, true);
			
		}

		
		/**
		 * 
		 * VIDEO AND PYRO EVENTS
		 * 
		 */
		private function _onNewStreamInit(event : PyroEvent) : void {
//			_log.trace("_onNewStreamInit");
		}
		
		protected function _onVideoClick(event : MouseEvent) : void {
//			_log.trace("_onVideoClick");
			if(_isVideoCompleted) _playAgain();
			else _video.togglePause();
		}
		
		protected function _onVideoDoubleClick(event : MouseEvent) : void {
//			_log.trace("_onVideoDoubleClick");
			_video.togglePause();
			_video.toggleFullScreen();
		}

		protected function _onVideoStarted(event : PyroEvent) : void {
//			_log.trace("_onVideoStarted");
			_hidePreloader();
		}

		protected function _onVideoStopped(event : PyroEvent) : void {
//			_log.trace("_onVideoStopped");
		}

		protected function _onVideoPaused(event : PyroEvent) : void {
//			_log.trace("_onVideoPaused");
		}

		protected function _onVideoUnPaused(event : PyroEvent) : void {
//			_log.trace("_onVideoUnPaused");
		}

		protected function _onVideoSeeked(event : PyroEvent) : void {
//			_log.trace("_onVideoSeeked");
		}

		protected function _onVideoVolumeUpdate(event : PyroEvent) : void {
//			_log.trace("_onVideoVolumeUpdate");
		}
		
		protected function _onVideoMuted(event : PyroEvent) : void {
//			_log.trace("_onVideoMuted");
		}

		protected function _onVideoUnMuted(event : PyroEvent) : void {
//			_log.trace("_onVideoUnMuted");
		}

		protected function _onVideoBufferEmpty(event : PyroEvent) : void {
//			_log.trace("_onVideoBufferEmpty");
			if(!_isVideoFlushed) _showPreloader();
		}

		protected function _onVideoBufferFlush(event : PyroEvent) : void {
//			_log.trace("_onVideoBufferFlush");
			_isVideoFlushed = true;
		}

		protected function _onVideoBufferFull(event : PyroEvent) : void {
//			_log.trace("_onVideoBufferFull");
			_hidePreloader();
		}

		protected function _onVideoBufferTimeAdjusted(event : PyroEvent) : void {
//			_log.trace("_onVideoBufferTimeAdjusted");
		}

		protected function _onVideoMetadataReceived(event : PyroEvent) : void {
//			_log.trace("_onVideoMetadataReceived");
			_video.removeEventListener(PyroEvent.METADATA_RECEIVED, _onVideoMetadataReceived);
		}

		protected function _onVideoCompleted(event : PyroEvent) : void {
//			_log.trace("_onVideoCompleted");
			_isVideoCompleted = true;
		}
		
		protected function _playAgain() : void {
//			_log.trace("_playAgain");
			_video.seek(0);
			_isVideoCompleted = false;
			_isVideoFlushed = false;
		}
		
		protected function _onKeyboardDown(event : KeyboardEvent) : void {
			if (event.keyCode == Keyboard.SPACE) _video.togglePause();
		}
		
		protected function _onFullscreen(event : Event) : void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				_video.resize( _defaultVideoWidth, _defaultVideoHeight );
			} else {
				_video.resize( stage.fullScreenWidth, stage.fullScreenHeight );
			}
		}
		
		
		
		/**
		 * 
		 * PRELOADER
		 * 
		 */
		protected function _initPreloader() : void {
		}
		
		protected function _showPreloader() : void {
		}
		
		protected function _hidePreloader() : void {
		}
		
		
		
		
		
		/**
		 * 
		 * REMMOVE STAGE LISTENERS
		 * 
		 */
		public function killStagetListeners() : void {
			trace("VideoControls killStagetListeners");
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyboardDown);
			stage.removeEventListener(Event.FULLSCREEN, _onFullscreen);
		}
		
	}
}
