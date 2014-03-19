package com.rockdot.library.view.component.common {
	import com.jvm.utils.DeviceDetector;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.system.Security;
	import flash.system.SecurityPanel;

	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author 	Nils Doehring (nilsdoehring(at)gmail.com)
	 * @since	04.05.2011
	 */
	public class ComponentCamera extends SpriteComponent {
		private var _cam : Camera;
		private var _video : Video;
		private var _bandwidth : uint;
		private var _quality : uint;
		private var _fps : uint;

		public function ComponentCamera(bandwith : uint = 0, quality : uint = 1, fps : uint = 15) {
			super();

			_bandwidth = bandwith;
			_quality = quality;
			_fps = fps;

			if (Camera.isSupported) {
				_cam = Camera.getCamera();
			}

			if (!_cam) {
				_log.debug("No camera is installed.");
			} else {
				_log.debug("Connecting");
				_connectCamera();
			}
		}

		override public function setSize(w : int, h : int) : void {
			if (w == _width || h == _height) {
				return;
			}
			
//			if (w > h * .75) {
//				// landscape
//				h = w * .75;
//			} else {
//				// portrait
//				w = (h / 3) * 4;
//			}

			_cam.setMode(w, h, _fps);

			if (_video) {
				_video.width = w;
				_video.height = h;
				_video.x = (w - _video.width) * .5;
			}

			super.setSize(w, h);
		}

		private function _connectCamera() : void {
			var w : int = _width;
			var h : int = _height;

			_cam.setQuality(_bandwidth, _quality);
			_video = new Video(w, h);
			_video.smoothing = true;
			_video.attachCamera(_cam);
			addChild(_video);

			setSize(w, h);
		}

		public function openSecurityDialog() : void {
			if (_cam)
				_cam.addEventListener(StatusEvent.STATUS, statusHandler);
			else
				_log.debug("No camera is installed.");

			if (!DeviceDetector.IS_MOBILE) {
				Security.showSettings(SecurityPanel.PRIVACY);
			}
		}

		private function statusHandler(event : StatusEvent) : void {
			if (event.code == "Camera.Unmuted") {
				_connectCamera();
				_cam.removeEventListener(StatusEvent.STATUS, statusHandler);
			}
		}

		public function get cam() : Camera {
			return _cam;
		}

		public function get video() : Video {
			return _video;
		}
	}
}
