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
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	import com.danielfreeman.extendedMadness.UIe;
	import com.danielfreeman.madcomponents.IContainerUI;
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UIPages;
	import com.danielfreeman.madcomponents.UIScrollVertical;
	import com.danielfreeman.madcomponents.UISwitch;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.utils.Timer;

/**
 * This class impliments 3D page flipping capabilities.
 * There are four flipping modes.  MadPages (2D), MadFlow, MadCircle, and MadSwap
 */
	public class PageFolding extends Stage3DAcceleration {
		
		public static const CHANGED:String = "pageFoldingChanged";

		protected static const TEXTURE_WIDTH:int = 2048;
		protected static const TEXTURE_HEIGHT:int = 2048;
		protected static const TOUCH_MULTIPLIER:Number = 1.5;
		protected static const DELTA:Number = 0.08;

		protected static const ZOOM:Number = 1.73;
		protected static const DARKEN:Number = 0.9;
		protected static const SENSITIVITY:Number = 2.0;
		protected static const LIMIT:Number = 0.2;
		protected static const THRESHOLD:Number = 0.1;
		protected static const SMALL:Number = 0.01;
		
		protected static const CLICK_FRAMES:int = 2;
		protected static const CLICK_THRESHOLD:Number = 0.04;
		
		protected var _textureBitMapData:Vector.<BitmapData> = null;
		protected var _vertices:Vector.<Number>;
		protected var _uv:Vector.<Number>;
		protected var _indices:Vector.<uint>;
		protected var _indexBuffer:IndexBuffer3D;
		protected var _xyzVertexBuffer:VertexBuffer3D;
		protected var _uvVertexBuffer:VertexBuffer3D;
		protected var _backgroundColour:uint = 0x000000;

		protected var _pageFoldingVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _pageFoldingFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _pageFoldingShaderProgram:Program3D;
		protected var _pageFoldingTexture:Vector.<Texture>;
		
		protected var _finalMatrix:Matrix3D = new Matrix3D();
		protected var _projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		
		protected var _count:uint = 0;

		protected var _pageWidth:Number;
		protected var _pageHeight:Number;
		protected var _columns:Number;
		protected var _rows:Number;
		protected var _container:IContainerUI = null;
		protected var _gridPages:Vector.<GridPageQuarter> = new Vector.<GridPageQuarter>();
		protected var _index:int = 0;
		protected var _position:Number = 0;
		protected var _horizontal:Boolean = false;
		
		protected var _mouseDown:Boolean = false;
		protected var _lastX:Number;
		protected var _lastY:Number;
		protected var _distance:Number;
		protected var _destination:Number = Number.NaN;
		protected var _deltaX:Number;
		protected var _deltaY:Number;
		protected var _searchHitComponent:DisplayObject = null;
		protected var _searchHit:DisplayObject = null;
		protected var _frameCount:int = 0;
		protected var _autoUpdateComponents:Boolean = true;
		protected var _listenForChange:UISwitch = null;
		protected var _interraction:Boolean = false;
		
		protected var _delayedStage3D:Timer = new Timer(50,1);
		
		public function PageFolding() {
			initialise();
			_delayedStage3D.addEventListener(TimerEvent.TIMER, showStage3D);
		}
		
 /**
 * Set background colour
 */
		public function set backgroundColour(value:uint):void {
			_backgroundColour = value;
		}
		
/**
 * For custom renderers, if a components is clicked - update textures.
 */
		public function set autoUpdateComponents(value:Boolean):void {
			_autoUpdateComponents = value;
		}
		
		
		public function set horizontal(value:Boolean):void {
			_horizontal = value;
		}
		
		
		public function get pageNumber():int {
			return isNaN(_destination) ? Math.round(_position) : Math.round(_destination);
		}
		
		
		public function set pageNumber(value:int):void {
			_destination = value;
		}
			
/**
 * Apply a translation matrix
 */
		protected function translationMatrix():void {
			_projectionMatrix.perspectiveFieldOfViewLH(60.0*Math.PI/180, 1.0, 0.1, 1000.0);
			_finalMatrix.identity();
			_finalMatrix.appendTranslation(0, 0, ZOOM);
			_finalMatrix.append(_projectionMatrix);
		}
		
/**
 * The vertex shader aloows for horizontal translation (scrolling), and applies the perspective transformation matrix
 * 
 * The fragment shader optionally applies a fading effect to squares to make an inverted page appear like a reflection
 */
		public function initialise():void {

			translationMatrix();

			_pageFoldingVertexShader.assemble( Context3DProgramType.VERTEX,
				"mul vt0.xyzw, va0.xyxw, vc4.xyzw \n" +
				"mul vt1.xyzw, va0.xyyw, vc5.xyzw \n" +
				"add vt0, vt0, vt1 \n" +
				"m44 op, vt0, vc0 \n" +	// vertex
				"mov v0, va1 \n"	// interpolate UVT
			);
			
			_pageFoldingFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"tex ft0, v0.xy, fs0 <2d,linear,nomip> \n" +	// output texture
				"mul oc, ft0, fc0.xxxx \n"
			);
			
			_pageFoldingShaderProgram = _context3D.createProgram();
			_pageFoldingShaderProgram.upload( _pageFoldingVertexShader.agalcode, _pageFoldingFragmentShader.agalcode);
		}
		
