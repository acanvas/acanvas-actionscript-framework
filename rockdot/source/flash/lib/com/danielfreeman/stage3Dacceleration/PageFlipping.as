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
	import com.danielfreeman.madcomponents.IContainerUI;
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UINavigation;
	import com.danielfreeman.madcomponents.UINavigationBar;
	import com.danielfreeman.madcomponents.UIPages;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;

/**
 * This class impliments 3D page flipping capabilities.
 * There are four flipping modes.  MadPages (2D), MadFlow, MadCircle, and MadSwap
 */
	public class PageFlipping extends Stage3DAcceleration {
		
		public static const CLICKED:String = "pageFlippingClicked";
		public static const FINISHED:String = "pageFlippingFinished";

		protected static const TEXTURE_WIDTH:int = 2048;
		protected static const TEXTURE_HEIGHT:int = 2048;
		protected static const TOUCH_MULTIPLIER:Number = 1.5;
		
		protected static const ZOOM_DELTA:Number = 0.2;
		protected static const SPACING:Number = 0.3;
		protected static const POWER:Number = 4;
		protected static const PAUSE:Number = 0.415;
		protected static const TWEEK:Number = 0.3;
		protected static const SIDEWAYS:Number = 0.4;
		
		protected static const GAP:Number = 0.05;
		
		protected static const SKEW:Number = 0.1;
		protected static const EDGE:Number = 0.2;
		protected static const BACK:Number = 1.0;
		protected static const UNIT:Number = 0.6;
		
		protected static const ZOOM:Number = 1.73;
		protected static const FILL:Number = 1.30;
		protected static const BOUNDARY:Number = 1.30;
		
		protected static const MOVE_FACTOR:Number = 2.0;
		protected static const BOUNCE_FACTOR:Number = 0.3;
		protected static const CLICK_THRESHOLD:Number = 32.0;
		protected static const MOVE_THRESHOLD:Number = 0.01;
		protected static const DELTA_THRESHOLD:Number = 0.01;
		protected static const DECAY:Number = 0.99;
		protected static const FASTER_DECAY:Number = 0.60;
		protected static const Y:Number = 0.10;
		protected static const MAXIMUM_TEXTURE:int = 7;
		protected static const DEPTH:Number = 8.0;
		protected static const CIRCLE:Number = 4.0;
		protected static const CIRCULAR_DELTA:Number = 0.005;
		
		protected static const INDICATOR_GAP:Number = 8.0;
		protected static const INDICATOR_SIZE:Number = 8.0;

		
		protected var _textureBitMapData:Vector.<BitmapData> = null;
		protected var _vertices:Vector.<Number>;
		protected var _uv:Vector.<Number>;
		protected var _indices:Vector.<uint>;
		protected var _indexBuffer:IndexBuffer3D;
		protected var _xyzVertexBuffer:VertexBuffer3D;
		protected var _uvVertexBuffer:VertexBuffer3D;

		protected var _pageFlippingVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _pageFlippingFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _pageFlippingShaderProgram:Program3D;
		protected var _pageFlippingTexture:Vector.<Texture>;
		
		protected var _finalMatrix:Matrix3D = new Matrix3D();
		protected var _projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		
		protected var _count:uint = 0;

		protected var _pageWidth:Number;
		protected var _pageHeight:Number;
		protected var _columns:Number;
		protected var _rows:Number;
		
		protected var _position:Number = 0;
		
		protected var _minimumPosition:Number;
		protected var _maximumPosition:Number;
		
		protected var _lastX:Number;
		protected var _deltaX:Number;
		protected var _distanceX:Number;

		protected var _destination:Number;
		protected var _boundary:Number;
		protected var _unit:Number;
		protected var _fillScreen:Vector.<Number>;
		
		protected var _zoomIn:Number = 0.0;
		protected var _zoomDelta:Number;
		protected var _zoomInOnClick:Boolean = false;
		protected var _pageTop:Number;
		protected var _zoomedColour:uint = 0x000000;
		protected var _container:IContainerUI = null;
		protected var _textureUpdate:Vector.<uint> = null;
		
		protected var _circular:Boolean = true;
		protected var _flavour:Function = makePagesMadFlow;
		protected var _index:int = -1;
		protected var _numberOfTextures:int = 0;
		protected var _rowsPerTexture:Number;
		protected var _pagesPerTexture:Number;
		protected var _snapToPage:Boolean = true;
		protected var _enabled:Boolean = false;
		protected var _spin:Boolean = false;
		protected var _circularDelta:Number = CIRCULAR_DELTA;
				
		protected var _pageIndicator:PageIndicator = null;
		
		
		public function PageFlipping() {
			initialise();
		}
		
/**
 * Page snapping, ensures that the current page in centre on the screen
 */
		public function set snapToPage(value:Boolean):void {
			_snapToPage=value;
			if (value) {
				_destination = pageNumberToPosition(pageNumber);
				onEnterFrame(this, destinationMovement);
			}
		}
		
		
		public function get snapToPage():Boolean {
			return _snapToPage;
		}


		protected function textureR(pageNumber:int):int {
			return Math.floor(pageNumber/_pagesPerTexture);
		}

		
		protected function textureX(pageNumber:int):Number {
			return (pageNumber % _columns) * _pageWidth;
		}
		
		
		protected function textureY(pageNumber:int):Number {
			pageNumber = pageNumber % _pagesPerTexture;
			return Math.floor(pageNumber / _columns) * _pageHeight;
		}
		
/**
 * Vertex corners of a 2D page zoomed in
 */
		protected function fillScreen():Vector.<Number> {
			var y:Number = -_pageTop / _screen.stage.stageHeight;
			return Vector.<Number> ([
			//	X,					Y,					Z,
				-FILL*_unit,		y-3*FILL*UNIT,		-0.1,
				FILL*_unit,			y-3*FILL*UNIT,		-0.1,
				FILL*_unit,			y+FILL*UNIT,		-0.1,
				-FILL*_unit,		y+FILL*UNIT,		-0.1
			]);
		}
		
/**
 * Vertex corners of a 2D page at flipping distance
 */
		protected function centrePanel(position:Number = 0, y:Number = 0.1, z:Number = 0):Vector.<Number> {	
			return Vector.<Number> ([
			//	X,						Y,				Z,
				position-_unit,			y-3*UNIT,		z,
				position+_unit,			y-3*UNIT,		z,
				position+_unit,			y+UNIT,			z,
				position-_unit,			y+UNIT,			z
			]);
		}
			
/**
 * Vertex coordinates of MadFlow page to the left of the screen.
 */
		protected function leftMadFlow(position:Number):Vector.<Number> {	
		
			return Vector.<Number> ([
			//	X,						Y,				Z,
				position,				Y-3*UNIT,		EDGE,
				position + SKEW,		Y-3*UNIT,		BACK,
				position + SKEW,		Y+UNIT,			BACK,
				position,				Y+UNIT,			EDGE
			]);
		}

/**
 * Vertex coordinates of MadFlow page to the right of the screen.
 */
		protected function rightMadFlow(position:Number):Vector.<Number> {
		
			return Vector.<Number> ([
			//	X,						Y,				Z,
				position - SKEW,		Y-3*UNIT,		BACK,
				position,				Y-3*UNIT,		EDGE,
				position,				Y+UNIT,			EDGE,
				position - SKEW,		Y+UNIT,			BACK
			]);
		}
		

		protected function get rightBoundary():Number {
			return toGraphX(_screen.stage.stageWidth * (0.5 + _boundary/2));
		}
		
		
		protected function get leftBoundary():Number {
			return toGraphX(_screen.stage.stageWidth * (0.5 - _boundary/2));
		}

/**
 * Calculate a MadFlow page in the centre of the screen
 */
		protected function centreCoverFlow(offset:Number, position:Number, flat:Boolean, zoomIn:Number = 0):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>(); 
			var sideShape:Vector.<Number> = (offset>0) ? rightMadFlow(_boundary-(1-offset)*TWEEK) : leftMadFlow(position);
			var i:int = 0;
			var factor:Number = (Math.abs(offset)<PAUSE || flat) ? 1.0 : Math.pow(1.0-(Math.abs(offset)-PAUSE)/(1.0-PAUSE), POWER);
			var centre:Vector.<Number> = centrePanel(offset*SIDEWAYS);
			for each (var value:Number in centre) {
				result.push(zoomIn*_fillScreen[i]+(1-zoomIn)*(factor*value + (1-factor) * sideShape[i]));
				i++;
			}
			return result;
		}
		
