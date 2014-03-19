package com.rockdot.library.view.component.common {
	import com.greensock.TweenLite;
	import com.jvm.utils.BitmapUtils;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;





	/**
	 * Copyright 2009 Jung von Matt/Neckar
	 */
	public class ComponentImageLoader extends SpriteComponent {
		private var _loader : Loader;
		private var _img : Bitmap;
		private var _href : String;

		public function ComponentImageLoader(href : String, w:int, h:int)
		{
			super();
			_width = w;
			_height = h;
			_href = href;
			alpha = 0;

			if (!_href ) {
				onComplete();
				return;
			}

			if (RockdotConstants.PROTOCOL == "https:") {
				if (_href.indexOf("fbcdn.net") != -1) {
					_href = _href.replace("http://profile.ak.fbcdn.net", "https://fbcdn-profile-a.akamaihd.net");
				} else {
					_href = _href.replace("http:", "https:");
				}
			}

			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);

			try {
				_loader.load(new URLRequest(_href), new LoaderContext(true));
			} catch ( error : Error ) {
				trace("Error while loading '" + _href + "': " + error.message);

				onComplete();
			}
		}

		private function onComplete(event : Event = null) : void
		{
			if (_loader && _loader.content ) {
				_img = Bitmap(_loader.content) ;
			} else {
				var dobj : Sprite = new Sprite();
				dobj.graphics.beginFill(0x222222);
				dobj.graphics.drawRect(0,0,10,10);
				
				_img = BitmapUtils.getBitmapFromDisplayObject(dobj);
			}

			_img.smoothing = true;

			// calculate and apply scale
			var scale : Number = 0;
			if (_img.width > _img.height) {
				// scale = _width/ _img.width;
				scale = _height / _img.height;
			} else {
				// scale = _height / _img.height;
				scale = _width / _img.width;
			}
			_img.scaleX = scale;
			_img.scaleY = scale;
			_img.x = (_width-_img.width)/2;
			_img.y = (_height-_img.height)/2;

			// mask with rounded edges
			var mask : Shape;
			mask = new Shape();
			mask.graphics.beginFill(0xff0000, 1);
			mask.graphics.drawRoundRect(0, 0, _width, _height, 2, 2);
			mask.graphics.endFill();
			_img.mask = mask;

			addChild(mask);
			addChild(_img);

			TweenLite.to(this, .8, {alpha:1});
		}
		
		
		override public function get height() : Number {
			return _height;
		}

		private function onIoError(event : IOErrorEvent) : void
		{
			trace("IO error occured while loading image");
			onComplete();
		}

		private function onSecurityError(event : SecurityErrorEvent) : void
		{
			trace("Security error occured while loading image");
			onComplete();
		}
	}
}