/**
 * Capture all of the pages within a MadComponents container.  (UIPages, UINavigation, etc.).
 * Notice optional showPageIndicator parameter.  If true, displays a page indicator at the bottom of the screen.
 */
		public function containerPageTextures(container:IContainerUI):void {
			var pages:Vector.<Sprite> = new Vector.<Sprite>();
			for each (var page:Sprite in container.pages) {
				pages.push(page);
			}
			_container = container;
			pageTextures(container.attributes.width, container.attributes.height, pages, container.attributes.backgroundColours.length>0 ? container.attributes.backgroundColours[0] : 0xFFFFFF);
		}

/**
 * Capture all of the pages within specified as a Vector of Sprites.
 * Notice optional showPageIndicator parameter.  If true, displays a page indicator at the bottom of the screen.
 */
		public function pageTextures(width:Number, height:Number, pages:Vector.<Sprite>, backgroundColour:uint = 0xFFFFFF):void {
			_pageWidth = width*scale;
			_pageHeight = height*scale;
			_count = pages.length;
			for each (var page:Sprite in pages) {
				var gridPage:GridPageQuarter = new GridPageQuarter(IContainerUI(page), backgroundColour);
				gridPage.vertices = Vector.<Number> ([
				//	X,				Y,				Z,
					-1.0,			-1.0,			0.0,
					1.0,			-1.0,			0.0,
					1.0,			1.0,			0.0,
					-1.0,			1.0,			0.0
				]);
				_gridPages.push(gridPage);
			}
		}
		
/**
 *  Enable page flipping
 */
		override public function enable():void {
			setRegisters();
			onEnterFrame(this, renderStuff);
			
		}
		
