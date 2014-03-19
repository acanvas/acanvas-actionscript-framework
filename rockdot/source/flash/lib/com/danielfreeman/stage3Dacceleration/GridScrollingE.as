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
	import com.danielfreeman.madcomponents.Attributes;
	import com.danielfreeman.madcomponents.IContainerUI;
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UIForm;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
/**
 * An enhancement to the GridScrolling class that allows a grid square to flip around and zoom into a MadComponents form on its flip side
 */
	public class GridScrollingE extends GridScrolling {
		
		protected static const INCREMENT:Number = 0.1;
		protected static const NEAR:Number = 0.86;
		protected static const AUTO_SWAP_FRAMES:int = 128;
		protected static const SWAP_DURATION_FRAMES:int = 32;
		
		protected var _pages:Vector.<GridPage> = new Vector.<GridPage>;
		protected var _pageIndex:int = -1;
		protected var _frame:Number = 0.0;
		protected var _flipMatrix:Matrix3D = new Matrix3D();
		protected var _midPoint:Vector3D;
		protected var _pivotPoint:Vector3D;
		protected var _axis:Vector3D;
		protected var _rotation:Number;
		protected var _reverse:Boolean;
		protected var _offset:Number;
		
		protected var _autoSwapIndices:Vector.<int> = new Vector.<int>();
		protected var _autoSwapFrames:int = AUTO_SWAP_FRAMES;
		protected var _autoSwapCount:int = 0;
		protected var _swapCount:int = SWAP_DURATION_FRAMES;
		protected var _swapState:Boolean = true;
		

		public function GridScrollingE() {
			super();
		}
		
/**
 * The vertex shader is designed to transform each vertex by both transformation matrices,
 * then linear interpolation to animate between the two positions.
 * 
 * The fragment shader allows or a UV-animated panel to slide up in front of the current panel.
 */
		override public function initialise():void {
			
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
				"add ft1.xy, fc0.xy, v0.xy \n" +
				"tex ft0, ft1.xy, fs0 <2d,linear,nomip> \n" + 	// texture 1
				"add ft1.y, ft1.y, fc0.z \n" +
				"tex ft2, ft1.xy, fs0 <2d,linear,nomip> \n" + 	// texture 2
				"sge ft3.x, v0.y, fc0.w \n" +
				"slt ft3.y, v0.y, fc0.w \n" +
				"mul ft0.xyzw, ft0.xyzw, ft3.yyyy \n" +
				"mul ft2.xyzw, ft2.xyzw, ft3.xxxx \n" +
				"add oc, ft0, ft2 \n"
			);
			
			_tiledShaderProgram = _context3D.createProgram();
			_tiledShaderProgram.upload( _tiledVertexShader.agalcode, _tiledFragmentShader.agalcode);

			_projectionMatrix.perspectiveFieldOfViewLH(60.0*Math.PI/180, _aspectRatio, 0.1, 1000.0);
			translationMatrix();
		}
		
/**
 * Set the number of frames as the intwerval between swaps.
 */
		public function set autoSwapFrames(value:int):void {
			_autoSwapFrames = Math.max(value, SWAP_DURATION_FRAMES);
		}
		
