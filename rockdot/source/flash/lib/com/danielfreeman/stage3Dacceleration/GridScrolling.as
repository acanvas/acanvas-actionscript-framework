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
	import com.danielfreeman.madcomponents.Attributes;
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UIForm;

	import flash.display.BitmapData;
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
	import flash.geom.Vector3D;

/**
 * A scrolling grid of panels inspired by Windows-8 Touch
 */
	public class GridScrolling extends Stage3DAcceleration {
		
		public static const CLICKED:String = "gridScrollingClicked";
		
		protected static const CELL_WIDTH:Number = 256.0;
		protected static const CELL_HEIGHT:Number = 256.0;
		protected static const GAP:Number = 10.0;
		protected static const ZOOM:Number = 1.1;
		protected static const RECESSED:Number = 1.3;
		protected static const SIDE_GAP:Number = CELL_WIDTH/8;
		protected static const TOP_GAP:Number = CELL_HEIGHT/4;
		protected static const CLICK_THRESHOLD:Number = 32.0;
		protected static const DECAY:Number = 0.99;
		protected static const FASTER_DECAY:Number = 0.60;
		protected static const DELTA_THRESHOLD:Number = 0.1;
		protected static const MOVE_THRESHOLD:Number = 0.01;
		protected static const BOUNCE_FACTOR:Number = 0.3;
		protected static const TOUCH_MULTIPLIER:Number = 1.0;
		protected static const MOVE_FACTOR:Number = 2.0;
		protected static const ANIMATION_FRAMES:Number = 2.0;
		protected static const STAGGER:int = 4;
		protected static const ANIMATION:int = 16;
		protected static const INITIAL_ROTATION:Number = 90;
		protected static const QUALITY_SCALE:Number = 0.5;


		protected var _textureBitMapData:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		protected var _indexBuffer:IndexBuffer3D;
		protected var _xyzVertexBuffer:VertexBuffer3D;
		protected var _uvVertexBuffer:VertexBuffer3D;

		protected var _tiledVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _tiledFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _tiledShaderProgram:Program3D;
		
		protected var _tiledTexture:Vector.<Texture> = new Vector.<Texture>();
		
		protected var _backgroundColour:uint = 0x000000;
		protected var _cellWidth:Number = CELL_WIDTH;
		protected var _cellHeight:Number = CELL_HEIGHT;
		
		protected var _finalMatrix:Matrix3D = new Matrix3D();
		protected var _secondMatrix:Matrix3D = new Matrix3D();
		protected var _projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		protected var _count:int = 0;
		protected var _scale:Number = 1.0;
		protected var _position:Number = 0.0;
		protected var _distanceX:Number;
		protected var _lastX:Number;
		protected var _mouseDown:Boolean;
		protected var _deltaX:Number;
		protected var _minimumPosition:Number = 0;
		protected var _maximumPosition:Number = 0;
		protected var _destination:Number;
		protected var _animationInitial:Vector.<int> = new Vector.<int>();
		protected var _animation:Vector.<int>;
		
		protected var _vertices:Vector.<Number> = new Vector.<Number>();
		protected var _uv:Vector.<Number> = new Vector.<Number>();
		protected var _indices:Vector.<uint> = new Vector.<uint>();
		
		protected var _topGap:Number;
		protected var _sideGap:Number;
		protected var _screenEdge:Point;
		protected var _widthIndices:int;
		protected var _heightIndices:int;
		protected var _indexPoint:Point = null;
		protected var _arrayIndex:int = -1;
		protected var _gridPositionToArrayIndex:Vector.<Vector.<int>>;
		protected var _cellSize:Vector.<Point>;
		protected var _start:Boolean = false;
		
		protected var _zoomInOnClick:Boolean = false;
		protected var _finish:Boolean = false;
		protected var _gridPageWidth:int;
		protected var _snapToPage:Boolean = false;
		protected var _enabled:Boolean = false;
		protected var _moving:int;


		public function GridScrolling() {
			initialise();
		}
		
		
		public function setCellSize(width:Number, height:Number):void {
			_cellWidth = width;
			_cellHeight = height;
		}
		
/**
 * Translation matrix.  Scaling and Perspective.
 */
		protected function translationMatrix():void {
			_finalMatrix.identity();
			_finalMatrix.appendTranslation(0, 0, ZOOM);
			_finalMatrix.appendScale(_scale, _scale, 1.0);
			_finalMatrix.append(_projectionMatrix);
		}
		
/**
 * Second transformation matrix that defines the initial transition, and pressed state.
 */
		protected function secondTranslationMatrix(rotationDegrees:Number = 0.0):void {
			_secondMatrix.identity();
			_secondMatrix.appendRotation(rotationDegrees, Vector3D.Y_AXIS);
			_secondMatrix.appendTranslation(0, 0, RECESSED);
			_secondMatrix.appendScale(_scale, _scale, 1.0);
			_secondMatrix.append(_projectionMatrix);
		}
		
/**
 * The vertex shader is designed to transform each vertex by both transformation matrices,
 * then linear interpolation to animate between the two positions.
 * 
 * The fragment shader is a standard simple texture shader.
 */
		public function initialise():void {
			
			_tiledVertexShader.assemble( Context3DProgramType.VERTEX,
				"add vt0, va0, vc8.zwww \n" +	// scroll
				"m44 vt1, vt0, vc0 \n" +		// vertex0
				"m44 vt2, vt0, vc4 \n" +		// vertex1
				"mul vt1, vt1, vc8.xxxx \n" +
				"mul vt2, vt2, vc8.yyyy \n" +
				"add op, vt1, vt2 \n" +
				"mov v0, va1 \n"				// interpolate UV
			);
			
			_tiledFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"tex oc, v0.xy, fs0 <2d,linear,nomip> \n" 	// output texture
			);
			
			_tiledShaderProgram = _context3D.createProgram();
			_tiledShaderProgram.upload( _tiledVertexShader.agalcode, _tiledFragmentShader.agalcode);

			_projectionMatrix.perspectiveFieldOfViewLH(60.0*Math.PI/180, _aspectRatio, 0.1, 1000.0);
			translationMatrix();
		}
		
