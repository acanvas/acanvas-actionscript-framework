package com.rockdot.library.view.component.common.video {
	import ca.turbulent.media.Pyro;

	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;


	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 08.06.2011 14:47:03
	 */
	public class VideoPlayer extends SpriteComponent {
		private var _video : Pyro;
		private var _videoControls : VideoControls;
		private var _videoControlsClass : Class;

		public function VideoPlayer(w : uint, h : uint, videoControlsClass : Class) {
			super();
			_width = w;
			_height = h;
			_videoControlsClass = videoControlsClass;

			_video = new Pyro(_width, _height);
			addChild(_video);

			if (_videoControlsClass){
				_videoControls = new _videoControlsClass(_video);
				addChild(_videoControls);
			}
		}

		public function get video() : Pyro {
			return _video;
		}
		
		public function get videoControls() : VideoControls {
			return VideoControls(_videoControls);
		}

		override public function render() : void {
			_video.width = _width;
			_video.height = _height;
		}
	}
}