/**
 * For a live-rectangle, specify a layout.
 */
		public function addSwapFlipTexture(row:int, column:int, layout:XML):void {
			var index:uint = _gridPositionToArrayIndex[column][row];
			var cellSize:Point = _cellSize[index];
			var oldBitmapData:BitmapData = _textureBitMapData[index];
			
			var madRendered:UIForm = new UIForm(new Sprite(), layout, new Attributes(0, 0, cellSize.x/UI.scale, cellSize.y/UI.scale));
			var newBitmapData:BitmapData = new BitmapData(power2(QUALITY_SCALE * cellSize.x), power2(QUALITY_SCALE * cellSize.y + oldBitmapData.height));
			newBitmapData.copyPixels(oldBitmapData, new Rectangle(0, 0, cellSize.x, cellSize.y), new Point(0, 0));
			saveTexture(newBitmapData, madRendered, new Rectangle(0, QUALITY_SCALE * cellSize.y, cellSize.x, cellSize.y), 0, 0, QUALITY_SCALE);
			var texture:Texture = _context3D.createTexture(newBitmapData.width, newBitmapData.height, Context3DTextureFormat.BGRA, false);
			_textureBitMapData[index] = newBitmapData;
			texture.uploadFromBitmapData(newBitmapData);
			oldBitmapData.dispose();
			_tiledTexture[index].dispose();
			_tiledTexture[index] = texture;
			
			var newV:Number = cellSize.y * QUALITY_SCALE / newBitmapData.height;
			_uv.splice(index*8 + 1, 1, newV);
			_uv.splice(index*8 + 3, 1, newV);
			_uvVertexBuffer.uploadFromVector(_uv, 0, _uv.length/2);

			_autoSwapIndices.push(index);
		}
		
/**
 * Include a new page
 */
		public function pageTexture(page:IContainerUI, backgroundColour:uint = 0x000000):uint {
			return _pages.push(new GridPage(page, backgroundColour));
		}
		
		
		override public function contextResumed(running:Boolean):void {
			super.contextResumed(running);
			for each (var page:GridPage in _pages) {
				page.contextResumed(running);
			}
		}
		
		
		protected function flipTransformation(frame:Number, angle:Number, axis:Vector3D, scaleX:Number = 1.0, scaleY:Number = 1.0):void {
			if (_reverse) {
				frame = 1 - frame;
			}
			_flipMatrix.identity();
			
			_flipMatrix.appendTranslation(-_pivotPoint.x , -_pivotPoint.y, 0);
			_flipMatrix.appendScale((1-frame) + frame * (scaleX/_scale), (1-frame) + frame * (scaleY/_scale), 1.0);
			_flipMatrix.appendRotation(frame * angle, axis);
			_flipMatrix.appendTranslation(_pivotPoint.x , _pivotPoint.y, 0);
			_flipMatrix.appendScale(_scale, _scale, 1.0);
			_flipMatrix.appendTranslation(-frame * (_scale * _pivotPoint.x + _offset), -frame * _scale * _midPoint.y, (1-frame) * ZOOM + frame * NEAR);
			_flipMatrix.append(_projectionMatrix);
		}
		