/**
 *  Disable page flipping
 */
		override public function disable():void {
			unSetRegisters();
			removeListeners();
		}
		
		
		protected function addListeners():void {
			_screen.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		
		protected function removeListeners():void {
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		
		protected function mouseDown(event:MouseEvent):void {
			_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_screen.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_mouseDown = true;
			_lastX = _screen.stage.mouseX / _screen.stage.stageWidth;
			_lastY = _screen.stage.mouseY / _screen.stage.stageHeight;
			_distance = 0;
			_frameCount = 0;
			_destination = Number.NaN;
			_searchHit = null;
			event.stopPropagation();
		}
		
		
		protected function mouseUp(event:MouseEvent):void {
			_screen.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
				
			if (_searchHit) {
				if (_mouseDown) {
					_searchHit.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				}
				if (_autoUpdateComponents && _searchHitComponent) {
					updatePage(Math.round(_position), _searchHitComponent);
				}
				_searchHit = null;
				_position = Math.round(_position);
				if (!_listenForChange) {
					UI.uiLayer.visible = false;
					_interraction = false;
				}
			}
			else {
				var fraction:Number = _position - Math.floor(_position);
				if (_position < 0) {
					_destination = 0;
				}
				else if (_position > _gridPages.length - 1) {
					_destination = _gridPages.length - 1;
				}
				else if (fraction <= THRESHOLD) {
					_destination = Math.floor(_position);
				}
				else if (fraction >= 1.0 - THRESHOLD) {
					_destination = Math.ceil(_position);
				}
				else if (_horizontal) {
					_destination = (_deltaX < 0) ? Math.floor(_position) : Math.ceil(_position);
				}
				else {
					_destination = (_deltaY < 0) ? Math.floor(_position) : Math.ceil(_position);
				}
			}
			_mouseDown = false;
		}

		
		public function start(horizontal:Boolean = false):void {
			_horizontal = horizontal;
			activate(this);
			addListeners();
			UI.uiLayer.visible = false;
			UI.uiLayer.mouseChildren = UI.uiLayer.mouseChildren = false;
		}
		
		
		public function stop():void {
			deactivate(this);
			removeListeners();
			UI.uiLayer.visible = true;
			UI.uiLayer.mouseChildren = UI.uiLayer.mouseChildren = true;
		}
		
/**
 * Restore shaders, streams and textures after context loss.
 */
		override public function contextResumed(running:Boolean):void {

			_pageFoldingShaderProgram = _context3D.createProgram();
			_pageFoldingShaderProgram.upload( _pageFoldingVertexShader.agalcode, _pageFoldingFragmentShader.agalcode);
			
			for each (var page:GridPageQuarter in _gridPages) {
				page.contextResumed(running);
			}
		}
		
/**
 * Update the appearance of a component on a particular page.
 */
		public function updatePage(pageNumber:int, component:DisplayObject = null):void {
			_gridPages[pageNumber].updatePage(component);
		}
		
		
		public function loadPage(pageNumber:int, backgroundColour:uint = 0xFFFFFFFF):void {
			_gridPages[pageNumber].loadPage(backgroundColour);
		}
				
		
		protected function setRegisters():void {
			_context3D.setVertexBufferAt( 0, _xyzVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va1
			_context3D.setProgram(_pageFoldingShaderProgram);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _finalMatrix, true); //vc0 - vc3
		}
		
		
		protected function unSetRegisters():void {
			_context3D.setVertexBufferAt( 0, null ); //va0
			_context3D.setVertexBufferAt( 1, null ); //va1
			_context3D.setTextureAt(0, null);
		}
		

		protected function renderStuff(event:Event):void {
	
			if (_mouseDown) {
				
				if (!_interraction) {
					var x:Number = _screen.stage.mouseX / _screen.stage.stageWidth;
					var y:Number = _screen.stage.mouseY / _screen.stage.stageHeight;
					_deltaX = _lastX - x;
					_deltaY = _lastY - y;
					_distance += Math.abs(_deltaX) + Math.abs(_deltaY);
					_position += SENSITIVITY * (_horizontal ? _deltaX : _deltaY);
					
					if (_position < -LIMIT) {
						_position = -LIMIT;
					}
					else if (_position > _gridPages.length + LIMIT - 1) {
						_position = _gridPages.length + LIMIT - 1;
					}

					_lastX = x;
					_lastY = y;
				}
				
				if (_frameCount == CLICK_FRAMES && _distance < CLICK_THRESHOLD) {
					isClickOnComponent();
					if (_searchHit) {
						_interraction = true;
						componentClicked();
					}
				}
				else if (_searchHit) {
					_searchHit.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
				}
				
				_frameCount++;
			}
			else if (!isNaN(_destination)) {
				
				if (Math.abs(_position - _destination) < 0.0001) {
					_position = _destination;
					_destination = Number.NaN;
					_screen.dispatchEvent(new Event(CHANGED));
				}
				else {
					var delta:Number = Math.min( Math.abs(_destination - _position), DELTA);
					_position += (_destination > _position) ? delta : -delta;
				}
			}

			if (UI.uiLayer.visible != _interraction) {
				UI.uiLayer.visible = _interraction;
			}

			if (_horizontal) {
				drawHorizontal();
			}
			else {
				drawVertical();
			}
		}
		
		
		protected function drawHorizontal():void {
			_context3D.clear((_backgroundColour>>32 & 0xff)/0xff, (_backgroundColour>>16 & 0xff)/0xff, (_backgroundColour & 0xff)/0xff);
			var page:GridPageQuarter = _position < 0 ? null : _gridPages[Math.floor(_position)];
			var fractional:Number = _position - Math.floor(_position);
			var nextPage:GridPageQuarter = (fractional > 0 && Math.ceil(_position) < _gridPages.length) ? _gridPages[Math.ceil(_position)] : null;
			
			if (fractional > 1.0 - SMALL) {
				page = nextPage;
				nextPage = null;
				fractional = 0.0;
			}
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, Vector.<Number>([ 0.0, 0.0, 0.0, 0.0 ]) );	// vc5
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 1.0, 0.0, 0.0, 0.0 ]) );	// fc0
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ 1.0, 1.0, 0.0, 1.0 ]));	// vc4
			
			if (page) {
				page.displayTopLeft();
				page.displayBottomLeft();
			}
			
			if (nextPage && fractional > SMALL) {
				nextPage.displayTopRight();
				nextPage.displayBottomRight();		
			}
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ Math.max(fractional, 1.0 - fractional, DARKEN), 0.0, 0.0, 0.0 ]) );	// fc0
			if (fractional < 0.5) {
				_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4,
					Vector.<Number>([ 1.0 - 2.0 * fractional, 1.0, -2.0 * fractional, 1.0 ])); //vc4
				page.displayTopRight();
				page.displayBottomRight();
			}
			else if (nextPage) {
				_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4,
					Vector.<Number>([ 2.0 * (fractional - 0.5), 1.0, (1.0 - 2.0 * (fractional - 0.5)), 1.0 ]));	// vc4
				nextPage.displayTopLeft();
				nextPage.displayBottomLeft();				
			}
		
			_context3D.present();
		}
		
		
		protected function drawVertical():void {
			_context3D.clear((_backgroundColour>>32 & 0xff)/0xff, (_backgroundColour>>16 & 0xff)/0xff, (_backgroundColour & 0xff)/0xff);
			var page:GridPageQuarter = _position < 0 ? null : _gridPages[Math.floor(_position)];
			var fractional:Number = _position - Math.floor(_position);
			var nextPage:GridPageQuarter = (Math.ceil(_position) < _gridPages.length) ? _gridPages[Math.ceil(_position)] : null;
			
			if (fractional > 1.0 - SMALL) {
				page = nextPage;
				nextPage = null;
				fractional = 0.0;
			}
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ 0.0, 0.0, 0.0, 0.0 ]) );	// vc4
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 1.0, 0.0, 0.0, 0.0 ]) );	// fc0
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, Vector.<Number>([ 1.0, 1.0, 0.0, 1.0 ]));	// vc5
			
			if (page) {
				page.displayTopLeft();
				page.displayTopRight();
			}
			
			if (nextPage && fractional > SMALL) {
				nextPage.displayBottomLeft();
				nextPage.displayBottomRight();
			}
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ Math.max(fractional, 1.0 - fractional, DARKEN), 0.0, 0.0, 0.0 ]) );	// fc0
			if (fractional < 0.5) {
				_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5,
					Vector.<Number>([ 1.0, 1.0 - 2.0 * fractional, 2.0 * fractional, 1.0 ]));	// vc5
				page.displayBottomLeft();
				page.displayBottomRight();
			}
			else if (nextPage) {
				_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5,
					Vector.<Number>([ 1.0, 2.0 * (fractional - 0.5), -(1.0 - 2.0 * (fractional - 0.5)), 1.0 ]));	// vc5
				nextPage.displayTopLeft();
				nextPage.displayTopRight();
			}
			
			_context3D.present();
		}
		
		
		protected function isClickOnComponent():void {
			var fractional:Number = _position - Math.floor(_position);
			if (_container && fractional < SMALL || fractional > 1.0 - SMALL) {
				var page:Sprite = Sprite(_container.pages[Math.round(_position)]);
				_searchHitComponent = UIScrollVertical.searchHit(page);
				if (_searchHitComponent is UISwitch) {
					if (_listenForChange) {
						_listenForChange.removeEventListener(Event.CHANGE, changeHandler);
						_listenForChange = null;
					}
					_listenForChange = UISwitch(_searchHitComponent);
					_listenForChange.addEventListener(Event.CHANGE, changeHandler);
				}
				if (_searchHitComponent) {
					_searchHit = UIScrollVertical.searchHitChild(_searchHitComponent);
				}
			}
			else {
				_searchHit = null;
			}
		}
		
		
		protected function changeHandler(event:Event):void {
			if (_autoUpdateComponents) {
				updatePage(Math.round(_position), _listenForChange);
			}
			_listenForChange.removeEventListener(Event.CHANGE, changeHandler);
			_listenForChange = null;
		//	UI.uiLayer.visible = false;
			_delayedStage3D.reset();
			_delayedStage3D.start();
			_interraction = false;
		}
		
		
		protected function showStage3D(event:TimerEvent):void {
			UI.uiLayer.visible = false;
		}
		
		
		protected function componentClicked():void {
			if (_container && _container is UIPages) {
				UIPages(_container).goToPage(Math.round(_position));
			}
			_searchHit.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			UI.uiLayer.visible = true;
		}
		
		
		override public function destructor():void {
			super.destructor();
			for each (var page:GridPageQuarter in _gridPages) {
				page.destructor();
			}
			removeListeners();
			if (_listenForChange) {
				_listenForChange.removeEventListener(Event.CHANGE, changeHandler);
			}
			_delayedStage3D.removeEventListener(TimerEvent.TIMER, showStage3D);
		}
		
		
		public static const READY:String = "foldingReady";

		protected static var _pageFolding:PageFolding;
		protected static var _pages:UIPages = null;
		protected static var _screenS:Sprite;
		
		public static function create(screen:Sprite, xml:XML, width:Number = -1, height:Number = -1):Sprite {
			_screenS = screen;
			var result:Sprite = UIe.create(screen, xml, width, height);
			screen.addEventListener(Stage3DAcceleration.CONTEXT_COMPLETE, contextComplete);
			Stage3DAcceleration.startStage3D(screen);
			return result;
		}
		
		
		protected static function contextComplete(event:Event):void {
			_screenS.removeEventListener(Stage3DAcceleration.CONTEXT_COMPLETE, contextComplete);
			_pages = UIPages(UI.findViewById("@pages"));
			_pageFolding = new PageFolding();
			_pageFolding.containerPageTextures(_pages);
			_pageFolding.start();
			_screenS.dispatchEvent(new Event(READY));
		}
		
		
		public static function get pageFolding():PageFolding {
			return _pageFolding;
		}
		
		
		public static function get pages():UIPages {
			return _pages;
		}
		

	}
}