/**
 * Apply a translation matrix
 */
		protected function translationMatrix():void {
			_projectionMatrix.perspectiveFieldOfViewLH(60.0*Math.PI/180, _aspectRatio, 0.1, 1000.0);
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

			_pageFlippingVertexShader.assemble( Context3DProgramType.VERTEX,
				"add vt0, vc4, va0 \n" + // for fast scrolling
				"m44 op, vt0, vc0 \n" +	// vertex
				"mov v0, va1 \n"	// interpolate UVT
			);
			
			_pageFlippingFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"abs ft0.xy, v0.xy \n" +						// |uv|
				"sub ft0.y, fc0.y, ft0.y \n" +					// pageHeight - u
				"mov ft1.xy, ft0.xy \n" +
				"add ft1.y, ft1.y, v0.z \n" +					// add start page position to u
				"tex ft1, ft1.xy, fs0 <2d,linear,nomip> \n" +	// output texture
				"slt ft2.x, v0.y, fc0.z \n" +					// is u < 0 ?
				"mul ft0.y, ft0.y, fc0.x \n" +					// 
				"max ft2.x, ft2.x, ft0.y \n" +
				"mul oc, ft1, ft2.xxxx \n"
			);
			
			_pageFlippingShaderProgram = _context3D.createProgram();
			_pageFlippingShaderProgram.upload( _pageFlippingVertexShader.agalcode, _pageFlippingFragmentShader.agalcode);
		}
		