/**
 * Estimate the maximum and minimum x-coordinates at a particular depth.
 * A rough estimation - not accurate, but adequate for some calculations.
 */
		protected function screenRangeAtDepth(depth:Number):Point {
			var pointInSpace:Vector3D = _finalMatrix.transformVector(new Vector3D(1.0, 1.0, depth, 1.0));
			return new Point(pointInSpace.w/pointInSpace.x, pointInSpace.w/pointInSpace.y);
		}
		
/**
 * From stage coordinates to grid row and column
 */
		protected function toGridIndices(value:Vector3D):Point {
			var inverseTransform:Matrix3D = _finalMatrix.clone();
			inverseTransform.invert();
			var pointInSpace:Vector3D = inverseTransform.transformVector(value);
			var xx:Number = pointInSpace.x - _position/_scale - _sideGap + _screenEdge.x;
			
			pointInSpace.x = _screen.stage.stageWidth*xx/_aspectRatio;
			pointInSpace.y = -_screen.stage.stageHeight*(pointInSpace.y + _topGap - _screenEdge.y);
			
			if (_gridPageWidth>0) {
				var page:int = Math.floor((value.x-_position + 1) / (_scale * 2*_screenEdge.x));
				pointInSpace.x = pointInSpace.x - page * 2 * _sideGap * _screen.stage.stageWidth / (_aspectRatio);
			}
			
			var i:int = Math.floor(pointInSpace.x/(_cellWidth+GAP/2)); 
			var j:int = _heightIndices - Math.floor(pointInSpace.y/(_cellHeight+GAP/2))-1;

			if (i < 0) {
				i=0;
			}
			else if (i > _widthIndices - 1) {
				i = _widthIndices - 1;
			}

			if (j < 0) {
				j = 0;
			}
			else if (j > _heightIndices - 1) {
				j = _heightIndices - 1;
			}

			return new Point(i, j);
		}

/**
 * Set background colour
 */
		public function set backgroundColour(value:uint):void {
			_backgroundColour = value;
		}
		
/**
 * Insert a column of empty grid cells.
 * On some screen resolutions/density, If a grid pages can't fit onto a screen, this is how we seperate it into pages.
 */
		protected function insertNulls(grid:Vector.<Vector.<XML>>, gridPageWidth:int):void {
			for each (var row:Vector.<XML> in grid) {
				for (var i:int = 1; i< Math.floor(row.length/gridPageWidth); i++) {
					row.splice(i*gridPageWidth+(i-1), 0, null);
				}
			}
		}
		
