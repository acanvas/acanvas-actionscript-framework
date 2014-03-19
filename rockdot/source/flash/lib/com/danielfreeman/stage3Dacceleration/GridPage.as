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
	import com.danielfreeman.madcomponents.UIList;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	public class GridPage extends Stage3DAcceleration{
		
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
	
		protected static const GRID_SIZE:uint = 128;
		
		protected var _page:IContainerUI;
		protected var _columns:uint;
		protected var _rows:uint;
		
		protected var _pageWidth:Number;
		protected var _pageHeight:Number;
		protected var _pageWidthNormalised:Number;
		protected var _pageHeightNormalised:Number;
		protected var _gridWidthNormalised:Number;
		protected var _gridHeightNormalised:Number;
		
		protected var _lastWidth:Number;
		protected var _lastHeight:Number;
		protected var _lastWidthNormalised:Number;
		protected var _lastHeightNormalised:Number;

		protected var _gridBitmapdata: Vector.<Vector.<BitmapData>> = new Vector.<Vector.<BitmapData>>();
		protected var _gridTexture:Vector.<Vector.<Texture>> = new Vector.<Vector.<Texture>>();
		protected var _uv:Vector.<Number>;
		protected var _vertices:Vector.<Number>;
		protected var _uvVertexBuffer:VertexBuffer3D;
		protected var _xyzVertexBuffer:VertexBuffer3D;
		protected var _indices:Vector.<uint>;
		protected var _indexBuffer:IndexBuffer3D;
		protected var _reverseIndices:Vector.<uint>;
		protected var _reverseIndexBuffer:IndexBuffer3D;
		protected var _originalVertices:Vector.<Number> = null;
		
		protected var _workaround:Bitmap = null;
		protected var _offsetX:Number = 0;
		protected var _offsetY:Number = 0;

/**
 * This class captures a MadComponents page or panel, and represents it in Stage3D by a grid of square textures
 * The advantage of this scheme is that to update any region of the page, you only need reload the portions of the screen that have changed.
 * (not the whole thing).  Perhaps also, Stage#d deals with uploading smaller textures faster than one big texture.
 * This may or may not incur a small overhead to reassign a texture register for each square when rendering.
 */
		public function GridPage(page:IContainerUI, backgroundColour:uint = 0xffffffff):void {
			pageTexture(page, backgroundColour);
			pageCorners(-1.0, -1.0, 0.0, 1.0, -1.0, 0.0, -1.0, 1.0, 0.0);
		}
		
/**
 * Generate UV values.
 */
		protected function createUV(u:Number, v:Number):void {
			_uv.push(
				0, 		v,
				u,		v,
				u,		0,
				0,		0
			);
		}

/**
 * Set UV and index buffers.  There is also a reverse index buffer for rendering a reflected page.
 */
		protected function setBuffers():void {
			_uvVertexBuffer = _context3D.createVertexBuffer(_uv.length / 2, 2);
			_uvVertexBuffer.uploadFromVector(_uv, 0, _uv.length / 2);
			_indexBuffer = _context3D.createIndexBuffer( _indices.length );
			_indexBuffer.uploadFromVector(_indices, 0, _indices.length );
			_reverseIndexBuffer = _context3D.createIndexBuffer( _reverseIndices.length );
			_reverseIndexBuffer.uploadFromVector(_reverseIndices, 0, _reverseIndices.length );
			
			_gridWidthNormalised = 2 * GRID_SIZE / _screen.stage.stageWidth;
			_gridHeightNormalised = 2 * GRID_SIZE / _screen.stage.stageHeight;
		}
		
/**
 * Capture a page texture.
 */
		public function pageTexture(page:IContainerUI, backgroundColour:uint = 0xFFFFFFFF):void {
			_page = page;
			_pageWidth = UI.scale * theWidth(page);
			_pageHeight = UI.scale * theHeight(page);
			_pageWidthNormalised = 2 * _pageWidth / _screen.stage.stageWidth;
			_pageHeightNormalised = 2 * _pageHeight / _screen.stage.stageHeight;
			_columns = Math.ceil(_pageWidth / GRID_SIZE);
			_rows = Math.ceil(_pageHeight / GRID_SIZE);
			_lastWidth = _pageWidth - GRID_SIZE * (_columns - 1);
			_lastHeight = _pageHeight - GRID_SIZE * (_rows - 1);
			_lastWidthNormalised = 2 * _lastWidth/_screen.stage.stageWidth;
			_lastHeightNormalised = 2 * _lastHeight/_screen.stage.stageHeight;
			
			loadPage(backgroundColour);
		}
		
		
		public function loadPage(backgroundColour:uint = 0xFFFFFFFF):void {
			if (_gridBitmapdata) {
				clearTextures();
			}
			_uv = new Vector.<Number>();
			_indices = new Vector.<uint>();
			_reverseIndices = new Vector.<uint>();
			_gridBitmapdata = new Vector.<Vector.<BitmapData>>();
			_gridTexture = new Vector.<Vector.<Texture>>();
			for (var i:int = 0; i<_columns; i++) {
				var gridBitmapdata:Vector.<BitmapData> = new Vector.<BitmapData>;
				var gridTexture:Vector.<Texture> = new Vector.<Texture>;
				for (var j:int = 0; j<_rows; j++) {
					var bitmapData:BitmapData = new BitmapData(GRID_SIZE, GRID_SIZE, false, backgroundColour);
					var texture:Texture = _context3D.createTexture(GRID_SIZE, GRID_SIZE, Context3DTextureFormat.BGRA, false);
					saveTexture(bitmapData, Sprite(_page), new Rectangle(0, 0, GRID_SIZE * UI.scale, GRID_SIZE * UI.scale), -i * GRID_SIZE - _offsetX, -j * GRID_SIZE - _offsetY);
					texture.uploadFromBitmapData(bitmapData);
					gridBitmapdata.push(bitmapData);
					gridTexture.push(texture);
					
					createUV(	i < _columns - 1 ? 1.0 : _lastWidth / GRID_SIZE,
								j < _rows - 1 ? 1.0 : _lastHeight / GRID_SIZE
					);

					var count:int = 4 * (i*_rows + j);
					_indices.push(count, count+1, count+2,	count, count+2, count+3);
					_reverseIndices.push(count, count+2, count+1, count, count+3, count+2);
				}
				_gridBitmapdata.push(gridBitmapdata);
				_gridTexture.push(gridTexture);
			}
			_xyzVertexBuffer = _context3D.createVertexBuffer(_uv.length / 2, 3);
			setBuffers();
		}
		
/**
 * Set the orientation of the page in 3D space by specifying 3 corner points
 */
		public function pageCorners(topLeftX:Number, topLeftY:Number, topLeftZ:Number, topRightX:Number, topRightY:Number, topRightZ:Number, bottomLeftX:Number, bottomLeftY:Number, bottomLeftZ:Number):void {
			_vertices = new Vector.<Number>();
			var iDeltaX:Number = (topRightX - topLeftX) / _pageWidthNormalised;
			var iDeltaY:Number = (topRightY - topLeftY) / _pageHeightNormalised;
			var jDeltaX:Number = (bottomLeftX - topLeftX) / _pageWidthNormalised;
			var jDeltaY:Number = (bottomLeftY - topLeftY) / _pageHeightNormalised;
			for (var i:int = 0; i<_columns; i++) {
				for (var j:int = 0; j<_rows; j++) {
					var leftGrid:Number = topLeftX + (i * iDeltaX + j * jDeltaX) * _gridWidthNormalised;
					var rightGrid:Number = leftGrid + (iDeltaX + jDeltaX) * ((i < _columns - 1) ? _gridWidthNormalised : _lastWidthNormalised);
					var topGrid:Number = topLeftY + (i * iDeltaY + j * jDeltaY) * _gridHeightNormalised;
					var bottomGrid:Number = topGrid + (iDeltaY + jDeltaY) * ((j < _rows - 1) ? _gridHeightNormalised : _lastHeightNormalised);
					var frontGrid:Number = topLeftZ + (i / (_columns - 1)) * (topRightZ - topLeftZ) + (j / (_rows - 1)) * (bottomLeftZ - topLeftZ);
					var backGrid:Number = frontGrid + 1 / (_columns - 1) * (topRightZ - topLeftZ);
					_vertices.push(
						leftGrid, 		bottomGrid, 	frontGrid,
						rightGrid,		bottomGrid,		backGrid,
						rightGrid,		topGrid,		backGrid,
						leftGrid,		topGrid,		frontGrid
					);
				}
			}
			_xyzVertexBuffer.uploadFromVector(_vertices, 0, _vertices.length / 3);
		}
		
/**
 * Set the orientation of the page in 3D space with by its quad vertices.
 */
		public function set vertices(value:Vector.<Number>):void {
			_originalVertices = value.concat();
			pageCorners(
				value[9], value[10], value[11],
				value[6], value[7], value[8],
				value[0], value[1], value[2]
			);
		}
		
/**
 * store vertices
 */
		public function set vertices0(value:Vector.<Number>):void {
			_originalVertices = value.concat();
		}
		
/**
 * Retrieve the last quad set.
 */
		public function get vertices():Vector.<Number> {
			return _originalVertices;
		}
		
/**
 * The width of the page (in Stage space)
 */
		public function get width():Number {
			return UI.scale * _pageWidth;
		}
		
/**
 * The height of the page (in Stage space)
 */
		public function get height():Number {
			return UI.scale * _pageHeight;
		}

/**
 * Restore shaders, streams and textures after context loss.
 */
		override public function contextResumed(running:Boolean):void {
			
			for (var i:int = 0; i<_columns; i++) {
				for (var j:int = 0; j<_rows; j++) {
					_gridTexture[i][j].dispose();
					var texture:Texture = _context3D.createTexture(GRID_SIZE, GRID_SIZE, Context3DTextureFormat.BGRA, false);
					texture.uploadFromBitmapData(_gridBitmapdata[i][j]);
					_gridTexture[i][j] = texture;
				}
			}

			_xyzVertexBuffer = _context3D.createVertexBuffer(_vertices.length / 3, 3);
			_xyzVertexBuffer.uploadFromVector(_vertices, 0, _vertices.length / 3);
			setBuffers();
		}
		
		
		override public function disable():void {
			_context3D.setVertexBufferAt( 0, null ); //va0
			_context3D.setVertexBufferAt( 1, null ); //va1
		}
		
/**
 * Update a component appearance on that page.  
 */
		public function updatePage(component:DisplayObject):void {
			var globalPoint:Point = component.localToGlobal(new Point(0,0));
			var localPoint:Point = Sprite(_page).globalToLocal(globalPoint);
			var fromX:int = Math.max( Math.floor(UI.scale * localPoint.x / GRID_SIZE), 0);
			var toX:int = Math.min( Math.floor(UI.scale * (localPoint.x + component.width) / GRID_SIZE), _columns - 1);
			var fromY:int = Math.max( Math.floor(UI.scale * localPoint.y / GRID_SIZE), 0);
			var toY:int = Math.min( Math.floor(UI.scale * (localPoint.y + component.height) / GRID_SIZE), _rows - 1);
			if (component is UIList) {
				UIList(component).clearPressed();
			}
			
			for (var i:int = fromX; i <= toX; i++) {
				for (var j:int = fromY; j <= toY; j++) {trace(i,j);
					var bitmapData:BitmapData = _gridBitmapdata[i][j];
					saveTexture(bitmapData, Sprite(_page), new Rectangle(0, 0, GRID_SIZE * UI.scale, GRID_SIZE * UI.scale), -i * GRID_SIZE - _offsetX, -j * GRID_SIZE - _offsetY);	
					_gridTexture[i][j].uploadFromBitmapData(bitmapData);
				}
			}
		}

		
/**
 * Render the page.
 */
		public function display(reverse:Boolean = false):void {
			_context3D.setVertexBufferAt( 0, _xyzVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			for (var i:int = 0; i<_columns; i++) {
				for (var j:int = 0; j<_rows; j++) {
					_context3D.setTextureAt(0, _gridTexture[i][j]);
					_context3D.drawTriangles(reverse ? _reverseIndexBuffer : _indexBuffer, 6 * (j + i*_rows), 2);
				}
			}
		}
		
		
		protected function clearTextures():void {
			for (var i:int = 0; i<_gridTexture.length; i++) {
				for (var j:int = 0; j<_gridBitmapdata[i].length; j++) {
					_gridTexture[i][j].dispose();
					_gridBitmapdata[i][j].dispose();
				}
			}
		}
		
		
		override public function destructor():void {
			super.destructor();
			clearTextures();
		}

	}
}