/**
 * Capture all of the pages within a MadComponents container.  (UIPages, UINavigation, etc.).
 * Notice optional showPageIndicator parameter.  If true, displays a page indicator at the bottom of the screen.
 */
		public function containerPageTextures(container:IContainerUI, showPageIndicator:Boolean = false):void {
			var pages:Vector.<Sprite> = new Vector.<Sprite>();
			for each (var page:Sprite in container.pages) {
				pages.push(page);
			}
			_container = container;
			_pageTop = 0;
			if (container is UINavigation) {
				_zoomedColour = UINavigation(container).navigationBar.colour;
				_pageTop = pages[UIPages(_container).pageNumber].y - UINavigationBar.HEIGHT;
			}
			pageTextures(container.attributes.width, container.attributes.height, pages, showPageIndicator, container.attributes.backgroundColours.length>0 ? container.attributes.backgroundColours[0] : 0xFFFFFF);
		}

/**
 * Capture all of the pages within specified as a Vector of Sprites.
 * Notice optional showPageIndicator parameter.  If true, displays a page indicator at the bottom of the screen.
 */
		public function pageTextures(width:Number, height:Number, pages:Vector.<Sprite>, showPageIndicator:Boolean, backgroundColour:uint = 0xFFFFFF):void {

			var textureWidth:Number;
			var textureHeight:Number;
			
			_pageWidth = width*scale;
			_pageHeight = height*scale;
			
			if (showPageIndicator) {
				_pageIndicator = new PageIndicator(_screen.stage.stageHeight - INDICATOR_GAP * UI.scale, INDICATOR_SIZE * UI.scale, pages.length);
			}
			
			if (_pageWidth * pages.length > TEXTURE_WIDTH / 2) {
				_rowsPerTexture = Math.floor(TEXTURE_HEIGHT / _pageHeight);
				_columns = Math.floor(TEXTURE_WIDTH / _pageWidth);
				_rows = Math.ceil(pages.length / _columns);
				_numberOfTextures = Math.ceil(_rows / _rowsPerTexture);

				if (_numberOfTextures==1) {
					textureWidth = TEXTURE_WIDTH;				
					textureHeight = power2(_rows * _pageHeight);
				}
				else {
					var texturesOnLastPage:Number = pages.length - (_numberOfTextures - 1) * _rowsPerTexture * _columns;
					if (_pageWidth * texturesOnLastPage > TEXTURE_WIDTH / 2) {
						textureWidth = TEXTURE_WIDTH;				
						textureHeight = power2(Math.ceil(texturesOnLastPage / _columns) * _pageHeight);
					}
					else {
						textureWidth = power2(_pageWidth * texturesOnLastPage);
						textureHeight = power2(_pageHeight);
					}
				}
			}
			else {
				textureWidth = power2(_pageWidth * pages.length);
				_columns = pages.length;
				_rowsPerTexture = _rows = 1;
				_numberOfTextures = 1;
				textureHeight = power2(_pageHeight);
			}

			_pagesPerTexture = _rowsPerTexture * _columns;

			if (_textureBitMapData) {
				for each (var bitmapData0:BitmapData in _textureBitMapData) {
					bitmapData0.dispose();
				}
			}

			_textureBitMapData = new Vector.<BitmapData>();
			for (var i:int = 0; i< _numberOfTextures-1; i++) {
				_textureBitMapData.push(new BitmapData(TEXTURE_WIDTH, TEXTURE_HEIGHT, true, backgroundColour));
			}
			_textureBitMapData.push(new BitmapData(textureWidth, textureHeight, true, backgroundColour));

			_boundary = 0.8 * _pageWidth / _pageHeight;
			_unit = UNIT * _pageWidth / _pageHeight;
			_fillScreen = fillScreen();
			_indices = new Vector.<uint>();
			_uv = new Vector.<Number>();
			
			_count = 0;
			for each (var page:Sprite in pages) {
				
				var texWidth:Number = _textureBitMapData[textureR(_count)].width;
				var texHeight:Number = _textureBitMapData[textureR(_count)].height;
				
				_uv.push(
				//	U,											V,							W
					textureX(_count)/texWidth,					_pageHeight/texHeight,		textureY(_count)/texHeight,
					(_pageWidth+textureX(_count))/texWidth,		_pageHeight/texHeight,		textureY(_count)/texHeight,
					(_pageWidth+textureX(_count))/texWidth,		-_pageHeight/texHeight,		textureY(_count)/texHeight,
					textureX(_count)/texWidth,					-_pageHeight/texHeight,		textureY(_count)/texHeight
				);
				
				_indices.push(
					_count*4, _count*4+1, _count*4+2,	_count*4, _count*4+2, _count*4+3
				);

				saveTexture(_textureBitMapData[textureR(_count)], page, new Rectangle(textureX(_count), textureY(_count), _pageWidth, _pageHeight ));

				_count++;
			}
		
			contextResumed(false);
		}
		
