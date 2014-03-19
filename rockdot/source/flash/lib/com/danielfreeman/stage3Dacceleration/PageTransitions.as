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
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UIPages;

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
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	
	public class PageTransitions extends Stage3DAcceleration {
	
		public static const SIMPLE:String = "simple";	
		public static const SLIDE_LEFT:String = "slideLeft";
		public static const SLIDE_RIGHT:String = "slideRight";
		public static const SLIDE_UP:String = "slideUp";
		public static const SLIDE_DOWN:String = "slideDown";
		public static const FLIP_LEFT:String = "flipLeft";
		public static const FLIP_RIGHT:String = "flipRight";
		public static const SWAP_LEFT:String = "swapLeft";
		public static const SWAP_RIGHT:String = "swapRight";
		public static const CUBE_LEFT:String = "cubeLeft";
		public static const CUBE_RIGHT:String = "cubeRight";
		public static const DOOR_LEFT:String = "doorLeft";
		public static const DOOR_RIGHT:String = "doorRight";
		public static const DRAWER_UP:String = "drawerUp";
		public static const DRAWER_DOWN:String = "drawerDown";
		public static const TRASH_UP:String = "trashUp";
		public static const TRASH_DOWN:String = "trashDown";
		public static const SLIDE_OVER_UP:String = "slide3dUp";
		public static const SLIDE_OVER_DOWN:String = "slide3dDown";
		public static const SLIDE_OVER_LEFT:String = "slide3dLeft";
		public static const SLIDE_OVER_RIGHT:String = "slide3dRight";

		public static const TRANSITION_INITIAL:String = "transitionInitial";		
		public static const TRANSITION_COMPLETE:String = "transitionComplete";
		
		protected static const ZOOM:Number = 1.73;
		protected static const INCREMENT:Number = 0.1;
		
		
		protected static const INDICES:Vector.<uint> = 
		
			Vector.<uint> ([ 0, 1, 2,	0, 2, 3,    4, 5, 6,	4, 6, 7]);


		protected static const SCREEN_REGION:Vector.<Number> =	
		
			Vector.<Number> ([
			//	X,		Y,		Z,
				-1.0,	-1.0,	0.001,
				1.0,	-1.0,	0.001,
				1.0,	1.0,	0.001,
				-1.0,	1.0,	0.001
			]);
			
			
		protected static const FLIPPED:Vector.<Number> =	
		
			Vector.<Number> ([
			//	X,		Y,		Z,
				1.0,	-1.0,	0.001,
				-1.0,	-1.0,	0.001,
				-1.0,	1.0,	0.001,
				1.0,	1.0,	0.001
			]);	
		
		
		protected static const LEFT_REGION:Vector.<Number> =
		
			Vector.<Number> ([
			//	X,		Y,		Z,
				-3.0,	-1.0,	0.0,
				-1.0,	-1.0,	0.0,
				-1.0,	1.0,	0.0,
				-3.0,	1.0,	0.0
			]);
			
			
		protected static const RIGHT_REGION:Vector.<Number> =
		
			Vector.<Number> ([
			//	X,		Y,		Z,
				1.0,	-1.0,	0.0,
				3.0,	-1.0,	0.0,
				3.0,	1.0,	0.0,
				1.0,	1.0,	0.0
			]);
			

		protected static const BELOW_REGION:Vector.<Number> =

			Vector.<Number> ([
			//	X,		Y,		Z,
				-1.0,	-3.0,	0.0,
				1.0,	-3.0,	0.0,
				1.0,	-1.0,	0.0,
				-1.0,	-1.0,	0.0
			]);
			
			
		protected static const SINGULARITY:Vector.<Number> =

			Vector.<Number> ([
			//	X,		Y,		Z,
				1.0,	-3.0,	-0.01,
				-1.0,	-3.0,	-0.01,
				0.0,	-1.0,	-0.01,
				0.0,	-1.0,	-0.01
			]);
					

		protected static const LEFT_SCREEN_REGION:Vector.<Number> =

			Vector.<Number> ([
			//	X,		Y,		Z,
				-3.2,	-0.5,	2.0,
				-1.2,	-0.5,	2.0,
				-1.2,	0.5,	2.0,
				-3.2,	0.5,	2.0
			]);	
			
			
		protected static const RIGHT_SCREEN_REGION:Vector.<Number> =

			Vector.<Number> ([
			//	X,		Y,		Z,
				1.0,	-0.5,	2.0,
				3.0,	-0.5,	2.0,
				3.0,	0.5,	2.0,
				1.0,	0.5,	2.0
			]);	
			
			
		protected static const LEFT_CUBE:Vector.<Number> =

			Vector.<Number> ([
			//	X,		Y,		Z,
				-1.5,	-1.0,	1.0,
				-1.0,	-1.0,	0.0,
				-1.0,	1.0,	0.0,
				-1.5,	1.0,	1.0
			]);
			
			
		protected static const RIGHT_CUBE:Vector.<Number> =

			Vector.<Number> ([
			//	X,		Y,		Z,
				1.0,	-1.0,	0.0,
				1.5,	-1.0,	1.0,
				1.5,	1.0,	1.0,
				1.0,	1.0,	0.0
			]);
			
			
		protected static const LEFT_EDGE:Vector.<Number> =	
		
			Vector.<Number> ([
			//	X,		Y,		Z,
				-1.0,	-1.0,	0.0,
				-1.0,	-1.0,	2.0,
				-1.0,	1.0,	2.0,
				-1.0,	1.0,	0.0
			]);
			
			
		protected static const RIGHT_EDGE:Vector.<Number> =	
		
			Vector.<Number> ([
			//	X,		Y,		Z,
				1.0,	-1.0,	2.0,
				1.0,	-1.0,	0.0,
				1.0,	1.0,	0.0,
				1.0,	1.0,	2.0
			]);
			
			
		protected static const SCREEN_RECESSED:Vector.<Number> =	
		
			Vector.<Number> ([
			//	X,		Y,		Z,
				-1.0,	-1.0,	0.2,
				1.0,	-1.0,	0.2,
				1.0,	1.0,	0.2,
				-1.0,	1.0,	0.2
			]);


		protected static const N:int = 6;

		protected static var _indexBuffer:IndexBuffer3D;
		
		protected var _uvtVertices:VertexBuffer3D;
		protected var _startKeyVertices:VertexBuffer3D;
		protected var _finishKeyVertices:VertexBuffer3D;
		
		protected var _pageTransitionVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _pageTransitionFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _pageTransitionShaderProgram:Program3D;
		
		protected var _finalMatrix:Matrix3D = new Matrix3D();
		protected var _projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		
		protected var _count:Number = 0.0;
		protected var _transition:String = SLIDE_UP;
		
		protected var _page:int = -1;
		protected var _uiPages:UIPages = null;
		
		protected var _sourceBitmapData:BitmapData;
		protected var _destinationBitmapData:BitmapData;

		protected var _transitionSourceTexture:Texture;
		protected var _transitionDestinationTexture:Texture;	

		
		protected function uvt(scaleX:Number, scaleY:Number, reverse:Boolean = false):Vector.<Number> {	
		
		if (reverse) {
			return Vector.<Number> ([
				//	U,						V,
					0.0,					scaleY,			1.0,
					scaleX,					scaleY,			1.0,
					scaleX,					0.0,			1.0,
					0.0,					0.0,			1.0,
				
					0.0,					scaleY,			0.0,
					scaleX,					scaleY,			0.0,
					scaleX,					0.0,			0.0,
					0.0,					0.0,			0.0
				]);
		}
		else {
			return Vector.<Number> ([
				//	U,						V,
					0.0,					scaleY,			0.0,
					scaleX,					scaleY,			0.0,
					scaleX,					0.0,			0.0,
					0.0,					0.0,			0.0,
				
					0.0,					scaleY,			1.0,
					scaleX,					scaleY,			1.0,
					scaleX,					0.0,			1.0,
					0.0,					0.0,			1.0
				]);
		}
		}
		
		
		public function PageTransitions() {
			initialise();
		}
		
		
		public function initialise():void {
			_startKeyVertices = _context3D.createVertexBuffer(8, 3);
			_finishKeyVertices = _context3D.createVertexBuffer(8, 3);

			_uvtVertices = _context3D.createVertexBuffer(8, 3);
			_indexBuffer = _context3D.createIndexBuffer( INDICES.length );
			_indexBuffer.uploadFromVector(INDICES, 0, INDICES.length );

			_projectionMatrix.perspectiveFieldOfViewLH(60.0*Math.PI/180, 1.0, 0.1, 1000.0);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _finalMatrix, true); //vc0 - vc3

			_pageTransitionVertexShader.assemble( Context3DProgramType.VERTEX,
				"mul vt0, va0, vc4.xxxx \n" +	// t * start position
				"mul vt1, va1, vc4.yyyy \n" +	// (1-t) * end position
				"add vt2, vt0, vt1 \n" +		// add
				"m44 op, vt2, vc0 \n" +			// transform and output
				"mov v0, va2 \n"				// interpolate UVT
			);

			_pageTransitionFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"tex ft0, v0, fs0 <2d,linear,nomip> \n"	+	// output texture
				"sub ft2.x, fc0.w, v0.z \n" +
				"mul ft0, ft0, ft2.xxxx \n" +      			// if t=1, texture
				"tex ft1, v0, fs1 <2d,linear,nomip> \n"	+	// output texture
				"mul ft1, ft1, v0.zzzz \n" +
				"add oc, ft0, ft1 \n"
			);

			_pageTransitionShaderProgram = _context3D.createProgram();
			_pageTransitionShaderProgram.upload( _pageTransitionVertexShader.agalcode, _pageTransitionFragmentShader.agalcode);
		}
		
		
		override public function contextResumed(running:Boolean):void {

			_pageTransitionShaderProgram = _context3D.createProgram();
			_pageTransitionShaderProgram.upload( _pageTransitionVertexShader.agalcode, _pageTransitionFragmentShader.agalcode);
			
			_startKeyVertices = _context3D.createVertexBuffer(8, 3);
			_finishKeyVertices = _context3D.createVertexBuffer(8, 3);

			_uvtVertices = _context3D.createVertexBuffer(8, 3);
			_indexBuffer = _context3D.createIndexBuffer( INDICES.length );
			_indexBuffer.uploadFromVector(INDICES, 0, INDICES.length );
			
			_transitionSourceTexture = _context3D.createTexture(_sourceBitmapData.width, _sourceBitmapData.height, Context3DTextureFormat.BGRA, false);
			_transitionSourceTexture.uploadFromBitmapData(_sourceBitmapData);
				
			_transitionDestinationTexture = _context3D.createTexture(_destinationBitmapData.width, _destinationBitmapData.height, Context3DTextureFormat.BGRA, false);
			_transitionDestinationTexture.uploadFromBitmapData(_destinationBitmapData);

			if (running) {
				setRegisters();
				onEnterFrame(this, onEnterFramePageTransition);
			}
		}
		
		
		
		protected function setRegisters():void {
			_context3D.setVertexBufferAt( 0, _startKeyVertices,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _finishKeyVertices,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va1
			_context3D.setVertexBufferAt( 2, _uvtVertices,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va2	
			_context3D.setTextureAt(0, _transitionSourceTexture); //fs0
			_context3D.setTextureAt(1, _transitionDestinationTexture); //fs1
			_context3D.setProgram(_pageTransitionShaderProgram);
		}
		
		
		protected function unSetRegisters():void {
			_context3D.setVertexBufferAt( 0, null ); //va0
			_context3D.setVertexBufferAt( 1, null ); //va1
			_context3D.setVertexBufferAt( 2, null ); //va2	
			_context3D.setTextureAt(0, null); //fs0
			_context3D.setTextureAt(1, null); //fs1
		}
		
		
		override public function enable():void {
			setRegisters();
		}
		
		
		override public function disable():void {
			unSetRegisters();
		}
		
		
		protected function power2(value:Number):Number {
			return Math.pow(2, Math.ceil(Math.log(value)/Math.LN2));
		}
		
		
		public function pageTransitionTextures(page0:Sprite, page1:Sprite, reverse:Boolean = false):void {
			var width:Number = _screen.stage.stageWidth;
			var height:Number = _screen.stage.stageHeight;
			var widthP2:Number = power2(scale*width);
			var heightP2:Number = power2(scale*height);
			
			if (page0 && page1) {
				
				var sourceBitmapData:BitmapData = new BitmapData(widthP2, heightP2, false, 0x333333);
				var destinationBitmapData:BitmapData = new BitmapData(widthP2, heightP2, false, 0x333333);
				
				saveTexture(sourceBitmapData, page0, new Rectangle(0, 0, width, height));
				saveTexture(destinationBitmapData, page1, new Rectangle(0, 0, width, height));
				
				_transitionSourceTexture = _context3D.createTexture(sourceBitmapData.width, sourceBitmapData.height, Context3DTextureFormat.BGRA, false);
				_transitionSourceTexture.uploadFromBitmapData(sourceBitmapData);
				
				_transitionDestinationTexture = _context3D.createTexture(destinationBitmapData.width, destinationBitmapData.height, Context3DTextureFormat.BGRA, false);
				_transitionDestinationTexture.uploadFromBitmapData(destinationBitmapData);

			}
			
			_context3D.setTextureAt(0, _transitionSourceTexture); //fs0
			_context3D.setTextureAt(1, _transitionDestinationTexture); //fs1
			_uvtVertices.uploadFromVector(uvt(width/widthP2, height/heightP2, reverse), 0, 8);
		}
		
		
		public function pageTransition(nextPage:Sprite, thisPage:Sprite, transition:String, reverse:Boolean = false):void {
			
			_transition = transition;
			if (transition == SIMPLE) {
				_uiPages.goToPage(_page);
				_page = -1;
				_screen.dispatchEvent(new Event(TRANSITION_COMPLETE));
				return;
			}
			
			pageTransitionTextures(nextPage, thisPage, reverse);

			switch(transition) {
				
				case SLIDE_LEFT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(LEFT_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(RIGHT_REGION.concat(SCREEN_REGION), 0, 8);
				break;
				
				case SLIDE_RIGHT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(RIGHT_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(LEFT_REGION.concat(SCREEN_REGION), 0, 8);
				break;

				case SLIDE_DOWN:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(BELOW_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(SCREEN_REGION.concat(SCREEN_REGION), 0, 8);
				break;
				
				case SLIDE_UP:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(SCREEN_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(BELOW_REGION.concat(SCREEN_REGION), 0, 8);
				break;
				
				case SWAP_LEFT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(LEFT_SCREEN_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(RIGHT_SCREEN_REGION.concat(SCREEN_REGION), 0, 8);
				break;
				
				case SWAP_RIGHT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(RIGHT_SCREEN_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(LEFT_SCREEN_REGION.concat(SCREEN_REGION), 0, 8);
				break;
							
				case CUBE_RIGHT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(RIGHT_CUBE), 0, 8);
					_finishKeyVertices.uploadFromVector(LEFT_CUBE.concat(SCREEN_REGION), 0, 8);
				break;
				
				case CUBE_LEFT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(LEFT_CUBE), 0, 8);
					_finishKeyVertices.uploadFromVector(RIGHT_CUBE.concat(SCREEN_REGION), 0, 8);
				break;

				case DOOR_RIGHT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(RIGHT_EDGE), 0, 8);
					_finishKeyVertices.uploadFromVector(LEFT_EDGE.concat(SCREEN_REGION), 0, 8);
				break;
				
				case DOOR_LEFT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(LEFT_EDGE), 0, 8);
					_finishKeyVertices.uploadFromVector(RIGHT_EDGE.concat(SCREEN_REGION), 0, 8);
				break;

				case TRASH_DOWN:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(SINGULARITY), 0, 8);
					_finishKeyVertices.uploadFromVector(SCREEN_REGION.concat(SCREEN_REGION), 0, 8);
		 		break;

				case TRASH_UP:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(SCREEN_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(SINGULARITY.concat(SCREEN_REGION), 0, 8);
		 		break;

				case FLIP_LEFT:
				case FLIP_RIGHT:
					_startKeyVertices.uploadFromVector(FLIPPED.concat(SCREEN_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(FLIPPED.concat(SCREEN_REGION), 0, 8);
		 		break;
				
				case SLIDE_OVER_UP:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(SCREEN_RECESSED), 0, 8);
					_finishKeyVertices.uploadFromVector(BELOW_REGION.concat(SCREEN_REGION), 0, 8);
		 		break;
				
				case SLIDE_OVER_DOWN:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(BELOW_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(SCREEN_RECESSED.concat(SCREEN_REGION), 0, 8);
				break;
				
				case SLIDE_OVER_LEFT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(SCREEN_RECESSED), 0, 8);
					_finishKeyVertices.uploadFromVector(RIGHT_REGION.concat(SCREEN_REGION), 0, 8);
		 		break;
				
				case SLIDE_OVER_RIGHT:
					_startKeyVertices.uploadFromVector(SCREEN_REGION.concat(RIGHT_REGION), 0, 8);
					_finishKeyVertices.uploadFromVector(SCREEN_RECESSED.concat(SCREEN_REGION), 0, 8);
				break;
			}

			_count = INCREMENT;
			setTransformation();

			UI.uiLayer.visible = false;
			activate(this);
			onEnterFrame(this, onEnterFramePageTransition);
		}
		
		
		public function customPageTransition(fromQuads:Vector.<Number>, toQuads:Vector.<Number>):void {
			_startKeyVertices.uploadFromVector(fromQuads, 0, 8);
			_finishKeyVertices.uploadFromVector(toQuads, 0, 8);
			
			_count = INCREMENT;
			setTransformation();

			UI.uiLayer.visible = false;
			activate(this);
			onEnterFrame(this, onEnterFramePageTransition);
		}
		
		
		public function opposite(transition:String = ""):String {
			var position:int;
			if (transition=="") {
				transition = _transition;
			}
			if ((position=transition.indexOf("Left"))>0) {
				return transition.substr(0,position)+"Right";
			}
			else if ((position=transition.indexOf("Right"))>0) {
				return transition.substr(0,position)+"Left";
			}
			else if ((position=transition.indexOf("Up"))>0) {
				return transition.substr(0,position)+"Down";
			}
			else if ((position=transition.indexOf("Down"))>0) {
				return transition.substr(0,position)+"Up";
			} 
			return SLIDE_UP;
		}
		
		
		public function goBack(nextPage:Sprite = null, thisPage:Sprite = null):void {
			pageTransition(nextPage, thisPage, opposite(_transition), true);
		}
		
		
		public function goToPage(uiPages:UIPages, page:int):void {
			_uiPages = uiPages;
			_page = page;
			_screen.dispatchEvent(new Event(TRANSITION_INITIAL));
		}
		
		
		protected function setTransformation(rotation:Number = 0.0):void {
			_finalMatrix.identity();
			_finalMatrix.appendRotation(rotation, Vector3D.Y_AXIS);
			_finalMatrix.appendTranslation(0, 0, ZOOM);
			_finalMatrix.append(_projectionMatrix);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _finalMatrix, true); //vc0 - vc3
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 0.0, 0.0, 0.0, 1.0 ]) ); //fc0
		}
			
		
		protected function onEnterFramePageTransition(event:Event = null):void {
			_context3D.clear(0x33/0xff,0x33/0xff,0x33/0xff);
			var easedCount:Number = easing(_count);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ easedCount, (1.0 - easedCount), 0.0, 1.0 ]) ); //vc4
			if (_transition==FLIP_LEFT) {
				setTransformation(_count*180);
			}
			else if (_transition==FLIP_RIGHT) {
				setTransformation(-_count*180);
			}
			_context3D.drawTriangles(_indexBuffer);
			_context3D.present();
			_count+=INCREMENT;
			if (_count>1.0) {
				completePageTransition();
			}
		}
		
		
		protected function completePageTransition():void {
			if (_uiPages && _page>=0) {
				_uiPages.goToPage(_page);
				_page = -1;
			}
			UI.uiLayer.visible = true;
			deactivate(this);
			_screen.dispatchEvent(new Event(TRANSITION_COMPLETE));
		}
		
		
		override public function destructor():void {
			super.destructor();
			_sourceBitmapData.dispose();
			_destinationBitmapData.dispose();
			_transitionSourceTexture.dispose();
			_transitionDestinationTexture.dispose();
		}
		
	}
}
