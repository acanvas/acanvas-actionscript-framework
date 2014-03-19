/**
 * <p>Original Author: Daniel Freeman</p>
 *
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 *
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 *
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 *
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 */

package com.danielfreeman.stage3Dacceleration {
	import com.danielfreeman.madcomponents.IContainerUI;
	import com.danielfreeman.madcomponents.UI;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	

	
	public class Stage3DAcceleration {
		
		public static const CONTEXT_COMPLETE:String = "contextComplete";
		
		public static const SCALE_TO_RESOLUTION:Boolean = true;
		
		public static var EASE_IN:Number = 0.05;
		public static var EASE_OUT:Number = 0.95;
		
		protected static var _context3D:Context3D;
		protected static var _screen:Sprite = null;
		
		protected static var _currentlyDoing:Stage3DAcceleration = null;
		protected static var _theDefault:Stage3DAcceleration = null;
		protected static var _onEnterFrameHandler:Function = null;
		
		protected static var _easeIn:Number = EASE_IN;
		protected static var _easeOut:Number = EASE_OUT;

		protected var _aspectRatio:Number;
		

		

/**
 * This is the base class for MadComponents3D classes.
 */
		public function Stage3DAcceleration() {
			_aspectRatio = _screen.stage.stageWidth/_screen.stage.stageHeight;
			_screen.addEventListener(CONTEXT_COMPLETE, contextResumedHandler);
		}
		
/**
 * If not started, initialise a new Stage3D context
 */
		public static function startStage3D(screen:Sprite, index:uint = 0):void {
			if (!_screen) {
				_screen = screen;
				screen.stage.stage3Ds[index].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
				screen.stage.stage3Ds[index].requestContext3D();
			}
		}
		
/**
 * Configure back buffer and set culling as standard
 */
		public static function onContext3DCreate(event:Event):void {		
			_context3D = Stage3D(event.currentTarget).context3D;

			if (!_context3D)
				return;

			_context3D.configureBackBuffer(_screen.stage.stageWidth, _screen.stage.stageHeight, 1, true);
			_context3D.setCulling(Context3DTriangleFace.FRONT);
			
			_context3D.enableErrorChecking = true;
			_screen.dispatchEvent(new Event(CONTEXT_COMPLETE));
		}
		
/**
 * Convert Stage x-coordinate to Stage3D x-coordinate
 */
		protected static function toGraphX(value:Number):Number {
			return 2.0 * value / _screen.stage.stageWidth - 1.0;
		}
		
/**
 * Convert Stage y-coordinate to Stage3D y-coordinate
 */
		protected static function toGraphY(value:Number):Number {
			return 2.0 * value / _screen.stage.stageHeight - 1.0;
		}
		
/**
 * Get scale.
 * This was written to allows textures to be uploaded faster at a lower resolution
 * - but this mechanism is not yet implimented in MadComponents3D
 */
		protected static function get scale():Number {
			return SCALE_TO_RESOLUTION ? UI.scale : 1.0;
		}
		
/**
 * Set easing values
 */
		public static function setEasing(easeIn:Number, easeOut:Number):void {
			_easeIn = easeIn;
			_easeOut = easeOut;
		}
		
/**
 * Bezier easing equation
 */
		protected static function easing(t:Number):Number {
			if (t<0.5) {
				return bezier(0, _easeIn, 0.5, (1-t*2));
			}
			else {
				return bezier(0.5, _easeOut, 1, (1-t)*2);
			}
		}
		
/**
 * Bezier equation
 */
		protected static function bezier(p0:Number,p1:Number,p2:Number,t:Number):Number {//Quadratic bezier
			return t*t*p0+2*t*(1-t)*p1+(1-t)*(1-t)*p2;
		}
		
/**
 * Extract a texture from a Sprite, and save it to a bitmapdata
 */
		protected static function saveTexture(textureBitMapData:BitmapData, panel:DisplayObject, rectangle:Rectangle, x:Number = 0, y:Number = 0, qualityScale:Number = 1.0):void {
			var matrix:Matrix = new Matrix();
			matrix.identity();
			matrix.scale(qualityScale * scale, qualityScale * scale);
			matrix.translate(x + rectangle.x, y + rectangle.y);
			textureBitMapData.draw(panel, matrix, null, null, rectangle);
		}
		
/**
 * value ** 2
 */
		protected static function power2(value:Number):Number {
			return Math.pow(2, Math.ceil(Math.log(value)/Math.LN2));
		}
		
/**
 * Fill a display-list hole
 */
		public static function fillHole(container:Sprite):void {
			if (container is IContainerUI) {
				IContainerUI(container).drawComponent();
			}
			if (container != UI.uiLayer) {
				fillHole(Sprite(container.parent));
			}
		}
		
/**
 * Resume context if lost
 */
		public function contextResumedHandler(event:Event):void {
			contextResumed(_currentlyDoing == this);
		}
		
/**
 * Override to resume after reset context lost
 */
		public function contextResumed(running:Boolean):void {
		}
		
/**
 * Override to enable effect
 */
		public function enable():void {
		}
			
/**
 * Override to disable effect
 */
		public function disable():void {
		}
		
/**
 * Set a MadCmponents3D effect as the default, do when another effect terminates - the default will resume
 */
		protected function isDefault(delegate:Stage3DAcceleration):void {
			_theDefault = delegate;
		}
		
/**
 * Activate an effect so it becomes current
 */
		protected function activate(delegate:Stage3DAcceleration):void {
			
			if (delegate != _currentlyDoing) {
				if (_currentlyDoing) {
					_currentlyDoing.disable();
				}
				
				_currentlyDoing = delegate;
				
				if (delegate) {
					delegate.enable();
				}
			}
		}
		
/**
 * Deactiavte an effect
 */
		protected function deactivate(delegate:Stage3DAcceleration):void {
			if (delegate == _currentlyDoing) {
				if (_onEnterFrameHandler!=null) {
					_screen.removeEventListener(Event.ENTER_FRAME, _onEnterFrameHandler);
					_onEnterFrameHandler = null;
				}
				delegate.disable();
				_currentlyDoing = _theDefault;
				if (_theDefault) {
					_theDefault.enable();
				}
			}
		}
		
/**
 * Set onEnterFrame handler
 */
		protected function onEnterFrame(delegate:Stage3DAcceleration, handler:Function = null):void {
			
			if (delegate == _currentlyDoing) {
				if (_onEnterFrameHandler!=null) {
					_screen.removeEventListener(Event.ENTER_FRAME, _onEnterFrameHandler);
				}

				_onEnterFrameHandler = handler;
			
				if (handler!=null) {
					_screen.addEventListener(Event.ENTER_FRAME, handler);
					handler(new Event(Event.ENTER_FRAME));
				}
			}
		}
		
/**
 * The width of a component
 */
		protected function theWidth(list:IContainerUI):Number {
			return list.attributes.width + (list.attributes.hasBorder ? 2*UI.PADDING : 0);
		}
				
/**
 * The height of a component
 */
		protected function theHeight(list:IContainerUI):Number {
			return list.attributes.height + (list.attributes.hasBorder ? 2*UI.PADDING : 0);
		}
		
		
		public static function staticDestructor():void {
			_screen.stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
		}
		
		
		public function destructor():void {
			_screen.addEventListener(CONTEXT_COMPLETE, contextResumedHandler);
		}

	}
}