/**
 *  Enable page flipping
 */
		override public function enable():void {
			_enabled = true;
			setRegisters();
		//	_context3D.setTextureAt(0, _pageFlippingTexture[0]); //fs0
			make(_position);
			onEnterFrame(this, doNothing);
		}
		
/**
 *  Disable page flipping
 */
		override public function disable():void {
			_enabled = false;
			unSetRegisters();
			removeListeners();
		}
		
/**
 * Restore shaders, streams and textures after context loss.
 */
		override public function contextResumed(running:Boolean):void {

			_pageFlippingShaderProgram = _context3D.createProgram();
			_pageFlippingShaderProgram.upload( _pageFlippingVertexShader.agalcode, _pageFlippingFragmentShader.agalcode);
			
			_xyzVertexBuffer = _context3D.createVertexBuffer(_count * 4, 3);
		//	_xyzVertexBuffer.uploadFromVector(_vertices, 0, _vertices.length / 3);
			
			_uvVertexBuffer = _context3D.createVertexBuffer(_count * 4, 3);
			_uvVertexBuffer.uploadFromVector(_uv, 0, _uv.length/3);
			
			_indexBuffer = _context3D.createIndexBuffer( _indices.length );
			_indexBuffer.uploadFromVector(_indices, 0, _indices.length );
			
			_pageFlippingTexture = new Vector.<Texture>();
			for each (var bitmapData:BitmapData in _textureBitMapData) {
				var texture:Texture = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
				texture.uploadFromBitmapData(bitmapData);
				_pageFlippingTexture.push(texture);
			}
			
			_textureUpdate = null;
			if (running) {
				show();
				onEnterFrame(this, touchMovement);
			}
		}
		
/**
 * Update the appearance of a component on a particular page.
 */
		public function updatePage(pageNumber:int, component:DisplayObject = null):void {
			var page:Sprite = _container.pages[pageNumber];
			var textureIndex:int = textureR(pageNumber);
			
			if (!_textureUpdate) {
				_textureUpdate = new Vector.<uint>();
			}
			
			if (_textureUpdate.indexOf(textureIndex) < 0) {
				_textureUpdate.push(textureIndex);
			}
			
			if (!component) {
				saveTexture(_textureBitMapData[textureIndex], page, new Rectangle(textureX(pageNumber), textureY(pageNumber), _pageWidth, _pageHeight));
			}
			else {
				var globalPoint:Point = component.localToGlobal(new Point(0,0));
				var localPoint:Point = page.globalToLocal(globalPoint);
				saveTexture(_textureBitMapData[textureIndex], page, new Rectangle(textureX(pageNumber) + localPoint.x-1, textureY(pageNumber)+localPoint.y-1, Math.min(_pageWidth - (localPoint.x-1), UI.scale*(component.width+2)), Math.min(_pageHeight - (localPoint.y-1), UI.scale*(component.height+2))), - localPoint.x + 1, - localPoint.y + 1);
			}
		}
		
		
		protected function setRegisters():void {
			_context3D.setVertexBufferAt( 0, _xyzVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va1
			
			if (_numberOfTextures == 1) {
				_context3D.setTextureAt(0, _pageFlippingTexture[0]); //fs0
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 0.3*_textureBitMapData[0].height/_pageHeight, _pageHeight/_textureBitMapData[0].height, 0.0, 1.0 ]) );	// fc0
			}
			updateRegisters();
			_context3D.setProgram(_pageFlippingShaderProgram);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _finalMatrix, true); //vc0 - vc3
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ 0.0, 0.0, 0.0, 0.0 ])); //vc4
		}
		
