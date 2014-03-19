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

	import flash.display.BitmapData;

/**
 * A record/struct, utilised by ListScrolling classes
 */
	public class ListRecord {
		
		import com.danielfreeman.madcomponents.*;
		import flash.display.BitmapData;

		public var container:IContainerUI;
		public var uvWidth:Number;
		public var uvHeight:Number;
		public var textureHeight:Number;
		public var onScreen:Boolean = false;
		public var isMoving:Boolean = false;
		public var textureIndex:int;

		public var inertia:Boolean = false;
		public var delta:Number = 0;
		public var destination:Number = Number.NaN;
		
		public var showPressed:Boolean;
		
		public var lastRowIndex:int = -1;
		public var firstRowIndex:int = -1;
		
		public var background:BitmapData = null;
		public var recycle:Boolean;
		public var lazyRender:Boolean;
		public var motionBlur:int = -1;
		
		public var finalTexture:int = 0;


		public function ListRecord(container:IContainerUI, textureIndex:int, showPressed:Boolean, uvWidth:Number = 0, uvHeight:Number= 0, textureHeight:Number = 0) {
			this.container = container;
			this.uvHeight = uvHeight;
			this.uvWidth = uvWidth;
			this.textureHeight = textureHeight;
			this.textureIndex = textureIndex;
			this.showPressed = showPressed;
		}
	}
}
