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
	import com.danielfreeman.madcomponents.UIWindow;

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
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	public class PanelScaling extends Stage3DAcceleration {

		public static const SCALE_COMPLETE:String = "scaleComplete";
		public static const REVERSE_COMPLETE:String = "reverseComplete";

		protected static const QUADS:int = 2;
		protected static const INCREMENT:Number = 0.1;
		protected static const POPUP_INCREMENT:Number = 0.2;
		protected static const POPUP_SMALL:Number = 0.7;

		protected var _backgroundTextureBitMapData:BitmapData;
		protected var _sourcePanelTextureBitMapData:BitmapData;
		protected var _destinationPanelTextureBitMapData:BitmapData;
		
		protected var _indexBuffer:IndexBuffer3D;
		protected var _startKeyVertexBuffer:VertexBuffer3D;
		protected var _finishKeyVertexBuffer:VertexBuffer3D;
		protected var _uvtStartVertexBuffer:VertexBuffer3D;
		protected var _uvFinishVertexBuffer:VertexBuffer3D;

		protected var _panelScalingVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _panelScalingFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _panelScalingShaderProgram:Program3D;
		
		protected var _backgroundTexture:Texture;
		protected var _sourcePanelTexture:Texture;
		protected var _destinationPanelTexture:Texture = null;

		protected var _backgroundRectangle:Rectangle;
		protected var _sourcePanelRectangle:Rectangle;
		protected var _destinationPanelRectangle:Rectangle;
		
		protected var _count:Number = 0.0;
		protected var _backgroundColour:uint = 0xFFFFFFFF;
		protected var _reverse:Boolean = false;
		protected var _window:UIWindow = null;
		protected var _popUp:Boolean = false;
		protected var _deactivate:Boolean = false;

/**
 * This class impliments two animated transitions that may be applied to MadComponents forms.
 * 
 * The first is a panel scaling effect that's often seen on Tablet UIs.
 * There is an animated resizing, combined with a cross-fade of the UI appearance.
 * 
 * The second transition is for pop-up windows that appear to properly pop-out.  A rapid scale effect.
 */
		public function PanelScaling() {
			initialise();
		}
		
/**
 * The vertex shader impliments a tween between two sets of vertices, and a tween between two sets of UV values.
 * 
 * The fragment shader impliments a cross-fade between two textures, or optionally dispalys a third, non-cross-faded texture.
 */
		public function initialise():void {

			_panelScalingVertexShader.assemble( Context3DProgramType.VERTEX,
				"mul vt0, va0, vc0.yyyy \n" +	// t * start position
				"mul vt1, va1, vc0.xxxx \n" +	// (1-t) * end position
				"add op, vt0, vt1 \n" +			// add
				
				"mov v0, va2 \n" +				// interpolate UVT
				
				"mul vt0, va2, vc0.yyyy \n" +	// t * start position
				"mul vt1, va3, vc0.xxxx \n" +	// (1-t) * end position
				"add v1, vt0, vt1 \n"			// add
				
			);
			
			_panelScalingFragmentShader.assemble( Context3DProgramType.FRAGMENT,

				"tex ft0, v0.xy, fs0 <2d,linear,nomip> \n"	+	// texture 0
				"tex ft1, v0.xy, fs1 <2d,linear,nomip> \n"	+	// texture 1
				"tex ft2, v1.xy, fs2 <2d,linear,nomip> \n"	+	// texture 2
				"mul ft1, ft1, fc0.yyyy \n" +				// t * start position
				"mul ft2, ft2, fc0.xxxx \n" +				// (1-t) * end position
				"add ft1, ft1, ft2 \n" +					// add

				"mul ft0, ft0, v0.zzzz \n" +
				"sub ft2.x, fc0.w, v0.z \n" +				// Option to use texture0
				"mul ft1, ft1, ft2.xxxx \n" +
				"add oc, ft0, ft1 \n"
			);
			
			_panelScalingShaderProgram = _context3D.createProgram();
			_panelScalingShaderProgram.upload( _panelScalingVertexShader.agalcode, _panelScalingFragmentShader.agalcode);

			_startKeyVertexBuffer = _context3D.createVertexBuffer(QUADS * 4, 3);
			_finishKeyVertexBuffer = _context3D.createVertexBuffer(QUADS * 4, 3);
			_uvtStartVertexBuffer = _context3D.createVertexBuffer(QUADS * 4, 3);
			_uvFinishVertexBuffer = _context3D.createVertexBuffer(QUADS * 4, 2);
			
			var indices:Vector.<uint> = Vector.<uint> ([ 0, 1, 2,	0, 2, 3,    4, 5, 6,	4, 6, 7]);
			_indexBuffer = _context3D.createIndexBuffer( indices.length );
			_indexBuffer.uploadFromVector(indices, 0, indices.length );
		}

/**
 * Set the Stage3D background colour
 */
		public function set backgroundColour(value:uint):void {
			_backgroundColour = value;
		}
		
/**
 * Apply scale to rectange width and height
 */
		protected function applyScale(rectangle:Rectangle):void {
			rectangle.width*=UI.scale;
			rectangle.height*=UI.scale;
		}
		
/**
 * Upload background texture
 */
		public function backgroundTexture(panel:IContainerUI):void {
			_backgroundRectangle = new Rectangle(0, 0, _screen.stage.stageWidth, _screen.stage.stageHeight);
			_backgroundTextureBitMapData = new BitmapData(power2(_backgroundRectangle.width), power2(_backgroundRectangle.height), false, _backgroundColour);
			saveTexture(_backgroundTextureBitMapData, Sprite(panel), _backgroundRectangle);
			_backgroundTexture = _context3D.createTexture(_backgroundTextureBitMapData.width, _backgroundTextureBitMapData.height, Context3DTextureFormat.BGRA, false);
			_backgroundTexture.uploadFromBitmapData(_backgroundTextureBitMapData);
			
		}
		
/**
 * Upload souce panel texture for cross-fade scale effect
 */
		public function sourcePanelBackground(panel:IContainerUI):void {
			var globalPoint:Point = Sprite(panel).localToGlobal(new Point(0,0));
			_sourcePanelRectangle = new Rectangle(globalPoint.x, globalPoint.y, panel.attributes.width + (panel.xml.@border=="true" ? 2*UI.PADDING : 0), panel.attributes.height + (panel.xml.@border=="true" ? 2*UI.PADDING : 0));
			applyScale(_sourcePanelRectangle);
			_sourcePanelTextureBitMapData = new BitmapData(power2(_sourcePanelRectangle.width), power2(_sourcePanelRectangle.height), false, _backgroundColour);
			saveTexture(_sourcePanelTextureBitMapData, Sprite(panel), new Rectangle(0, 0, _sourcePanelRectangle.width, _sourcePanelRectangle.height));
			_sourcePanelTexture = _context3D.createTexture(_sourcePanelTextureBitMapData.width, _sourcePanelTextureBitMapData.height, Context3DTextureFormat.BGRA, false);
			_sourcePanelTexture.uploadFromBitmapData(_sourcePanelTextureBitMapData);
			
		}
		
/**
 * Upload destination panel texture for cross-fade scale effect
 */
		public function destinationPanelBackground(panel:IContainerUI):void {
			var globalPoint:Point = Sprite(panel).localToGlobal(new Point(0,0));
			_destinationPanelRectangle = new Rectangle(globalPoint.x, globalPoint.y, panel.attributes.width + (panel.xml.@border=="true" ? 2*UI.PADDING : 0), panel.attributes.height + (panel.xml.@border=="true" ? 2*UI.PADDING : 0));
			applyScale(_destinationPanelRectangle);
			_destinationPanelTextureBitMapData = new BitmapData(power2(_destinationPanelRectangle.width), power2(_destinationPanelRectangle.height), false, _backgroundColour);
			saveTexture(_destinationPanelTextureBitMapData, Sprite(panel), new Rectangle(0, 0, _destinationPanelRectangle.width, _destinationPanelRectangle.height));				
			_destinationPanelTexture = _context3D.createTexture(_destinationPanelTextureBitMapData.width, _destinationPanelTextureBitMapData.height, Context3DTextureFormat.BGRA, false);
			_destinationPanelTexture.uploadFromBitmapData(_destinationPanelTextureBitMapData);
			
		}
		
/**
 * A 2x2 quad
 */
		protected function fill():Vector.<Number> {
			return Vector.<Number> ([
			//	X,				Y,				Z,
				-1.0,			-1.0,			0.02,
				1.0,			-1.0,			0.02,
				1.0,			1.0,			0.02,
				-1.0,			1.0,			0.02
			]);
		}
		
/**
 * A scaled quad converted to Stage3D coordinates
 */
		protected function quad(rectangle:Rectangle, multiplier:Number = 1.0):Vector.<Number> {
			return Vector.<Number> ([
				multiplier*toGraphX(rectangle.x),						-multiplier*toGraphY(rectangle.y+rectangle.height),		0.01,
				multiplier*toGraphX(rectangle.x+rectangle.width),		-multiplier*toGraphY(rectangle.y+rectangle.height),		0.01,
				multiplier*toGraphX(rectangle.x+rectangle.width),		-multiplier*toGraphY(rectangle.y),							0.01,
				multiplier*toGraphX(rectangle.x),						-multiplier*toGraphY(rectangle.y),							0.01
			]);
		}
		
/**
 * Generate UV values
 */
		protected function uv(rectangle:Rectangle):Vector.<Number> {
			var textureRight:Number = rectangle.width / power2(rectangle.width);
			var textureBottom:Number = rectangle.height / power2(rectangle.height);
			return Vector.<Number> ([
				0, 				textureBottom,
				textureRight,	textureBottom,
				textureRight,	0,
				0,				0
			]);
		}
		
/**
 * Generate UV values with a flag which indicates which texture to use
 */
		protected function uvt(rectangle:Rectangle, flag:Number):Vector.<Number> {
			var textureRight:Number = rectangle.width / power2(rectangle.width);
			var textureBottom:Number = rectangle.height / power2(rectangle.height);
			return Vector.<Number> ([
				0, 				textureBottom,		flag,
				textureRight,	textureBottom,		flag,
				textureRight,	0,					flag,
				0,				0,					flag
			]);
		}
		
/**
 * Do scale / cross-fade effect
 */
		protected function doScaleEffect(reverse:Boolean = false, popUp:Boolean = false):void {
			_reverse = reverse;
			_popUp = popUp;
			_deactivate = false;
			
			var startKeyVertices:Vector.<Number> = fill().concat(quad(_sourcePanelRectangle, popUp ? POPUP_SMALL : 1.0));
			_startKeyVertexBuffer.uploadFromVector(startKeyVertices, 0, startKeyVertices.length/3);
			
			var finishKeyVertices:Vector.<Number> = fill().concat(popUp ? quad(_sourcePanelRectangle) : quad(_destinationPanelRectangle));
			_finishKeyVertexBuffer.uploadFromVector(finishKeyVertices, 0, finishKeyVertices.length/3);
			
			var uvtStartVertices:Vector.<Number> = uvt(_backgroundRectangle, 1.0).concat(uvt(_sourcePanelRectangle, 0.0));
			_uvtStartVertexBuffer.uploadFromVector(uvtStartVertices, 0, uvtStartVertices.length/3);
			
			var uvFinishVertices:Vector.<Number> = uv(_backgroundRectangle).concat(uv(popUp ? _sourcePanelRectangle : _destinationPanelRectangle));
			_uvFinishVertexBuffer.uploadFromVector(uvFinishVertices, 0, uvFinishVertices.length/2);

			_count = _reverse ? 1.0 : 0.0;
			UI.uiLayer.visible = false;
			
			activate(this);
			onEnterFrame(this, onEnterFrameScaleTransition);
		}
		
/**
 * Activate scale effect
 */
		public function scaleEffect():void {
			doScaleEffect(false);
		}
		
/**
 * Activate inverse scale effect
 */
		public function goBack():void {
			doScaleEffect(true);
		}
		
/**
 * Activate pop-up window effect
 */
		public function popUp(window:UIWindow):void {
			UI.showPopUp(window);
			_window = window;
			UI.uiLayer.visible = false;
			UI.windowLayer.visible = false;
			doScaleEffect(false, true);
		}
		
		
		override public function enable():void {
			_context3D.setVertexBufferAt( 0, _startKeyVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _finishKeyVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 ); //va1
			_context3D.setVertexBufferAt( 2, _uvtStartVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 ); //va2
			_context3D.setVertexBufferAt( 3, _uvFinishVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 ); //va3
			_context3D.setTextureAt(0, _backgroundTexture); //fs0
			_context3D.setTextureAt(1, _sourcePanelTexture); //fs1
			_context3D.setTextureAt(2, _popUp ? _sourcePanelTexture : _destinationPanelTexture); //fs2
			_context3D.setProgram(_panelScalingShaderProgram);
		}
		
		
		override public function disable():void {
			_context3D.setVertexBufferAt( 0, null ); //va0
			_context3D.setVertexBufferAt( 1, null ); //va1
			_context3D.setVertexBufferAt( 2, null ); //va2
			_context3D.setVertexBufferAt( 3, null ); //va3
			_context3D.setTextureAt(0, null); //fs0
			_context3D.setTextureAt(1, null); //fs1
			_context3D.setTextureAt(2, null); //fs2
		}
		
/**
 * Render effect
 */
		protected function onEnterFrameScaleTransition(event:Event = null):void {
			_context3D.clear((_backgroundColour>>32 & 0xff)/0xff, (_backgroundColour>>16 & 0xff)/0xff, (_backgroundColour & 0xff)/0xff);
			var easedCount:Number = easing(_count);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([ easedCount, (1.0 - easedCount), 0.0, 1.0 ]) ); //vc0
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ easedCount, (1.0 - easedCount), 0.0, 1.0 ]) ); //fc0
			_context3D.drawTriangles(_indexBuffer);
			_context3D.present();
			_count += _window ? POPUP_INCREMENT : (_reverse ? -INCREMENT : INCREMENT);

			if (_deactivate) {
				deactivate(this);
			}
			else if (_count>1.0) {
				completeScaleTransition();
			}
			else if (_count<0.0) {
				completeReverseTransition();
			}
		}
		
/**
 * Scale / cross-fade transition is complete
 */
		protected function completeScaleTransition():void {
			_count = 1.0;_deactivate = true;
			_screen.dispatchEvent(new Event(SCALE_COMPLETE));
			UI.uiLayer.visible = true;
			if (_window) {
				UI.windowLayer.visible = true;
				_window = null;
			}
		}
		
/**
 * Inverse scale / cross-fade transition is complete
 */
		protected function completeReverseTransition():void {
			_count = 0.0;_deactivate = true;
		//	deactivate(this);
			_screen.dispatchEvent(new Event(REVERSE_COMPLETE));
			UI.uiLayer.visible = true;
		}
		
		
		override public function destructor():void {
			super.destructor();
			_backgroundTextureBitMapData.dispose();
			_sourcePanelTextureBitMapData.dispose();
			_destinationPanelTextureBitMapData.dispose();
		}

	}
}