/**
 * Define the grid interface with a 2D vector of MadComponents Layout XML.
 */
		public function defineGrid(grid:Vector.<Vector.<XML>>, gridPageWidth:int = 0):void {
			_gridPageWidth = gridPageWidth;
			translationMatrix();
			_screenEdge = screenRangeAtDepth(0.0);
			var gridHeight:Number = (_cellHeight + (grid.length-1)*(_cellHeight + GAP))/(2 * _screen.stage.stageHeight);
			_topGap = _screenEdge.y - gridHeight;
			if (_topGap < 0) {
				_scale = (_screenEdge.y-TOP_GAP/_screen.stage.stageHeight)/gridHeight;
				_scale = (_screenEdge.y-_scale*TOP_GAP/_screen.stage.stageHeight)/gridHeight; // two pass
				translationMatrix();
				_screenEdge = screenRangeAtDepth(0.0);
				_topGap = _screenEdge.y - gridHeight;
			}

			var gridWidth:Number = _aspectRatio*(_cellWidth + (grid[0].length-1)*(_cellWidth + GAP))/(2 * _screen.stage.stageWidth);
			_sideGap = _screenEdge.x - gridWidth;
			
			if (gridPageWidth > 0) {
				var pageWidth:Number = _aspectRatio*(_cellWidth + (gridPageWidth-1)*(_cellWidth + GAP))/(2 * _screen.stage.stageWidth);
				_sideGap = _screenEdge.x - pageWidth;
				var gapsBetweenPages:Number = (Math.ceil(grid[0].length / gridPageWidth)-1) * _sideGap;
				_maximumPosition = -2 * _scale * ((gridWidth - pageWidth) + gapsBetweenPages);
				_snapToPage = true;
			}
			if (_sideGap < 0) {
				if (_snapToPage) { // We have pages, but page width longer than screen width
					_snapToPage = false;
					_gridPageWidth = 0;
					insertNulls(grid, gridPageWidth);
					gridWidth = _aspectRatio*(_cellWidth + (grid[0].length-1)*(_cellWidth + GAP))/(2 * _screen.stage.stageWidth);
				}
				_maximumPosition = 2 * _scale * (_screenEdge.x - gridWidth) - 2 * SIDE_GAP/_screen.stage.stageWidth;
				_sideGap = SIDE_GAP/_screen.stage.stageWidth;
			}
			
			_widthIndices = grid[0].length;
			_heightIndices = grid.length;
			
			_gridPositionToArrayIndex = new Vector.<Vector.<int>>();
			_cellSize = new Vector.<Point>();
			
			for (var j0:int = 0; j0 < grid.length ; j0++) {
				var row:Vector.<int> = new Vector.<int>();
				for (var i0:int = 0; i0 < grid[j0].length ; i0++) {
					row.push(-1);
				}
				_gridPositionToArrayIndex.push(row);
			}
			
			for (var j:int = 0; j < grid.length ; j++) {
				
				for (var i:int = 0; i < grid[j].length ; i++) {
					var cellWidth:Number = _cellWidth;
					var cellHeight:Number = _cellHeight;
					var item:XML = grid[j][i];
					var pageOffset:Number = (_gridPageWidth>0) ? Math.floor(i / _gridPageWidth) * 2 * _sideGap : 0;

					if (item) {
						if (item.@tile.length()>0) {
							var tileSize:Array = String(item.@tile).split("x");
							cellWidth = _cellWidth + (tileSize[0]-1)*(_cellWidth + GAP);
							cellHeight = _cellHeight + (tileSize[1]-1)*(_cellHeight + GAP);
							
							for (var jj:int = 0; jj < tileSize[0] ; jj++) {
								for (var ii:int = 0; ii < tileSize[1] ; ii++) {
									_gridPositionToArrayIndex[j+jj][i+ii] = _count;
								}
							}
						}
						else {
							_gridPositionToArrayIndex[j][i] = _count;
						}

						var x:Number = pageOffset - _screenEdge.x + (_aspectRatio*i*(_cellWidth + GAP))/_screen.stage.stageWidth + _sideGap;
						var y:Number = _screenEdge.y-j*(_cellHeight + GAP)/_screen.stage.stageHeight - _topGap;
						var madRendered:UIForm = new UIForm(new Sprite(), item, new Attributes(0, 0, cellWidth, cellHeight));
						var bitmapData:BitmapData = new BitmapData(power2(QUALITY_SCALE*cellWidth*UI.scale), power2(QUALITY_SCALE*cellHeight*UI.scale));
						_cellSize.push(new Point(cellWidth*UI.scale, cellHeight*UI.scale));
						
						saveTexture(bitmapData, madRendered, new Rectangle(0, 0, QUALITY_SCALE*cellWidth*UI.scale, QUALITY_SCALE*cellHeight*UI.scale), 0, 0, QUALITY_SCALE);
						var texture:Texture = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
						texture.uploadFromBitmapData(bitmapData);
						
						_tiledTexture.push(texture);
						_textureBitMapData.push(bitmapData);
						
						var quadWidth:Number = cellWidth/_screen.stage.stageWidth;
						var quadHeight:Number = cellHeight/_screen.stage.stageHeight;
						_vertices.push(
							//	X,						Y,				Z,
							x,							y-quadHeight,				0,
							x+_aspectRatio*quadWidth,	y-quadHeight,				0,
							x+_aspectRatio*quadWidth,	y,	0,
							x,							y,	0
						);

						var u:Number = UI.scale*cellWidth*QUALITY_SCALE/bitmapData.width;
						var v:Number = UI.scale*cellHeight*QUALITY_SCALE/bitmapData.height;
						_uv.push(
							0, 		v,
							u,		v,
							u,		0,
							0,		0
						);
						
						_indices.push(
							4*_count, 4*_count+1, 4*_count+2,	4*_count, 4*_count+2, 4*_count+3
						);
						
						_animationInitial.push((x > _screenEdge.x) ? ANIMATION : (-i*STAGGER));
						_count++;
					}
				}
			}
				
			contextResumed(false);
		}
		
