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

	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;

/**
 * This Class render a page indicator.
 * That is, a sequence of dots, one of which is illuminated to show which page is current.
 */
	public class PageIndicator extends Stage3DAcceleration {
		
		protected static const GAP:Number = 0.01;
		protected static const DIM_COLOUR:uint = 0x666666;
		protected static const BRIGHT_COLOUR:uint = 0xCCCCCC;
		protected static const ZOOM:Number = 0.5;
		
		protected var _pages:int;
		protected var _vertices:Vector.<Number> = new Vector.<Number>();
		protected var _uv:Vector.<Number> = new Vector.<Number>();
		protected var _indices:Vector.<uint> = new Vector.<uint>();
		protected var _indexBuffer:IndexBuffer3D;
		protected var _xyzVertexBuffer:VertexBuffer3D;
		protected var _uvVertexBuffer:VertexBuffer3D;

		protected var _circleVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _circleFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _circleShaderProgram:Program3D;
		
		protected var _gap:Number;
				
/**
 * Note that that this class sets stage3D to allow for transparency in textures.
 */
		public function PageIndicator(y:Number, size:Number, pages:int, gap:Number = -1.0) {
			_gap = ( gap < 0 ) ? GAP : 2 * gap / _screen.stage.stageWidth;
			_pages = pages;
			super();
			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			initialise();
			makeGeometry(y, size, pages);
		}
		
/**
 * The vertex shader is simple and standard.  Output vertices, no transformation matrix.  Interpolate UV.
 * The fragment shader is a geomtric shader that creates a circular shape.
 */

		public function initialise():void {

			_circleVertexShader.assemble( Context3DProgramType.VERTEX,
				"mov op, va0 \n" +			//
				"mov v0, va1 \n"			// interpolate UV
			);
			
			_circleFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"mov ft1, fc3 \n" +
				"sub ft0.xy, v0.xy, fc2.xx \n" + // vector from centre
				"mul ft0.xy, ft0.xy, ft0.xy \n" + // square
				"add ft0.x, ft0.x, ft0.y \n" + // add x and y
				"sub ft0.y, fc2.y, ft0.x \n" + // (1 + radius squared) – sum
				"pow ft1.w, ft0.y, fc2.z \n" + // feathering to anti-alias circle
				"mov oc, ft1 \n" // output colour 	// output texture
			);
			
			_circleShaderProgram = _context3D.createProgram();
			_circleShaderProgram.upload( _circleVertexShader.agalcode, _circleFragmentShader.agalcode);
		}
		
/**
 * Construct vertices and UV values.  This is simply a row of quads.
 */
		protected function makeGeometry(y:Number, size:Number, pages:int):void {
			var sizeGraph:Number = 2 * size / _screen.stage.stageHeight;
			var xGraph:Number = - (pages * (sizeGraph + _gap) - _gap) / 2;
			var yGraph:Number = - toGraphY(y);
			for (var i:int = 0; i < pages; i++) {
				var left:Number = xGraph + i * (sizeGraph + _gap);
				var right:Number = left + sizeGraph/_aspectRatio;

				_vertices.push(
					left, 		yGraph, 			ZOOM,
					right,		yGraph ,			ZOOM,
					right,		yGraph+ sizeGraph,	ZOOM,
					left,		yGraph+ sizeGraph,	ZOOM
				);
				
				_uv.push(
					0.0, 		1.0,
					1.0,		1.0,
					1.0,		0.0,
					0.0,		0.0
				);
				
				var count:uint = 4*i;
				_indices.push(
					count, count+1, count+2,	count, count+2, count+3
				);
			}
			contextResumed(false);
		}
		
/**
 * Restore shaders, streams and textures after context loss.
 */
		override public function contextResumed(running:Boolean):void {
			
			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

			_circleShaderProgram = _context3D.createProgram();
			_circleShaderProgram.upload( _circleVertexShader.agalcode, _circleFragmentShader.agalcode);
			
			_xyzVertexBuffer = _context3D.createVertexBuffer(_pages * 4, 3);
			_xyzVertexBuffer.uploadFromVector(_vertices, 0, _vertices.length / 3);
			
			_uvVertexBuffer = _context3D.createVertexBuffer(_pages * 4, 2);
			_uvVertexBuffer.uploadFromVector(_uv, 0, _uv.length/2);
			
			_indexBuffer = _context3D.createIndexBuffer( _indices.length );
			_indexBuffer.uploadFromVector(_indices, 0, _indices.length );
			
		//	_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>([ 0.5, 1.245, 200, 1.0 ])); // vc2  centre, 1 + radius squared – frig, feathering, 1.0		
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>([ 0.5, 1.1, 20, 1.0 ]));
		}

/**
 * Render the page indicator.
 */
		public function display(page:int, clearAndPresent:Boolean = false):void {
			if (clearAndPresent) {
				_context3D.clear();
			}
			_context3D.setProgram(_circleShaderProgram);
			_context3D.setVertexBufferAt( 0, _xyzVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Vector.<Number>([ (DIM_COLOUR>>32 & 0xff)/0xff, (DIM_COLOUR>>16 & 0xff)/0xff, (DIM_COLOUR & 0xff)/0xff, 0]) );
			if (page > 0) {
				_context3D.drawTriangles(_indexBuffer,0, 2 * page);
			}
			if (page < _pages - 1) {
				_context3D.drawTriangles(_indexBuffer,6 * (page + 1), 2 * (_pages - page - 1));
			}
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Vector.<Number>([ (BRIGHT_COLOUR>>32 & 0xff)/0xff, (BRIGHT_COLOUR>>16 & 0xff)/0xff, (BRIGHT_COLOUR & 0xff)/0xff, 0]) );
			_context3D.drawTriangles(_indexBuffer,6 * page, 2);
			if (clearAndPresent) {
				_context3D.present();
			}
			
		}

	}
}
