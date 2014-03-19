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
	import com.danielfreeman.extendedMadness.UIWheelMenu;
	import com.danielfreeman.extendedMadness.UIe;
	import com.danielfreeman.madcomponents.IContainerUI;
	import com.danielfreeman.madcomponents.UI;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

/**
 *  Just displays a Stage3D rectangle.  But in continually refreshing that rectangle, we ensure that display list graphics are also refreshed.
 *  (On mobile Stage3D synchs Display List - so if Stage3D ceases - so does the display list!
 */
	public class WheelMenu extends Stage3DAcceleration {
		
		protected static const ZOOM:Number = 1.73;
	
		protected var _indexBuffer:IndexBuffer3D;
		protected var _uvBuffer:VertexBuffer3D;
		protected var _vertexBuffer:VertexBuffer3D;

		protected var _colour:uint;
		protected var _uv:Vector.<Number>;
		protected var _vertices:Vector.<Number>;
		protected var _textureBitmapData:BitmapData;
		protected var _forwardBitmapData:BitmapData;
		protected var _backwardBitmapData:BitmapData;
		protected var _wheelMenuTexture:Texture;
		protected var _wheelForwardTexture:Texture;
		protected var _wheelBackwardTexture:Texture;
		protected var _radius:Number;
		protected var _wheelMenu:UIWheelMenu;
		protected var _wheelMenuVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _wheelMenuFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _wheelMenuShaderProgram:Program3D;
		protected var _finalMatrix:Matrix3D = new Matrix3D();
		protected var _projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		protected var _pivotPoint:Vector3D;
				
		protected var _holes:Vector.<IContainerUI> = new Vector.<IContainerUI>();


		public function WheelMenu(wheelMenu:UIWheelMenu = null, colour:uint = 0xFFFFFF) {

			_wheelMenuVertexShader.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0 \n" +				// output vertex
				"mov v0, va1 \n"				// absolute and interpolate
			);
			
			_wheelMenuFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"tex ft0, v0.xy, fs0 <2d,linear,nomip> \n" +
				"tex ft1, v0.xy, fs1 <2d,linear,nomip> \n" +
				"tex ft2, v0.xy, fs2 <2d,linear,nomip> \n" +
				"mul ft0, ft0, fc0.xxxx \n" +
				"mul ft1, ft1, fc0.yyyy \n" +
				"mul ft2, ft2, fc0.zzzz \n" +
				"add ft0, ft0, ft1 \n" +
				"add oc, ft0, ft2 \n"
			);
			
			_finalMatrix.identity();
			_projectionMatrix.perspectiveFieldOfViewLH(60.0*Math.PI/180, _aspectRatio, 0.1, 1000.0);
			
			if (wheelMenu) {
				wheelTexture(wheelMenu, colour);
			}
		}
		
		