/**
 * Flip the square at position row, column
 */
		public function flipAround(row:uint, column:uint, pageIndex:uint = 0, reverse:Boolean = false):void {
			_pageIndex = pageIndex;
			_reverse = reverse;
			var arrayIndex:uint = _gridPositionToArrayIndex[column][row];
			if (arrayIndex >= 0) {
				_animation[arrayIndex] = ANIMATION;
				_arrayIndex = arrayIndex;
				var vertexIndex:int = 12 * arrayIndex;
				var xMid:Number = (_vertices[vertexIndex] + _vertices[vertexIndex + 3])/2;
				var yMid:Number = (_vertices[vertexIndex + 1] + _vertices[vertexIndex + 7])/2;
				_midPoint = new Vector3D(_position + xMid, yMid, 0);
				_axis = Vector3D.Y_AXIS;
				var direction:Boolean = (xMid + _position/_scale < 0);
				_rotation = direction ? -180 : 180;
				_offset = UI.scale * (direction ? 0.5 : -0.5) * _aspectRatio * _cellWidth / _screen.stage.stageWidth; //(_vertices[vertexIndex + 3] - _vertices[vertexIndex]); //_pages[pageIndex].width/_screen.stage.stageWidth; 
				var pivotX:Number = _position/_scale + (direction ? _vertices[vertexIndex + 3] : _vertices[vertexIndex]);
				_pivotPoint = new Vector3D(pivotX, yMid);
				_pages[pageIndex].pageCorners(
					_vertices[vertexIndex + 6], _vertices[vertexIndex + 7], _vertices[vertexIndex + 8],
					_vertices[vertexIndex + 9], _vertices[vertexIndex + 10], _vertices[vertexIndex + 11],
					_vertices[vertexIndex + 3], _vertices[vertexIndex + 4], _vertices[vertexIndex + 5]
				);

				_frame = 0;
				onEnterFrame(this, drawFlipAround);
			}
			_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
/**
 * Flip the square that was clicked last
 */
		public function flipAroundClicked(pageIndex:uint = 0, reverse:Boolean = false):void {
			flipAround(_indexPoint.x, _indexPoint.y, pageIndex, reverse);
		}
		
		
		public function flipBack():void {
			_reverse = true;
			_frame = -INCREMENT;
			activate(this);
			if (UI.windowLayer) {
				UI.windowLayer.visible = false;
			}
			onEnterFrame(this, drawFlipAround);
		}
		
		
		override protected function doTheDraw(present:Boolean = true):void {
			if (_swapCount > 0) {
				_swapCount++;
			}
			super.doTheDraw(present);
			if (++_autoSwapCount >= _autoSwapFrames) {
				_autoSwapCount = 0;
			}
			else if (_autoSwapCount == SWAP_DURATION_FRAMES) {
				_swapState = !_swapState;
			}
		}
		
		
		protected function setFc0ForSwap(index:int):void {
			var swap:Boolean = _autoSwapIndices.indexOf(index) >= 0;
			var animationFrame:int = (_autoSwapCount < SWAP_DURATION_FRAMES) ? _autoSwapCount : 0.0;
			var vPlus:Number =  _cellSize[index].y / power2(_cellSize[index].y);
			var animation:Number = swap ? vPlus * (1 -animationFrame/SWAP_DURATION_FRAMES) : vPlus;
			if (_swapState) {
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 0.0, 0.0, vPlus/2-animation, animation ]));
			}
			else {
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 0.0, swap ? vPlus/2 : 0.0, -vPlus/2-animation, animation ]));
			}
		}
		
		
		override protected function doTheDrawForTile(index:int):void {
			setFc0ForSwap(index);
			super.doTheDrawForTile(index);
		}	
		
/**
 * Render the grid, animating the flip square
 */
		protected function drawFlipAround(event:Event):void {
			flipTransformation(Math.max(0,_frame), _rotation , _axis, _pages[_pageIndex].width/_cellSize[_arrayIndex].x, _pages[_pageIndex].height/_cellSize[_arrayIndex].y);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _flipMatrix, true); //vc4 - vc7
			_context3D.clear((_backgroundColour>>32 & 0xff)/0xff, (_backgroundColour>>16 & 0xff)/0xff, (_backgroundColour & 0xff)/0xff);
			for (var j:int = 0; j < _count; j++) {
				setFc0ForSwap(j);
				_context3D.setTextureAt(0, _tiledTexture[j]); //fs0
				if (j == _arrayIndex) {
					_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, Vector.<Number>([ 0.0, 1.0, _position/_scale, 0.0 ]) );	// vc8
				}
				else {
					_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, Vector.<Number>([ 1.0, 0.0, _position/_scale, 0.0 ]) );	// vc8
				}
				_context3D.drawTriangles(_indexBuffer, 6 * j, 2);
			}
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, Vector.<Number>([ 0.0, 1.0, _position/_scale, 0.0 ]) );	// vc8
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 0.0, 0.0, 0.0, 1.0 ]));  //fc0
			_pages[_pageIndex].display();
			_context3D.present();
			_context3D.setVertexBufferAt( 0, _xyzVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			
			_frame+=INCREMENT;
			if (!_enabled) {
				deactivate(this);
			}
			if (_frame > 1.0) {
				if (_reverse) {
					makeInteractive();
					onEnterFrame(this, drawTiles);
				}
				else {
					_finish = false;
					stop();
				}
				_frame = 1.0;
			}
		}
	}
}
