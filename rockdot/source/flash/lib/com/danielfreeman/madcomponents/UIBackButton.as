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

package com.danielfreeman.madcomponents {
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	
/**
 * Arrow button, as used in the navigation bar (for both forward and back buttons)
 */	
	public class UIBackButton extends Sprite {
		
		protected static const FORMAT:TextFormat = new TextFormat("Arial",14,0xFFFFFF);
		protected static const HEIGHT:Number = 33.0;
		protected static const ARROW:Number = 10.0;
		protected static const CURVE:Number = 5.0;
		protected static const X:Number = 12.0;
		protected static const Y:Number = 6;
		
		public static const ADJUSTMENT:Number = 0.0;
		
		protected var _label:UILabel;
		protected var _colour:uint;
		protected var _forward:Boolean;
		protected var _height:Number = HEIGHT;
	
		public function UIBackButton(screen:Sprite, xx:Number, yy:Number, text:String, colour:uint, forward:Boolean = false) {
			screen.addChild(this);
			_forward = forward;
			_colour = colour;
			_label = new UILabel(this, X, Y, "", FORMAT);
			x=xx;y=yy;
			this.text = text;
			buttonMode = useHandCursor = true;
		}
		
/**
 * Set the text label of the button
 */	
		public function set text(value:String):void {
			_label.text = value;
			synthButton(_label.width + 20);
		}
		
		
		public function get text():String {
			return _label.text;
		}
		
/**
 * Set the text format of the button label
 */	
		public function set textFormat(value:TextFormat):void {
			_label.defaultTextFormat = value;
			_label.setTextFormat(value);
		}
		
/**
 * Set colour of the button
 */	
		public function set colour(value:uint):void {
			_colour = value;
			synthButton(_label.width + 20);
		}
		
/**
 * Render the button
 */	
		protected function synthButton(width:int):void {
			graphics.clear();
			var matr:Matrix=new Matrix();
			var buttonWidth:Number = Math.round(width/8)*8+2;
			matr.createGradientBox(width, HEIGHT, Math.PI/2, 0, 0);
		//	graphics.beginGradientFill(GradientType.LINEAR, [Colour.darken(_colour,-32),Colour.lighten(_colour, 0)], [1.0,1.0], [0x00,0xff], matr);
			graphics.beginFill(Colour.darken(_colour));
			var x:Number = _forward ? 0.0 : 2.0;
			buttonShape(x, 0.0, buttonWidth, _height);

			var gradient:Array = [Colour.lighten(_colour),Colour.darken(_colour),Colour.darken(_colour)];
			graphics.beginGradientFill(GradientType.LINEAR, gradient, [1.0,1.0,1.0], [0x00,0x80,0xff], matr);
			buttonShape(x, 1.0, buttonWidth-1, _height-1.5);
			_label.x = ( buttonWidth - _label.width ) / 2 + ( _forward ? -3 : 4 );
		}
		
/**
 * Create the basic button shape
 */	
		protected function buttonShape(x:Number,y:Number,buttonWidth:Number,height:Number):void {
			var quotient:Number = (ARROW-CURVE)/ARROW;
			var s:Number = _forward ? -1.0 : 1.0;
			var adjustment:Number = _forward ? 0.0 : ADJUSTMENT;
			if (_forward)
				x+= buttonWidth;
			graphics.moveTo(x,_height/2);
			graphics.lineTo(x+s*quotient*ARROW,y+(1-quotient)*_height/2);
			graphics.curveTo(x+s*ARROW,y,x+s*(ARROW+CURVE),y);
			graphics.lineTo(x+s*(buttonWidth-CURVE),y);
			graphics.curveTo(x+s*buttonWidth,y,x+s*buttonWidth,y+CURVE);
			graphics.lineTo(x+s*buttonWidth+adjustment,y+height-CURVE);
			graphics.curveTo(x+s*buttonWidth,y+height,x+s*(buttonWidth-CURVE),y+height);
			graphics.lineTo(x+s*(ARROW+CURVE),y+height);
			graphics.curveTo(x+s*ARROW,y+height,x+s*quotient*ARROW,y+height-(1-quotient)*_height/2);
			graphics.lineTo(x,_height/2);
		}
	}
}