/**
 * Restore shaders, streams and textures after context loss.
 */
		override public function contextResumed(running:Boolean):void {

			_tiledShaderProgram = _context3D.createProgram();
			_tiledShaderProgram.upload( _tiledVertexShader.agalcode, _tiledFragmentShader.agalcode);
			
			_xyzVertexBuffer = _context3D.createVertexBuffer(_count * 4, 3);
			_xyzVertexBuffer.uploadFromVector(_vertices, 0, _vertices.length / 3);
			
			_uvVertexBuffer = _context3D.createVertexBuffer(_uv.length/2, 2);
			_uvVertexBuffer.uploadFromVector(_uv, 0, _uv.length/2);
			
			_indexBuffer = _context3D.createIndexBuffer( _indices.length );
			_indexBuffer.uploadFromVector(_indices, 0, _indices.length );
			_tiledTexture = new Vector.<Texture>();
			for each (var bitmapData:BitmapData in _textureBitMapData) {
				var texture:Texture = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
				texture.uploadFromBitmapData(bitmapData);
				_tiledTexture.push(texture);
			}
			if (running) {
				enable();
				onEnterFrame(this, drawTiles);
			}
		}
		
		
/**
 * Replace a tile texture.
 */
		public function replaceTileTexture(row:int, column:int, layout:XML):void {
			var index:uint = _gridPositionToArrayIndex[column][row];
			var cellSize:Point = _cellSize[index];
			var bitmapData:BitmapData = _textureBitMapData[index];
			
			var madRendered:UIForm = new UIForm(new Sprite(), layout, new Attributes(0, 0, cellSize.x/UI.scale, cellSize.y/UI.scale));
			saveTexture(bitmapData, madRendered, new Rectangle(0, 0, cellSize.x, cellSize.y), 0, 0, QUALITY_SCALE);
			_tiledTexture[index].uploadFromBitmapData(bitmapData);
		}
		
/**
 * Start grid UI.  If zoomInOnClick is true, clicking on a grid square will take you back to display list view
 */
		public function start(zoomInOnClick:Boolean = false, alt:Boolean = false):void {
			_zoomInOnClick = zoomInOnClick;
			_start = true;
			_animation = _animationInitial.concat();
			_position = 0;
			secondTranslationMatrix(alt ? 0 : INITIAL_ROTATION);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _secondMatrix, true); //vc4 - vc7
			activate(this);
			onEnterFrame(this, drawTiles);
			if (UI.uiLayer) {
				UI.uiLayer.visible = false;
			}
			if (UI.windowLayer) {
				UI.windowLayer.visible = false;
			}
		}
		
