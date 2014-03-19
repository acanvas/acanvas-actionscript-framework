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
	import com.danielfreeman.madcomponents.IContainerUI;
	import com.danielfreeman.madcomponents.UI;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.events.Event;

/**
 * This refinement on the PageFlipping class utilises the GridPage class to subdivide each page into 128x128 squares
 * This is likely to make texture uploads faster, as subdividing a large texture into smaller areas is faster.
 * Also, updating the appearance of a component on a page will be faster (you only need to update the appropriate squares).
 * But it may incur penalties with geometry (more points to deal with), and renderring (swapping texture buffers more frequently).
 */
	public class PageFlippingE extends PageFlipping {
		
		protected var _gridPages:Vector.<GridPage> = new Vector.<GridPage>();
		protected var _reflectionVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _reflectionFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _reflectionShaderProgram:Program3D;
		protected var _lastPosition:Number = -1.0;
		
		protected static const ALTERNATIVE_SCHEME:Boolean = true;

		
		public function PageFlippingE() {
		}
		
/**
 * Vertex corners of a 2D page zoomed in
 */
		override protected function fillScreen():Vector.<Number> {
			var y:Number = -_pageTop / _screen.stage.stageHeight;
			return Vector.<Number> ([
			//	X,					Y,					Z,
				-FILL*_unit,		y-FILL*UNIT,		-0.1,
				FILL*_unit,			y-FILL*UNIT,		-0.1,
				FILL*_unit,			y+FILL*UNIT,		-0.1,
				-FILL*_unit,		y+FILL*UNIT,		-0.1
			]);
		}
		
/**
 * Vertex corners of a 2D page at flipping distance
 */
		override protected function centrePanel(position:Number = 0, y:Number = 0.1, z:Number = 0):Vector.<Number> {	
			return Vector.<Number> ([
			//	X,						Y,				Z,
				position-_unit,			y-UNIT,			z,
				position+_unit,			y-UNIT,			z,
				position+_unit,			y+UNIT,			z,
				position-_unit,			y+UNIT,			z
			]);
		}
			
/**
 * Vertex coordinates of MadFlow page to the left of the screen.
 */
		override protected function leftMadFlow(position:Number):Vector.<Number> {	
		
			return Vector.<Number> ([
			//	X,						Y,				Z,
				position,				Y-UNIT,			EDGE,
				position + SKEW,		Y-UNIT,			BACK,
				position + SKEW,		Y+UNIT,			BACK,
				position,				Y+UNIT,			EDGE
			]);
		}

/**
 * Vertex coordinates of MadFlow page to the right of the screen.
 */
		override protected function rightMadFlow(position:Number):Vector.<Number> {
		
			return Vector.<Number> ([
			//	X,						Y,				Z,
				position - SKEW,		Y-UNIT,			BACK,
				position,				Y-UNIT,			EDGE,
				position,				Y+UNIT,			EDGE,
				position - SKEW,		Y+UNIT,			BACK
			]);
		}
		
/**
 * There are two vertex shaders and two fragment shaders for this class.
 * 
 * The first vertex shader allows for horizontal translation (scrolling), and applies the perspective transformation matrix
 * The second vertex shader is for an inverted page that appears as a reflection.
 * 
 * The first fragment shader is a simple standard texture shader.
 * The second fragment shader is for a reflected appearance, and it multiplies each fragment value by an interpolated gradient value.
 */
		override public function initialise():void {

			translationMatrix();

			_pageFlippingVertexShader.assemble( Context3DProgramType.VERTEX,
				"mul vt0.xyzw, va0.xyxw, vc6.xyzw \n" + // interpolate
				"add vt0, vc4, vt0 \n" + // for fast scrolling
				"m44 op, vt0, vc0 \n" +	// vertex
				"mov v0, va1 \n"	// interpolate UVT
			);
			
			_pageFlippingFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"tex oc, v0.xy, fs0 <2d,linear,nomip> \n"	// output texture
			);
			
			_pageFlippingShaderProgram = _context3D.createProgram();
			_pageFlippingShaderProgram.upload( _pageFlippingVertexShader.agalcode, _pageFlippingFragmentShader.agalcode);
		
			_reflectionVertexShader.assemble(  Context3DProgramType.VERTEX,
			// vc4.x - reflect va0.y (y coordinate)
			// vc4.y - reflect va1.y (V)
			// vc4.z - always 0
				"mul vt0.xyzw, va0.xyxw, vc6.xyzw \n" + // interpolate
				"add vt0, vc4, vt0 \n" + // for fast scrolling
				"sub vt0.y, vc5.y, vt0.y \n" +  // reflect around baseline
				"m44 op, vt0, vc0 \n" +	// vertex
				"sub vt0.y, vt0.y, vc5.x \n" +
				"mul vt0.y, vt0.y, vc5.z \n" +
				"sub v1, vc5.wwww, vt0.yyyy \n" +
				"mov v0, va1 \n"		// interpolate UVT
			);
			
			_reflectionFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"tex ft0, v0.xy, fs0 <2d,linear,nomip> \n" +	// output texture
				"mul oc, ft0, v1.xy \n" // scale
			);
		
			_reflectionShaderProgram = _context3D.createProgram();
			_reflectionShaderProgram.upload( _reflectionVertexShader.agalcode, _reflectionFragmentShader.agalcode);
		
		}