/**
 * Update textures
 */
		protected function updateRegisters():void {
			if (_textureUpdate) {
				for each (var textureIndex:uint in _textureUpdate) {
					_pageFlippingTexture[textureIndex].uploadFromBitmapData(_textureBitMapData[textureIndex]);
				}
				_textureUpdate = null;
			}
		}
		
		
		protected function unSetRegisters():void {
			_context3D.setVertexBufferAt( 0, null ); //va0
			_context3D.setVertexBufferAt( 1, null ); //va1
			_context3D.setTextureAt(0, null);
		}
		
		
		protected function setPageVertices(i:int, pageVertices:Vector.<Number>):void {
			if (i==0) {  // Assumed this method called in i sequence
				_vertices = new Vector.<Number>();
			}
			_vertices = _vertices.concat(pageVertices);
		}
		
		
		protected function makePages(position:Number, zoomIn:Number = 0):void {
			if (zoomIn == 0) { //faster scrolling
				_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ position, 0.0, 0.0, 0.0 ])); //vc4
			}
			else {
				_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ 0.0, 0.0, 0.0, 0.0 ])); //vc4
				doMakePages(position, zoomIn);
			}
		}
		
/**
 * Calculate the page vertices for MadPages mode.
 */
		protected function doMakePages(position:Number = 0.0, zoomIn:Number = 0.0):void {
			for (var i:int=0; i<_count; i++) {
				var zoom:Number = (i == pageNumber) ? zoomIn : 0.0;
				var result:Vector.<Number> = new Vector.<Number>();
				var panel:Vector.<Number> = centrePanel(position);
				var filled:Vector.<Number> = fillScreen();
				for (var j:int=0; j<12; j++) {
					result.push((1-zoom) * panel[j] + zoom * filled[j]);
				}
				setPageVertices(i, result);
				position += 2 * _unit + GAP;
			}
		}
		
/**
 * Calculate the page vertices for MadCircular mode.
 */
		protected function makePagesMadCircular(position:Number, zoomIn:Number = 0):void {
			var theta:Number = -2 * Math.PI * (position - _minimumPosition)/(_maximumPosition - _minimumPosition);
			
			for (var i:int=0; i<_count; i++) {
				var delta:Number = 2 * Math.PI * i/_count;
				var zoom:Number = (i == _index) ? zoomIn : 0.0;
				var result:Vector.<Number> = new Vector.<Number>();
				var xCentre:Number = 2 * _pageWidth / _pageHeight * Math.sin(theta+delta);
				var yCentre:Number = _circular ? -(CIRCLE + 0.2)*Math.cos(theta+delta) + CIRCLE : Y;
				var zCentre:Number = DEPTH - DEPTH*Math.cos(theta+delta);
				var panel:Vector.<Number> = centrePanel(xCentre, yCentre, zCentre);
				var filled:Vector.<Number> = fillScreen();
				for (var j:int=0; j<12; j++) {
					result.push((1-zoom) * panel[j] + zoom * filled[j]);
				}
				setPageVertices(i, result);
				position += 2 * _unit + GAP;
			}
		}
		
/**
 * Calculate the page vertices for MadFlow mode.
 */
		protected function makePagesMadFlow(position:Number, zoomIn:Number = 0):void {
			var start:Boolean = _position > _minimumPosition;

			for (var i:int=0; i<_count; i++) {
				var zoom:Number = (i == pageNumber) ? zoomIn : 0.0;

				if (start) {
					if (i==0) {
						setPageVertices(i, centreCoverFlow((position - leftBoundary) / SPACING - 1, position, true, zoom));
						position += 2 * _boundary - SPACING;
					}
					else {
						setPageVertices(i, rightMadFlow(position));
						position += SPACING;
					}
				}
				else if (position <= leftBoundary && i<_count-1) {
					setPageVertices(i, leftMadFlow(position));
					position += SPACING;
				}
				else if (position >= rightBoundary) {
					setPageVertices(i, rightMadFlow(position));
					position += SPACING;
				}
				else if (position < 0) {
					var rotation:Number = (position - leftBoundary) / SPACING - 1;
					setPageVertices(i, centreCoverFlow(rotation, position, i==_count-1 && rotation<0, zoom));
					position = position - leftBoundary;
				}
				else if (position > 0) {
					setPageVertices(i, centreCoverFlow(position / SPACING, position, false, zoom));
					position = rightBoundary + position;
				}
				
			}
		}
		
/**
 * Calculate the maximum and minimum scroll positions.
 */
		protected function maximumAndMinimum():void {
			if (_flavour == makePagesMadCircular) {
				_minimumPosition = 0;
				_maximumPosition = -_count * ( 2 *_unit + GAP );
			}
			else {
				_minimumPosition = pageNumberToPosition(0);
				_maximumPosition = pageNumberToPosition(_count - 1);
			}
		}
		
