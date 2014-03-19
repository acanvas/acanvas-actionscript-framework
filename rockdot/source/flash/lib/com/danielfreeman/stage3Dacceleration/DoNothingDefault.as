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

	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;

/**
 *  Just displays a Stage3D rectangle.  But in continually refreshing that rectangle, we ensure that display list graphics are also refreshed.
 *  (On mobile Stage3D synchs Display List - so if Stage3D ceases - so does the display list!
 */
	public class DoNothingDefault extends Stage3DAcceleration {
	
		protected var _indexBuffer:IndexBuffer3D;
		protected var _vertexBuffer:VertexBuffer3D;

		protected var _doNothingVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _doNothingFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _doNothingShaderProgram:Program3D;


		public function DoNothingDefault() {

			//Very simple shaders
			
			_doNothingVertexShader.assemble( Context3DProgramType.VERTEX,
				"mov op, va0 \n" +				// output vertex
				"abs v0, va0 \n"				// absolute and interpolate
			);
			
			_doNothingFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"mov oc, v0 \n"
			);

			contextResumed(false);
			isDefault(this);
			activate(this);
		}
		
/**
 *  If we've lost context, refresh shaders and streams
 */
		override public function contextResumed(running:Boolean):void {

			_doNothingShaderProgram = _context3D.createProgram();
			_doNothingShaderProgram.upload( _doNothingVertexShader.agalcode, _doNothingFragmentShader.agalcode);
			
			var vertices:Vector.<Number> = Vector.<Number> ([
			//	X,			Y,			Z,
				-1.0,		-1.0,		0.0,
				1.0,		-1.0,		0.0,
				1.0,		1.0,		0.0,
				-1.0,		1.0,		0.0
			]);
			
			_vertexBuffer = _context3D.createVertexBuffer(4, 3);
			_vertexBuffer.uploadFromVector(vertices, 0, vertices.length/3);
			
			var indices:Vector.<uint> = Vector.<uint> ([ 0, 1, 2,	0, 2, 3 ]);
			_indexBuffer = _context3D.createIndexBuffer( indices.length );
			_indexBuffer.uploadFromVector(indices, 0, indices.length );
			
			if (running) {
				enable();
			}
		}
		

		override public function enable():void {
			_context3D.setVertexBufferAt( 0, _vertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setProgram(_doNothingShaderProgram);
			onEnterFrame(this, onEnterFrameDoNothing);
		}
		
			
		override public function disable():void {
			_context3D.setVertexBufferAt( 0, null ); //va0
		}
		
/**
 *  refresh Stage3D
 */
		protected function onEnterFrameDoNothing(event:Event):void {
			_context3D.clear();
			_context3D.drawTriangles(_indexBuffer);
			_context3D.present();
		}

	}
}