/**
 * Set background colour
 */
		public function set backgroundColour(value:uint):void {
			_colour = value;
		}
		
		
		public function wheelTexture(wheelMenu:UIWheelMenu, colour:uint = 0xFFFFFF):void {
			_colour = colour;
			_wheelMenu = wheelMenu;
			
			if (!_wheelMenu.forwardBitmap) {
				_wheelMenu.enableMotionBlur();
			}
			
			var textureSize:Number = power2(UI.scale * _wheelMenu.radius * 2);
			var u:Number = UI.scale * 2 * _wheelMenu.radius / textureSize;
			var v:Number = UI.scale * 2 * _wheelMenu.radius / textureSize;
			_textureBitmapData = new BitmapData(textureSize, textureSize, true, 0x00000000);
			saveTexture(_textureBitmapData, _wheelMenu.segmentLayer, new Rectangle(0, 0, 2 * UI.scale * _wheelMenu.radius, 2 * UI.scale * _wheelMenu.radius ), UI.scale * _wheelMenu.radius, UI.scale * _wheelMenu.radius);

			_wheelMenu.forwardBitmap.visible = true;
			_forwardBitmapData = new BitmapData(textureSize, textureSize, true, 0x00000000);
			saveTexture(_forwardBitmapData, _wheelMenu.forwardBitmap, new Rectangle(0, 0, 2 * UI.scale * _wheelMenu.radius, 2 * UI.scale * _wheelMenu.radius ));
			_wheelMenu.forwardBitmap.visible = false;

			_wheelMenu.backwardBitmap.visible = true;
			_backwardBitmapData = new BitmapData(textureSize, textureSize, true, 0x00000000);
			saveTexture(_backwardBitmapData, _wheelMenu.backwardBitmap, new Rectangle(0, 0, 2 * UI.scale * _wheelMenu.radius, 2 * UI.scale * _wheelMenu.radius ));
			_wheelMenu.backwardBitmap.visible = false;

			_uv = Vector.<Number>([
			//	U,	V
				0, 	v,
				u,	v,
				u,	0,
				0,	0
			]);
			
			var globalXY:Point = _wheelMenu.segmentLayer.localToGlobal(new Point(0, 0));
		//	globalXY.x *= UI.scale; globalXY.y *= UI.scale;
			var nWidth:Number = _screen.stage.stageWidth;
			var nHeight:Number = _screen.stage.stageHeight;
			var left:Number = _aspectRatio * (2 * (globalXY.x - UI.scale * _wheelMenu.radius) / nWidth - 1);
			var right:Number = _aspectRatio * (2 * (globalXY.x + UI.scale * _wheelMenu.radius) / nWidth - 1);
			var top:Number = - 2 * (globalXY.y + UI.scale *_wheelMenu.radius) / nHeight + 1;
			var bottom:Number = - 2 * (globalXY.y - UI.scale *_wheelMenu.radius) / nHeight + 1;
			_vertices = Vector.<Number> ([
			//	X,			Y,			Z,
				left,		top,		0.0,
				right,		top,		0.0,
				right,		bottom,		0.0,
				left,		bottom,		0.0
			]);
			
			_pivotPoint = new Vector3D(_aspectRatio * ( 2 * globalXY.x / nWidth - 1), -2 * globalXY.y / nHeight + 1);
			
			contextResumed(false);
			activate(this);
		}
		
/**
 *  If we've lost context, refresh shaders and streams
 */
		override public function contextResumed(running:Boolean):void {

			_wheelMenuShaderProgram = _context3D.createProgram();
			_wheelMenuShaderProgram.upload( _wheelMenuVertexShader.agalcode, _wheelMenuFragmentShader.agalcode);
			
			_uvBuffer = _context3D.createVertexBuffer(4, 2);
			_uvBuffer.uploadFromVector(_uv, 0, _uv.length / 2);

			_vertexBuffer = _context3D.createVertexBuffer(4, 3);
			_vertexBuffer.uploadFromVector(_vertices, 0, _vertices.length / 3);

			var indices:Vector.<uint> = Vector.<uint> ([ 0, 1, 2,	0, 2, 3 ]);
			_indexBuffer = _context3D.createIndexBuffer( indices.length );
			_indexBuffer.uploadFromVector(indices, 0, indices.length );

			_wheelMenuTexture = _context3D.createTexture(_textureBitmapData.width, _textureBitmapData.height, Context3DTextureFormat.BGRA, false);
			_wheelMenuTexture.uploadFromBitmapData(_textureBitmapData);
			
			_wheelForwardTexture = _context3D.createTexture(_textureBitmapData.width, _textureBitmapData.height, Context3DTextureFormat.BGRA, false);
			_wheelForwardTexture.uploadFromBitmapData(_forwardBitmapData);
			
			_wheelBackwardTexture = _context3D.createTexture(_textureBitmapData.width, _textureBitmapData.height, Context3DTextureFormat.BGRA, false);
			_wheelBackwardTexture.uploadFromBitmapData(_backwardBitmapData);			

			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			_context3D.setDepthTest(false, Context3DCompareMode.LESS);

			if (running) {
				enable();
			}
		}
		

		override public function enable():void {
			_context3D.setVertexBufferAt( 0, _vertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			_context3D.setTextureAt(0, _wheelMenuTexture);
			_context3D.setTextureAt(1, _wheelForwardTexture);
			_context3D.setTextureAt(2, _wheelBackwardTexture);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1.0, 0.0, 0.0, 1.0 ]) );	// fc0
			_context3D.setProgram(_wheelMenuShaderProgram);
			onEnterFrame(this, updateFrame);
			pokeHole(_wheelMenu);
		}
		
			
		override public function disable():void {
			_context3D.setVertexBufferAt( 0, null ); //va0
			_context3D.setVertexBufferAt( 1, null ); //va0
			fillHoles();
		}
				
