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
	
	
/**
 * MadComponents divided list
 * <pre>
 * &lt;dividedList
 *    id = "IDENTIFIER"
 *    colour = "#rrggbb"
 *    background = "#rrggbb, #rrggbb, ..."
 *    visible = "true|false"
 *    gapV = "NUMBER"
 *    gapH = "NUMBER"
 *    border = "true|false"
 *    lines = "true|false"
 *    pullDownRefresh = "true|false"
 *    pullDownColour = "#rrggbb"
 *    sortBy = "IDENTIFIER"
 *    mask = "true|false"
 *    alignV = "scroll|no scroll"
 *    highlightPressed = "true|false"
 *    autoLayout = "true|false"
 *    headingTextColour = "#rrggbb"
 *    headingShadowColour = "#rrggbb"
 * /&gt;
 * </pre>
 */	
	public class UIDividedList extends UIGroupedList {
		
		protected var _headingColour:uint;
		
		public function UIDividedList(screen:Sprite, xml:XML, attributes:Attributes) {
			_headingColour = (xml.@headingColour.length() > 0) ? UI.toColourValue(xml.@headingColour) : attributes.colour;
			super(screen, xml, attributes);
			doLayout();
		}
		
		
		override protected function drawCell(position:Number, count:int):void {
			drawSimpleCell(position, count);
		}
		
/**
 *  When a list row is clicked, display a highlight
 */	
		override protected function drawHighlight():void {
			if (_highlightPressed) {
				var groupDetails:Object = _groupPositions[_group];
				var autoLayout:Boolean = _autoLayoutGroup && !_simple;
				var top:Number = autoLayout ? _row.y - _attributes.paddingV +1 : groupDetails.top + _pressedCell * groupDetails.cellHeight;
				var bottom:Number = top + (autoLayout ? _row.height + 2 * _attributes.paddingV - 1 : groupDetails.cellHeight);
				_highlight.graphics.beginFill(HIGHLIGHT);
				_highlight.graphics.drawRect(_cellLeft, top, _cellWidth + 1, bottom - top);
			}
		}
		
		
		override protected function headingChrome():void {
			initDraw();
		}
		
/**
 *  Draw a group heading
 */	
		override protected function initDraw():void {
			var top:Number = _cellTop - 5 * _attributes.paddingV;
			var matr:Matrix=new Matrix();
			var gradient:Array = [Colour.lighten(_headingColour,64),_headingColour];
			var autoLayout:Boolean = (!_simple && _autoLayoutGroup);
			super.initDraw();
			var last:Number = _group>0 ? _groupPositions[_group-1].bottom + (autoLayout ? _attributes.paddingV : 0) : 0;

			var filling:Boolean = (top-last) > 2;
			matr.createGradientBox(_width, 4 * _attributes.paddingV, Math.PI/2, 0, top);
			_slider.graphics.beginGradientFill(GradientType.LINEAR, gradient, [1.0,1.0], [0x00,0xff], matr);
			_slider.graphics.drawRect(0, top, _width, 5 * _attributes.paddingV + 1);
			if (filling) {
				_slider.graphics.drawRect(0, last, _width, top-last);
			}
			_slider.graphics.beginFill(_colour);
			_slider.graphics.drawRect(0, filling ? last : top, _width, 1);
			_slider.graphics.beginFill(Colour.darken(_colour,-32));
			_slider.graphics.drawRect(0, _cellTop, _width, 1);
			_gapBetweenGroups = (autoLayout ? -2 * _attributes.paddingV : -_attributes.paddingV) - 1;
		}
		
/**
 *  Draw the background
 */	
		override public function drawComponent():void {
			if (_colours && _colours.length>0) {
				graphics.beginFill(_colours[0]);
			}
			else {
				graphics.beginFill(0,0);
			}
			graphics.drawRect(0, 0, _attributes.width, _attributes.height);
		}

/**
 *  Set up the scrolling part of the list
 */	
		override protected function initDrawGroups():void {
			_slider.graphics.clear();
			resizeRefresh();
		}
		
	}
}