/**
 * Calculate page vertices and render.
 */
		protected function make(position:Number, zoomIn:Number = 0):void {
			maximumAndMinimum();
			_flavour(position, zoomIn);
			_xyzVertexBuffer.uploadFromVector(_vertices, 0, _vertices.length / 3);
			drawPages();
		}
		
/**
 *  x coordinate of a paricular page.
 */
		protected function pageNumberToPosition(value:int):Number {
			if (_flavour == makePagesMadFlow) {
				return leftBoundary - (value - 1.0) * SPACING;
			}
			else {
				return - value * ( 2 *_unit + GAP );
			}
		}
		
/**
 * Return the page number for a particular Stage3D x-coordinate.
 */
		protected function positionToPageNumber(value:Number):int {//MadPages, not MadFlow
			var result:int = Math.round((value-_position)/(2*_unit+GAP));
			return (result < 0) ? 0 : ((result > _count-1) ? _count-1 : result);
		}
		
/**
 * Correct the scroll position for MadCircular mode
 */
		protected function correctCircularPosition():void {
			var normalisedPosition:Number = (_position - _minimumPosition)/(_maximumPosition - _minimumPosition);
			if (normalisedPosition < 0.0) {
				normalisedPosition = normalisedPosition + Math.ceil(-normalisedPosition);
			}
			else if (normalisedPosition>1.0) {
				normalisedPosition = normalisedPosition - Math.floor(normalisedPosition);
			}
			_position = normalisedPosition * (_maximumPosition - _minimumPosition) + _minimumPosition;
		}
		
/**
 * The current foreground page index
 */
		public function get pageNumber():int {
			var result:int;
			
			if (_flavour == makePagesMadFlow) {
				result = Math.floor(1.5 + (leftBoundary - _position) / SPACING);
			}
			else if (_flavour == makePages) {
				result = (_unit - _position) / ( 2 *_unit + GAP );
			}
			else {
				result = Math.round(_count * (_position - _minimumPosition)/(_maximumPosition - _minimumPosition));
			}
			return (result < 0) ? 0 : ((result > _count-1) ? _count-1 : result);
		}

/**
 * The current foreground page index.  MadCircular mode.
 */
		protected function get circularPageNumber():int {
			if (_flavour == makePagesMadCircular) {
				return Math.round(_count * (_position - _minimumPosition)/(_maximumPosition - _minimumPosition));
			}
			else {
				return pageNumber;
			}
		}

/**
 * Set the current foreground page index
 */
		public function set pageNumber(value:int):void {
			_index = value;
			_position = pageNumberToPosition(value);
			make(_position);
		}

/**
 * Render the pages
 */
		protected function drawPages():void {
			_context3D.clear(_zoomIn*(_zoomedColour>>32 & 0xff)/0xff, _zoomIn*(_zoomedColour>>16 & 0xff)/0xff, _zoomIn*(_zoomedColour & 0xff)/0xff);
			if (_numberOfTextures == 1) {
				_context3D.drawTriangles(_indexBuffer);
			}
			else if (_flavour == makePagesMadCircular) {
				for (var j:int = 0; j < _count; j++) {
					_context3D.setTextureAt(0, _pageFlippingTexture[textureR(j)]); //fs0
					_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 0.3*_textureBitMapData[textureR(j)].height/_pageHeight, _pageHeight/_textureBitMapData[textureR(j)].height, 0.0, 1.0 ]) );	// fc0
					_context3D.drawTriangles(_indexBuffer, 6 * j, 2);
				}
			}
			else {
				var midQuad:int = pageNumber;
				var firstQuad:int;
				var lastQuad:int;
				if (_flavour == makePagesMadFlow) {
					var eitherSide:int = Math.ceil((_aspectRatio - _unit/BOUNDARY)/SPACING);
					firstQuad = Math.max(0, midQuad - eitherSide);
					lastQuad = Math.min(_count, midQuad + eitherSide);
				}
				else {
					firstQuad = positionToPageNumber(-_aspectRatio);
					lastQuad = Math.min(_count, positionToPageNumber(+_aspectRatio) + 1);
				}
				var firstTexture:int = Math.floor(firstQuad/_pagesPerTexture);
				var lastTexture:int = Math.ceil(lastQuad/_pagesPerTexture);
				for (var i:int = firstTexture; i <= lastTexture; i++) {
					_context3D.setTextureAt(0, _pageFlippingTexture[i]); //fs0
					_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 0.3*_textureBitMapData[i].height/_pageHeight, _pageHeight/_textureBitMapData[i].height, 0.0, 1.0 ]) );	// fc0
					
					var firstQuadForTexture:int = Math.max(firstQuad, i * _pagesPerTexture);
					var lastQuadForTexture:int = Math.min(lastQuad, (i+1) * _pagesPerTexture);
					_context3D.drawTriangles(_indexBuffer, 6 * firstQuadForTexture, 2 * (lastQuadForTexture - firstQuadForTexture));
				}
			}
			if (_pageIndicator) {
				drawPageIndicator();
			}
			_context3D.present();
		}
		