/**
 * Cut a hole in a particular container background so that the accelerated list is visible underneath.
 */	
		public function cutRectangle(container:Sprite, rectangle:Rectangle):void {
			var topLeft:Point = container.globalToLocal(new Point(rectangle.x, rectangle.y));
		//	if (container is com.danielfreeman.extendedMadness.UIPanel) container.graphics.beginFill(0xffff00);
			container.graphics.drawRect(topLeft.x, topLeft.y, rectangle.width, rectangle.height);
			if (container is IContainerUI && _holes.indexOf(IContainerUI(container)) < 0) {
				_holes.push(container);
			}
		}
		
/**
 * Put a hole in the MadComponents display-list UI, so you can see the accelerated wheel menu
 */	
		public function pokeHole(component:UIWheelMenu, rectangle:Rectangle = null, container:Sprite = null):void {
			if (!rectangle) {
				component.segmentLayer.rotation = 0;
				var point:Point = component.segmentLayer.localToGlobal(new Point(-component.radius, -component.radius));
				rectangle = new Rectangle(point.x, point.y, component.radius * 2, component.radius * 2);
				container = component;
			}
			if (container.name=="+" || container.name=="-") {
				container.graphics.clear();
			}
			else {
				if (container != UI.uiLayer && container is IContainerUI && IContainerUI(container).attributes.backgroundColours.length> 0) {
					cutRectangle(container, rectangle);
				}
			}
			if (container == UI.uiLayer) {
				cutRectangle(UI.uiLayer, rectangle);
				component.segmentLayer.visible = false;
			}
			else {
				pokeHole(component, rectangle, Sprite(container.parent));
			}
		}
		
		
		protected function fillHoles():void {
			for each (var container:IContainerUI in _holes)
				if (Sprite(container).name != "+" && Sprite(container).name != "-") {
					container.drawComponent();
			}
		}


		protected function updateFrame(event:Event):void {
			_finalMatrix.identity();
			_finalMatrix.appendRotation(-_wheelMenu.wheelRotation, Vector3D.Z_AXIS, _pivotPoint);
			_finalMatrix.appendTranslation(0, 0, ZOOM);
			_finalMatrix.append(_projectionMatrix);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _finalMatrix, true); //vc0 - vc3
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([(_wheelMenu.forwardBlur || _wheelMenu.backwardBlur) ? 0.0 : 1.0, _wheelMenu.forwardBlur ? 1.0 : 0.0, _wheelMenu.backwardBlur ? 1.0 : 0.0, 1.0 ]) );	// fc0
			_context3D.clear((_colour>>32 & 0xff)/0xff, (_colour>>16 & 0xff)/0xff, (_colour & 0xff)/0xff);
			_context3D.drawTriangles(_indexBuffer);
			_context3D.present();
		}
		
		
		public static const READY:String = "wheelReady";

		protected static var _wheelMenu:WheelMenu;
		protected static var _menu:UIWheelMenu = null;
		protected static var _screenS:Sprite;
		protected static var _colourS:uint = 0xFFFFFF;
		
		
		public static function create(screen:Sprite, xml:XML, width:Number = -1, height:Number = -1):Sprite {
			_screenS = screen;
			var result:Sprite = UIe.create(screen, xml, width, height);
			if (xml.@stageColour.length() > 0) {
				_colourS = UI.toColourValue(xml.@stageColour);
			}
			screen.addEventListener(Stage3DAcceleration.CONTEXT_COMPLETE, contextComplete);
			Stage3DAcceleration.startStage3D(screen);
			return result;
		}
		
		
		protected static function contextComplete(event:Event):void {
			_screenS.removeEventListener(Stage3DAcceleration.CONTEXT_COMPLETE, contextComplete);
			_menu = UIWheelMenu(UI.findViewById("@menu"));
			_wheelMenu = new WheelMenu(_menu, _colourS);
			_screenS.dispatchEvent(new Event(READY));
		}
		
		
		public static function get wheelMenu():WheelMenu {
			return _wheelMenu;
		}
		
		
		public static function get menu():UIWheelMenu {
			return _menu;
		}

	}
}