/**
 * Stop grid UI.
 */
		public function stop():void {
			_enabled = false;
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			if (UI.windowLayer) {
				UI.windowLayer.visible = true;
			}
		}
		
		
		override public function enable():void {
			_enabled = true;
			_context3D.setVertexBufferAt( 0, _xyzVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			_context3D.setProgram(_tiledShaderProgram);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _finalMatrix, true); //vc0 - vc3
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _secondMatrix, true); //vc4 - vc7

		}
		
		
		override public function disable():void {
			_enabled = false;
			_context3D.setVertexBufferAt( 0, null ); //va0
			_context3D.setVertexBufferAt( 1, null ); //va1
			_context3D.setTextureAt(0, null);
		}
		
		
		protected function makeInteractive():void {
			secondTranslationMatrix();
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _secondMatrix, true); //vc4 - vc7
			_screen.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		
		public function finish():void {
			_finish = true;
		}

		
		protected function doTheDrawForTile(index:int):void {
			var frame:int = _animation[index];
			if (frame < 0) {
				_animation[index]++;
				_moving++;
			}
			else {
				_context3D.setTextureAt(0, _tiledTexture[index]); //fs0
				if (frame < ANIMATION) {
					_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, Vector.<Number>([ frame/ANIMATION, (1.0 - frame/ANIMATION), _position/_scale, 0.0 ]) );	// fc4
					_animation[index]++;
					_moving++;
				}
				else {
					_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, Vector.<Number>([ 1.0, 0.0, _position/_scale, 0.0 ]) );	// fc4
					}
				_context3D.drawTriangles(_indexBuffer, 6 * index, 2);
			}
		}
		
/**
 * Render the grid
 */
		protected function doTheDraw(present:Boolean = true):void {
			_moving = 0;
			_context3D.clear((_backgroundColour>>32 & 0xff)/0xff, (_backgroundColour>>16 & 0xff)/0xff, (_backgroundColour & 0xff)/0xff);
			for (var j:int = 0; j < _count; j++) {
				doTheDrawForTile(j);
			}

			if (present) {
				_context3D.present();
			}

			if (!_enabled) {
				deactivate(this);
			}
			else if (_moving == 0 && _start) {
				_start = false;
				makeInteractive();
			}
			else if (_moving == 0 && _finish) {
				_finish = false;
				stop();
			}

		}
		
/**
 * Horizontal scroll in response to touch swipe
 */
		protected function drawTiles(event:Event):void {
			if (_mouseDown) {
				var delta:Number = TOUCH_MULTIPLIER * (_screen.stage.mouseX - _lastX);
				_distanceX += Math.abs(delta);
				_deltaX = MOVE_FACTOR * delta / _screen.stage.stageWidth;
				_lastX = _screen.stage.mouseX;
				_position += _deltaX;
			}
			doTheDraw();
		}
		
/**
 * Mouse down handler
 */
		protected function mouseDown(event:MouseEvent):void {
			_mouseDown = true;
			_screen.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_lastX = _screen.stage.mouseX;
			_distanceX = 0;
			onEnterFrame(this, drawTiles);
		}
		
/**
 * Mouse up handler
 */
		protected function mouseUp(event:MouseEvent):void {
			_mouseDown = false;
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			if (_distanceX < CLICK_THRESHOLD) {
				click();
			}
			else {
				onEnterFrame(this, inertiaMovement);
			}
		}

/**
 * Click handler
 */
		protected function click():void {
			var indices:Point = toGridIndices(new Vector3D(toGraphX(_screen.stage.mouseX), toGraphY(_screen.stage.mouseY)));
			var arrayIndex:int = _gridPositionToArrayIndex[indices.y][indices.x];
			if (arrayIndex >= 0) {
				_indexPoint = indices;
				_arrayIndex = arrayIndex;
				_animation[_arrayIndex] = 0;
				_finish = _zoomInOnClick;
				_screen.dispatchEvent(new Event(CLICKED));
			}
		}
		
/**
 * Row and column of last grid cell clicked
 */
		public function get gridIndices():Point {
			return _indexPoint;
		}
		
/**
 * Array index of last grid cell clicked
 */
		public function get arrayIndex():int {
			return _arrayIndex;
		}
		
		
		protected function positionToPageStart():Number {
			return - _scale * 2 * _screenEdge.x * Math.round(-_position / (_scale * 2 * _screenEdge.x));
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
				else if (_snapToPage) {
					_destination = _minimumPosition + positionToPageStart();
					onEnterFrame(this, destinationMovement);
				} else {
					onEnterFrame(this, drawTiles);
				}
			}
			doTheDraw();
		}
		
/**
 * Scroll to a position
 */
		protected function destinationMovement(event:Event):void {
			var distance:Number = _destination - _position;
			if (Math.abs(distance) < MOVE_THRESHOLD) {
				_position = _destination;
				onEnterFrame(this, drawTiles);
			}
			else {
				_position += distance * BOUNCE_FACTOR ;
			}
			doTheDraw();
		}
		
		
		override public function destructor():void {
			super.destructor();
			for each (var bitmapData:BitmapData in _textureBitMapData) {
				bitmapData.dispose();
			}
		}

	}
}