/**
 * Render the page indicator
 */
		protected function drawPageIndicator():void {
			_context3D.setTextureAt(0, null); //fs0
			_pageIndicator.display(circularPageNumber % _count);
			setRegisters();
		}
		
/**
 * Activate MadPages mode.  (No zooming transition animation into this mode)
 */
		public function madPages(zoomInOnClick:Boolean = false):void {
			_flavour = makePages;
			doMakePages();
			_zoomInOnClick = zoomInOnClick;
			show();
		}
		
/**
 * Activate MadFlow mode.  (No zooming transition animation into this mode)
 */
		public function madFlow(zoomInOnClick:Boolean = false):void {
			_flavour = makePagesMadFlow;
			_zoomInOnClick = zoomInOnClick;
			show();
		}
		
/**
 * Activate MadSwap mode.  (No zooming transition animation into this mode)
 */
		public function madSwap(zoomInOnClick:Boolean = false, spin:Boolean = false):void {
			_flavour = makePagesMadCircular;
			_circular = false;
			_spin = spin;
			_zoomInOnClick = zoomInOnClick;
			show();
		}
		
/**
 * Activate MadCircular mode.  (No zooming transition animation into this mode)
 */
		public function madCircular(zoomInOnClick:Boolean = false, spin:Boolean = false):void {
			_flavour = makePagesMadCircular;
			_circular = true;
			_spin = spin;
			_zoomInOnClick = zoomInOnClick;
			show();
		}
		
		
		protected function show():void {
			setRegisters();
			_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_screen.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_flavour(_position);
		}
		
/**
 * Zooming transition animation into a flipping mode
 */
		protected function zoomOut(zoomInOnClick:Boolean = false):void {
			activate(this);
			updateRegisters();
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ 0.0, 0.0, 0.0, 0.0 ])); //vc4
			_zoomInOnClick = zoomInOnClick;
			UI.uiLayer.visible = false;
			if (_container is UIPages) {
				pageNumber = UIPages(_container).pageNumber;
			}
			_zoomIn = 1.0;
			_zoomDelta = -ZOOM_DELTA;
			removeListeners();
			onEnterFrame(this, zoomInMovement);
		}
		
/**
 * Activate MadPages mode.  (With zooming transition animation)
 */
		public function zoomOutToMadPages(zoomInOnClick:Boolean = false):void {
			_flavour = makePages;
			doMakePages();
			zoomOut(zoomInOnClick);
		}
		
/**
 * Activate MadFlow mode.  (With zooming transition animation)
 */
		public function zoomOutToMadFlow(zoomInOnClick:Boolean = false):void {
			_flavour = makePagesMadFlow;
			zoomOut(zoomInOnClick);
		}
		
/**
 * Activate MadCircular mode.  (With zooming transition animation)
 */
		public function zoomOutToMadCircular(zoomInOnClick:Boolean = false, spin:Boolean = false):void {
			_flavour = makePagesMadCircular;
			_circular = true;
			_spin = spin;
			zoomOut(zoomInOnClick);
		}
		
/**
 * Activate MadSwap mode.  (With zooming transition animation)
 */
		public function zoomOutToMadSwap(zoomInOnClick:Boolean = false, spin:Boolean = false):void {
			_flavour = makePagesMadCircular;
			_circular = false;
			_spin = spin;
			zoomOut(zoomInOnClick);
		}
		