/**
 * Capture all of the pages within specified as a Vector of Sprites.
 * Notice optional showPageIndicator parameter.  If true, displays a page indicator at the bottom of the screen.
 */
		override public function pageTextures(width:Number, height:Number, pages:Vector.<Sprite>, showPageIndicator:Boolean, backgroundColour:uint = 0xFFFFFF):void {
			
			_pageWidth = width*scale;
			_pageHeight = height*scale;
			
			if (showPageIndicator) {
				_pageIndicator = new PageIndicator(_screen.stage.stageHeight - INDICATOR_GAP * UI.scale, INDICATOR_SIZE * UI.scale, pages.length);
			}

			_boundary = 0.8 * _pageWidth / _pageHeight;
			_unit = UNIT * _pageWidth / _pageHeight;
			_fillScreen = fillScreen();
			
			_count = pages.length;
			for each (var page:Sprite in pages) {
				var gridPage:GridPage = new GridPage(IContainerUI(page), backgroundColour);
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
 * Restore shaders, streams and textures after context loss.
 */
		override public function contextResumed(running:Boolean):void {

			_pageFlippingShaderProgram = _context3D.createProgram();
			_pageFlippingShaderProgram.upload( _pageFlippingVertexShader.agalcode, _pageFlippingFragmentShader.agalcode);
			_reflectionShaderProgram = _context3D.createProgram();
			_reflectionShaderProgram.upload( _reflectionVertexShader.agalcode, _reflectionFragmentShader.agalcode);

			for each (var page:GridPage in _gridPages) {
				page.contextResumed(running);
			}

			if (running) {
				show();
				onEnterFrame(this, touchMovement);
			}
		}
		
/**
 * Update the appearance of a component on a particular page.
 */
		override public function updatePage(pageNumber:int, component:DisplayObject = null):void {
			_gridPages[pageNumber].updatePage(component);
		}
		
		
		public function loadPage(pageNumber:int, backgroundColour:uint = 0xFFFFFFFF):void {
			_gridPages[pageNumber].loadPage(backgroundColour);
		}
		
		
		override protected function setRegisters():void {
			_context3D.setProgram(_pageFlippingShaderProgram);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _finalMatrix, true); //vc0 - vc3
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, Vector.<Number>([ 0.0, 0.0, 0.0, 0.0 ])); //vc5
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 6, Vector.<Number>([ 1.0, 1.0, 0.0, 1.0 ])); //vc6
		}
		
		
		override protected function setPageVertices(i:int, pageVertices:Vector.<Number>):void {
			if (ALTERNATIVE_SCHEME) {
				_gridPages[i].vertices0 = pageVertices;
			}
			else
				if (_position != _lastPosition || i == pageNumber && _zoomIn > 0.0) {
					_gridPages[i].vertices = pageVertices;
			}
		}
		
	
		override protected function doNothing(event:Event):void {
			drawPages();
		}
		
		
		override protected function make(position:Number, zoomIn:Number = 0):void {
			maximumAndMinimum();
			_flavour(position, zoomIn);
			drawPages();
		}
		
		
		override protected function makePages(position:Number, zoomIn:Number = 0):void {
			if (ALTERNATIVE_SCHEME) { //faster scrolling
				doMakePages(position, zoomIn);
			}
			else {
				super.makePages(position, zoomIn);
			}
		}

/**
 * Render pages.
 */
		override protected function drawPages():void {
			_context3D.clear(_zoomIn*(_zoomedColour>>32 & 0xff)/0xff, _zoomIn*(_zoomedColour>>16 & 0xff)/0xff, _zoomIn*(_zoomedColour & 0xff)/0xff);
			for each (var page:GridPage in _gridPages) {
				_context3D.setProgram(_pageFlippingShaderProgram);
				if (ALTERNATIVE_SCHEME) {
					var deltaX:Number = (page.vertices[3] - page.vertices[0]) / 2;
					var deltaY:Number = (page.vertices[7] - page.vertices[4]) / 2;
					var deltaZ:Number = (page.vertices[5] - page.vertices[2]) / 2;
					_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ page.vertices[0] + deltaX, page.vertices[1] + deltaY, page.vertices[2] + deltaZ, 0.0 ]) );	// vc4
					_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 6, Vector.<Number>([
						deltaX,
						deltaY,
						deltaZ,
						1.0
					]) );	// vc6
				}
				page.display();
				var baseline:Number = page.vertices[1];
				_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, Vector.<Number>([ baseline, 2.0*baseline, -1/(2*UNIT), 0.5 ]) );	// vc5

				_context3D.setProgram(_reflectionShaderProgram);
				page.display(true);
			}
			if (_pageIndicator) {
				drawPageIndicator();
			}
			_context3D.present();
			_lastPosition == _position;
		}
		
		
		override public function destructor():void {
			super.destructor();
			for each (var page:GridPage in _gridPages) {
				page.destructor();
			}
		}

	}
}
