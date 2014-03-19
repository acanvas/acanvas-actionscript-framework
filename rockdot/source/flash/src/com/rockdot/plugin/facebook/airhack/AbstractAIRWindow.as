/*
  Copyright (c) 2010, Adobe Systems Incorporated
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

 * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

 * Neither the name of Adobe Systems Incorporated nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package com.rockdot.plugin.facebook.airhack {
	import com.facebook.graph.controls.Distractor;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.library.view.component.example.button.ExampleButton;

	import flash.display.NativeWindowInitOptions;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.media.StageWebView;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.setTimeout;

	/**
	 * Defines the base class used for displaying Facebook windows.
	 * This class will resize automatically to the underlying HTMLControl.
	 * This class should not be instantiated, but extended.
	 *
	 */
	public class AbstractAIRWindow extends Sprite {
		/**
		 * Default window width.
		 *
		 */
		public static var WINDOW_WIDTH : Number = 460;
		/**
		 * Default window height.
		 *
		 */
		public static var WINDOW_HEIGHT : Number = 260;
		protected var webView : StageWebView;
		/**
		 * @private
		 *
		 */
		protected var html : HTMLLoader;
		/**
		 * @private
		 *
		 */
		protected var distractor : Distractor;
		/**
		 * @private
		 *
		 */
		protected var modalOverlay : Sprite;
		/**
		 * @private
		 *
		 */
		protected var inLoad : Boolean;
		private var _button : Button;
		/**
		 * Creates a new AbstractWindow instance.
		 * This class is Abstract and should only be extended.
		 *
		 */
		protected var _stage : Stage;

		public function AbstractAIRWindow(stage : Stage) {
			_stage = stage;
			super();

			configUI();
		}

		/**
		 * @private
		 *
		 */
		protected function configUI() : void {
			distractor = new Distractor();
			distractor.text = 'Connecting to Facebook…';

			_button = new ExampleButton("X");
			_button.addEventListener(MouseEvent.CLICK, _onCloseButtonClick);

			modalOverlay = new Sprite();
			modalOverlay.graphics.beginFill(0xffffff, 1);
			modalOverlay.graphics.drawRect(0, 0, 1, 1);
		}

		private function _onCloseButtonClick(event : MouseEvent) : void {
			closeWindow();
		}

		/**
		 * @private
		 *
		 */
		protected function setSize(width : Number, height : Number) : void {
			if ( html ) {
				html.stage.nativeWindow.width = width;
				html.stage.nativeWindow.height = height;
			} else {
				trace('setSize: ' + width + ':' + height);
				webView.viewPort = new Rectangle(0, 0, width, height);
			}
		}

		/**
		 * @private
		 *
		 */
		protected function showWindow(req : URLRequest, bounds : Rectangle = null) : void {
//			if ( HTMLLoader.isSupported ) {
//				var initOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
//
//				initOptions.resizable = true;
//				initOptions.maximizable = false;
//
//				html = HTMLLoader.createRootWindow(true, initOptions, false, bounds);
//				html.stage.nativeWindow.addEventListener(Event.CLOSING, handleWindowClosing, false, 0, true);
//				html.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, handleWindowResize, false, 0, true);
//				html.addEventListener(Event.LOCATION_CHANGE, handleLocationChange, false, 0, true);
//				html.addEventListener(Event.HTML_DOM_INITIALIZE, handleHtmlDomInit, false, 0, true);
//				html.load(req);
//
//				setTimeout(focusWindow, 500);
//			} else {
				webView = new StageWebView();
				webView.stage = _stage;
				webView.viewPort = bounds;
				webView.addEventListener(Event.COMPLETE, handleLocationChange, false, 0, true);
				webView.addEventListener(Event.LOCATION_CHANGE, handleLocationChange, false, 0, true);
				webView.loadURL(req.url);
//			}
			showDistractor();
		}

		/**
		 * @private
		 *
		 */
		protected function focusWindow() : void {
			if ( html ) {
				if (html.stage.nativeWindow.closed == false) {
					html.stage.nativeWindow.activate();
				}
			}
		}

		/**
		 * @private
		 *
		 */
		protected function handleWindowClosing(event : Event = null) : void {
			if ( html ) {
				html.removeEventListener(Event.COMPLETE, handleHtmlComplete);
				html.stage.nativeWindow.removeEventListener(Event.CLOSING, handleWindowClosing);
				html.stage.nativeWindow.removeEventListener(NativeWindowBoundsEvent.RESIZE, handleWindowResize);
				html.removeEventListener(Event.LOCATION_CHANGE, handleLocationChange);
				html.removeEventListener(Event.HTML_DOM_INITIALIZE, handleHtmlDomInit);
			}

			if (webView) {
				webView.removeEventListener(Event.COMPLETE, handleLocationChange);
				webView.removeEventListener(Event.LOCATION_CHANGE, handleLocationChange);
			}

			hideDistractor();
			handleWindowClosed();
		}

		/**
		 * @private
		 *
		 */
		protected function handleHtmlComplete(event : Event) : void {
			inLoad = false;
		}

		/**
		 * @private
		 *
		 */
		protected function handleWindowClosed() : void {
		}

		/**
		 * @private
		 *
		 */
		protected function handleLocationChange(event : Event) : void {
			inLoad = true;
		}

		/**
		 * @private
		 *
		 */
		protected function handleHtmlDomInit(event : Event) : void {
			hideDistractor();
		}

		/**
		 * @private
		 *
		 */
		protected function handleWindowResize(event : NativeWindowBoundsEvent = null) : void {
			var bounds : Rectangle;
			if ( html ) {
				bounds = html.stage.nativeWindow.bounds;
			} else {
				bounds = webView.viewPort;
			}

			distractor.x = bounds.x + (bounds.width - distractor.width >> 1);
			distractor.y = bounds.y + (bounds.height - distractor.height >> 1);

			_button.x = bounds.width - _button.width;
			_button.y = bounds.y - _button.height;

			modalOverlay.x = bounds.x;
			modalOverlay.y = bounds.y;
			modalOverlay.width = bounds.width;
			modalOverlay.height = bounds.height;
		}

		/**
		 * @private
		 *
		 */
		protected function showDistractor() : void {
			_stage.addChild(_button);
			_stage.addChild(modalOverlay);
			_stage.addChild(distractor);
			handleWindowResize();
		}

		/**
		 * @private
		 *
		 */
		protected function hideDistractor() : void {
			if (distractor && _stage.contains(distractor)) {
				_stage.removeChild(distractor);
				_stage.removeChild(_button);
				_stage.removeChild(modalOverlay);
			}
		}

		/**
		 * @private
		 *
		 * Obtains the query string from the current HTML location
		 * and returns its values in a URLVariables instance.
		 *
		 */
		protected function getURLVariables() : URLVariables {
			var vars : URLVariables = new URLVariables();
			var params : String;

			var loc : String;
			if ( html ) {
				loc = html.location;
			} else {
				loc = webView.location;
			}

			if (loc.indexOf('#') != -1) {
				params = loc.slice(loc.indexOf('#') + 1);
			} else if (loc.indexOf('?') != -1) {
				params = loc.slice(loc.indexOf('?') + 1);
			}

			if (params != null) {
				vars.decode(params);
			}

			return vars;
		}

		protected function closeWindow() : void {
			hideDistractor();

			if ( webView ) {
				webView.dispose();
				webView = null;
			}

			if (html) {
				html.stage.nativeWindow.close();
			}
		}
	}
}