/**
 * A zoom-in transition animation back to conventional MadComponents forms
 */
		public function zoomInToPage():void {
			if (_container is UIPages) {
				UIPages(_container).pageNumber = (_flavour != makePagesMadFlow) ? _index : pageNumber;
			}
			if (_container is UINavigation) {
				UINavigation(_container).navigationBar.backButton.visible = false;
			} 
			_zoomDelta = ZOOM_DELTA;
			_zoomIn = 0.0;
			setRegisters();
			removeListeners();
			onEnterFrame(this, zoomInMovement);
		}
				
		
		protected function mouseDown(event:MouseEvent):void {
			_screen.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_lastX = _screen.stage.mouseX;
			_distanceX = 0;
			_deltaX = 0;
			onEnterFrame(this, touchMovement);
		}
		
		
		protected function click():void {
			if (_flavour != makePagesMadFlow) {
				_index = circularPageNumber % _count;
				_screen.dispatchEvent(new Event(CLICKED));
			}
			if (_zoomInOnClick) {
				_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				zoomInToPage();
			}
		}


		protected function mouseUp(event:MouseEvent):void {
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			if (_distanceX < CLICK_THRESHOLD) {
				click();
			}
			else {
				onEnterFrame(this, inertiaMovement);
			}
		}

		
		public function get spinHandler():Function {
			return ((_flavour == makePagesMadCircular) && _spin) ? circularMovement : null;
		}
		
/**
 * Respond to swipes to scroll the pages
 */
		protected function touchMovement(event:Event):void {
			var delta:Number = TOUCH_MULTIPLIER * (_screen.stage.mouseX - _lastX);
			_distanceX += Math.abs(delta);
			_deltaX = MOVE_FACTOR * delta / _screen.stage.stageWidth;
			_lastX = _screen.stage.mouseX;
			_position += _deltaX;
			if (_flavour == makePagesMadCircular) {
				_circularDelta = (delta<-1.0 ? -CIRCULAR_DELTA : (delta>1.0 ? CIRCULAR_DELTA : _circularDelta));
				correctCircularPosition();
			}
			make(_position);
		}
			
/**
 * Scroll to a particular position
 */
		protected function destinationMovement(event:Event):void {
			var distance:Number = _destination - _position;
			if (Math.abs(distance) < MOVE_THRESHOLD) {
				_position = _destination;
				onEnterFrame(this);
			}
			else {
				_position += distance * BOUNCE_FACTOR ;
			}
			make(_position);
		}			
		
/**
 * MadCircle scrolling
 */
		protected function circularMovement(event:Event):void {
			_position += _circularDelta;
			correctCircularPosition();
			make(_position);
		}
			
/**
 * The user has swiped the screen, and removed their finger.  The scrolling motion has momentum,
 */
		protected function inertiaMovement(event:Event):void {
			_position += _deltaX;
			_deltaX *= (_position > _minimumPosition || _position < _maximumPosition) ? FASTER_DECAY : DECAY;
			if (Math.abs(_deltaX) < DELTA_THRESHOLD) {
				if (_position > _minimumPosition) {
					_destination = _minimumPosition;
					onEnterFrame(this, destinationMovement);
				}
				else if (_position < _maximumPosition) {
					_destination = _maximumPosition;
					onEnterFrame(this, destinationMovement);
				}
				else if (_snapToPage && !_spin) {
					_destination = pageNumberToPosition(circularPageNumber);
					onEnterFrame(this, destinationMovement);
				}
				else {
					onEnterFrame(this, spinHandler);
				}
			}
			make(_position);
		}
		
/**
 * Keep rendering.  Ensure Display list graphics don't freeze up.  On mobile, two two are synched.
 */
		protected function doNothing(event:Event):void {
			_context3D.clear(_zoomIn*(_zoomedColour>>32 & 0xff)/0xff, _zoomIn*(_zoomedColour>>16 & 0xff)/0xff, _zoomIn*(_zoomedColour & 0xff)/0xff);
			_context3D.drawTriangles(_indexBuffer, 0, 0);
			_context3D.present();
		}
		
/**
 * Animate zoom transition
 */
		protected function zoomInMovement(event:Event):void {
			_zoomIn += _zoomDelta;
			if (!_enabled) {
				make(_position, 1.0);
				deactivate(this);
			}
			else if (_zoomIn >= 1.0) {
				zoomInComplete();
			}
			else if (_zoomIn <= 0) {
				zoomOutComplete();
			}
			else {
				make(_position, _zoomIn);
			}
		}
				
/**
 * Zoom-Out transition complete
 */
		protected function zoomOutComplete():void {
			_zoomIn = 0.0;
			if (_flavour == makePages) {
				doMakePages();
				_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ 0.0, 0.0, 0.0, 0.0 ])); //vc4
			}
			onEnterFrame(this);
			show();
		}
		
/**
 * Zoom-In transition complete
 */
		protected function zoomInComplete():void {
			_zoomIn = 1.0;
			UI.uiLayer.visible = true;
			make(_position, _zoomIn);
			_screen.dispatchEvent(new Event(FINISHED));
			_enabled = false;
		}
		
		
		protected function removeListeners():void {
			_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		
		override public function destructor():void {
			super.destructor();
			for each (var bitmapData:BitmapData in _textureBitMapData) {
				bitmapData.dispose();
			}
		}

	}
}
