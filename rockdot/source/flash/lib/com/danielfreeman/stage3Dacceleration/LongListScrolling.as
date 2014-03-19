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
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UIGroupedList;
	import com.danielfreeman.madcomponents.UIList;
	import com.danielfreeman.madcomponents.UILongList;
	import com.danielfreeman.madcomponents.UIPicker;
	import com.danielfreeman.madcomponents.UIScrollVertical;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	public class LongListScrolling extends ListScrolling {
		
		protected static const STRIP_HEIGHT:Number = 128.0;
		protected static const MOTION_BLUR_DIVISOR:Number = 16.0;
		
		protected static const MOTION_K0:Number = 0.5;
		protected static const MOTION_K1:Number = 0.15;
		protected static const MOTION_K2:Number = 0.1;  // k0 + 2 ( k1 + k2 ) always = 1.0
		
		protected static const FAST_MOTION_K0:Number = 0.09;
		protected static const FAST_MOTION_K1:Number = 0.19;
		protected static const FAST_MOTION_K2:Number = 0.24;
		protected static const FAST_MOTION_AMOUNT:Number = 0.3;
		
		protected static const EXTRA:Number = 16.0;
		protected static const SCROLLBAR_POSITION:Number = 1.0;
		protected static const SCROLLBAR_WIDTH:Number = 6.0;
		protected static const FAST_INDEX_DIFFERENCE:int = 1;
		protected static const SHOW_SCROLLBAR_DELTA:Number = 2.0; 
		
		protected static const VERY_FAST_SCHEME:Boolean = true;
		protected static const SLOW:Number = 32.0;
		protected static const QUALITY:Number = 1.0;
		
		protected static const DEBUG:Boolean = false;
		
		protected var _listRowBitmapData:Vector.<Vector.<BitmapData>> = new Vector.<Vector.<BitmapData>>();
		protected var _listRowTextures:Vector.<Vector.<Texture>> = new Vector.<Vector.<Texture>>();
		protected var _recycleRow:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
		protected var _scrollbarTextures:Vector.<Texture> = new Vector.<Texture>();
		
		protected var _xyzVertexBuffersAll:Vector.<VertexBuffer3D>;
		protected var _uvVertexBuffersAll:Vector.<VertexBuffer3D>;
		
		protected var _positionCurrent:Number = 0;
		protected var _positionNext:Number = 0;
		protected var _backgroundColour:uint = 0xFFFFFF;
		
		protected var _showCursor:Boolean = true;
		protected var _cursorVertices:VertexBuffer3D = null;
		protected var _cursorUV:VertexBuffer3D = null;
		protected var _cursorTexture:Texture;
		protected var _fastScrolling:Boolean = VERY_FAST_SCHEME;
		protected var _fastScrollingThreshold:int = FAST_INDEX_DIFFERENCE;
		protected var _wasGoingVeryFast:Boolean = false;
		protected var _reloadIncremental:int = -1;
		protected var _quality:Number = QUALITY;

		
/**
 * This refinement on the PageFlipping class divides every list into strips, each with a height of 128 pixels.
 * This is likely to make texture uploads faster, as subdividing a large texture into smaller areas is faster.
 * 
 * You can set the list to lazily load texture strips, as the list is scrolled.  Use the lazyRender attribute:- <list lazyRender="true"...
 * To reduce memory - you may remove list textures dynamically when not on the screen.  Use the recycle attribute:- <list recycle="true"...
 * By default, without the lazyRender, or recycle attribute - all list textures are pre-loaded.
 * 
 * This class allows you to update list rows that change appearance. (This is fast as you need only update relevant texture strips - not the whole list texture ).
 * But it may incur penalties with geometry (more points to deal with), and renderring (swapping texture buffers more frequently), and we can't do UV animation now.
 * 
 * Note that lists must have a clearance above and below of 128 pixels from any other Stage3D animated are - due to the lack of masking in the shaders.
 * (This won't usually be a problem).
 * 
 **/
		public function LongListScrolling() {
			super();
			_supportedLists.push("longList", "tickList", "tickOneList");
		}
		
/**
 * This scheme doesn't allow us to do UV animation - but we add the scroll offset within the vertex shader - so it is still fast.
 * 
 * The fragment shader implements variable motion blur which is put into effect when the list scrolls.
 * The faster the list scrolls, the more motion blur we apply.
 */
		override public function initialise():void {

			_listScrollingVertexShader.assemble( Context3DProgramType.VERTEX,
				"add op, va0, vc0 \n" +			// scroll
				"mov v0, va1 \n"				// interpolate UV
			);

			_listScrollingFragmentShader.assemble( Context3DProgramType.FRAGMENT,
			
				"mov ft0, v0 \n" +
				"tex ft1, v0.xy, fs0 <2d,linear,nomip> \n" +	// output texture
				"mul ft1.xyzw, ft1.xyzw, fc0.xxxx \n" +
				
				"sub ft0.y, ft0.y, fc0.w \n" +
				"tex ft2, ft0.xy, fs0 <2d,linear,nomip> \n" +
				"mul ft2.xyzw, ft2.xyzw, fc0.yyyy \n" +
				"add ft1, ft1, ft2 \n" +
				
				"sub ft0.y, ft0.y, fc0.w \n" +
				"tex ft2, ft0.xy, fs0 <2d,linear,nomip> \n" +
				"mul ft2.xyzw, ft2.xyzw, fc0.zzzz \n" +
				"add ft1, ft1, ft2 \n" +
				
				"mov ft0, v0 \n" +
				
				"add ft0.y, ft0.y, fc0.w \n" +
				"tex ft2, ft0.xy, fs0 <2d,linear,nomip> \n" +
				"mul ft2.xyzw, ft2.xyzw, fc0.yyyy \n" +
				"add ft1, ft1, ft2 \n" +
				
				"add ft0.y, ft0.y, fc0.w \n" +
				"tex ft2, ft0.xy, fs0 <2d,linear,nomip> \n" +
				"mul ft2.xyzw, ft2.xyzw, fc0.zzzz \n" +
				"add oc, ft1, ft2 \n"
			);
			
			_listScrollingShaderProgram = _context3D.createProgram();
			_listScrollingShaderProgram.upload( _listScrollingVertexShader.agalcode, _listScrollingFragmentShader.agalcode);
		
			_indexBuffer = _context3D.createIndexBuffer(6);
			_indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2,  0, 2, 3]), 0, 6);
		}
		
/**
 * Set quality.  0 > value >= 1.  1 = full quality, 0.1 is terrible.
 */
		public function set quality(value:Number):void {
			_quality = value;
		}
		
		
		public function get quality():Number {
			return _quality;
		}
		
/**
 * Show row highlight, or not (default is show)
 */
		public function set showCursor(value:Boolean):void {
			_showCursor = value;
		}
		
/**
 * Fast scrolling effect for lazyRender mode (default is on)
 */
		public function set fastScrolling(value:Boolean):void {
			_fastScrolling = value;
		}
		
/**
 * Fast scrolling threshold.  If you have amore powerful device - set it higher.
 */
		public function set fastScrollingThreshold(value:int):void {
			_fastScrollingThreshold = value;
		}
		
		
		public function get fastScrollingThreshold():int {
			return _fastScrollingThreshold;
		}
		
/**
 * Vertices of a list strip quad
 */
		protected function pushVerticesAndUV(listRecord:ListRecord, listWidth:Number):void {
			var pointList:Point = Sprite(listRecord.container).localToGlobal(new Point(0, 0));
			var left:Number = 2 * pointList.x / _screen.stage.stageWidth - 1.0;
			var top:Number = - 2 * pointList.y / _screen.stage.stageHeight + 1.0;
			var right:Number = left + 2 * listWidth / _screen.stage.stageWidth;
			var bottom:Number = top - 2 * STRIP_HEIGHT / (_screen.stage.stageHeight * _quality);

			var xyzVertexBuffer:VertexBuffer3D = _context3D.createVertexBuffer(4, 3);
			xyzVertexBuffer.uploadFromVector(Vector.<Number>([
				left, 		bottom, 	0.02,
				right,		bottom,		0.02,
				right,		top,		0.02,
				left,		top,		0.02	]), 0, 4);
			_xyzVertexBuffersAll.push(xyzVertexBuffer);

			var uvVertexBuffer:VertexBuffer3D = _context3D.createVertexBuffer(4, 2);
			uvVertexBuffer.uploadFromVector(Vector.<Number>([
				0, 						1,
				listRecord.uvWidth,		1,
				listRecord.uvWidth,		0,
				0,						0	]), 0, 4);
			_uvVertexBuffersAll.push(uvVertexBuffer);
		}
		
/**
 * Remove and dispose of a particular texture strip bitmapdata and texture.
 */
		protected function removeRow(listRecord:ListRecord, index:int):void {
			removeListRow(_recycleRow[listRecord.textureIndex], index);
		}
		
		
/**
 * Remove and dispose of a particular texture strip bitmapdata and texture.
 */
		protected function removeListRow(recycleRow:Vector.<uint>, index:int):void {
			if (recycleRow.indexOf(index) < 0) {
				recycleRow.push(index);
			}
		}
		
/**
 * Recycle a bitmapdata if available - or create a new one.  (Not sure how much more efficient it is to recycle rather than reinstanciate bitmapdata).
 */
		protected function newRowBitmapData(listRowBitmapData:Vector.<BitmapData>, recycleRow:Vector.<uint>, index:int, listWidth:Number, backgroundColour:uint = 0xFFFFFF, background:BitmapData = null):BitmapData {
			var result:BitmapData;
			if (recycleRow.length > 0) {
				var copyIndex:uint = recycleRow[0];
				result = listRowBitmapData[copyIndex];
				if (background) {
					result.copyPixels(background, new Rectangle(0, 0, listWidth, STRIP_HEIGHT), new Point(0, 0));
				}
				else {
					result.floodFill(0, 0, backgroundColour);
				}
				listRowBitmapData[copyIndex] = null;
			}
			else {
				result = background ? background.clone() : new BitmapData(power2(listWidth), STRIP_HEIGHT, false, DEBUG ? 0xffff00 : backgroundColour);
			}
			listRowBitmapData[index] = result;
			return result;
		}
		
		
/**
 * Remove recycle flag for a row.
 */
		protected function removeRecycle(recycleRow:Vector.<uint>, index:int):void {
			var pos:int = recycleRow.indexOf(index);
			if (pos >= 0) {
				recycleRow.splice(pos, 1);
			}
		}
			
/**
  * Recycle a Texture if available - or create a new one
  */
		protected function newRowTexture(listRowTexture:Vector.<Texture>, recycleRow:Vector.<uint>, index:int, bitmapData:BitmapData):Texture {
			var result:Texture;
			if (recycleRow.length > 0) {
				var copyIndex:uint = recycleRow.shift();
				result = listRowTexture[copyIndex];
				listRowTexture[copyIndex] = null;
			}
			else {
				result = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
			}
			removeRecycle(recycleRow, index);
			result.uploadFromBitmapData(bitmapData);
			listRowTexture[index] = result;
			return result;
		}
		
/**
 * Dynamically create a new list row
 */
		protected function loadNewRow(listRecord:ListRecord, newRowIndex:int, from:Number = 0, overwrite:Boolean = false):void {
			var list:IContainerUI = listRecord.container;
			var isScrolling:Boolean = list is UIScrollVertical;
			var listWidth:Number = _quality * UI.scale * theWidth(list);
			
			var listRowBitmapData:Vector.<BitmapData> = _listRowBitmapData[listRecord.textureIndex];
			var listRowTextures:Vector.<Texture> = _listRowTextures[listRecord.textureIndex];
			var recycleRow:Vector.<uint> = _recycleRow[listRecord.textureIndex];
			var y:Number = newRowIndex * STRIP_HEIGHT;
			
			if (newRowIndex >= listRowBitmapData.length) {
				listRowBitmapData.push(null);
				_listRowTextures[listRecord.textureIndex].push(null);
			}
			
			if (overwrite && listRowBitmapData[newRowIndex]) {
				removeRow(listRecord, newRowIndex);
			}
			
			if ((overwrite || !listRowBitmapData[newRowIndex]) && newRowIndex >= from) {
				var slider:Sprite = isScrolling ? Sprite(list.pages[0]) : Sprite(list);
				var backgroundColour:uint = list.attributes.backgroundColours.length > 0 ? list.attributes.backgroundColours[0] : 0xFFFFFF;
				
				var bitmapData:BitmapData = newRowBitmapData(listRowBitmapData, recycleRow, newRowIndex, listWidth, backgroundColour, listRecord.background);
				saveTexture(bitmapData, slider, new Rectangle(0, 0, listWidth, STRIP_HEIGHT), 0, -y, _quality);
				newRowTexture(listRowTextures, recycleRow, newRowIndex, bitmapData);

				if (newRowIndex == 0) {
					bitmapData.fillRect(
						new Rectangle(0, 0, listWidth, 1),
						0xFF000000 | backgroundColour
					);
				}
			}
			else {
				removeRecycle(recycleRow, newRowIndex);
			}
		}
		
/**
 * Store the background texture of a list.
 */
		protected function saveBackgroundBitmap(listRecord:ListRecord, listWidth:Number):void {
			var list:UIScrollVertical = UIScrollVertical(listRecord.container);
			var backgroundColour:uint = list.attributes.backgroundColours.length>0 ? list.attributes.backgroundColours[0] : 0xFFFFFF;
			var scroller:Sprite = Sprite(list.pages[0]);
			scroller.visible = false;
			list.drawComponent();
			listRecord.background = new BitmapData(power2(listWidth), STRIP_HEIGHT, false, DEBUG ? 0xffff00 : backgroundColour);
			saveTexture(listRecord.background, list, new Rectangle(0, 0, listWidth, STRIP_HEIGHT), 0, 0, _quality);
			scroller.visible = true;
		}

/**
 * Provide a list of the specific lists in your layout that you want to accelerate
 */
		override public function listTextures(lists:Vector.<IContainerUI>):Boolean {
	
			_xyzVertexBuffersAll = new Vector.<VertexBuffer3D>;
			_uvVertexBuffersAll = new Vector.<VertexBuffer3D>;
			
			for each (var list:IContainerUI in lists) {
				var listWidth:Number = UI.scale*theWidth(list);
				var textureWidth:Number = power2(listWidth);
				var listRecord:ListRecord = new ListRecord(list, _listRecords.length, list is UIList && UIList(list).showPressed, _quality * listWidth/textureWidth);
				if (list is UIGroupedList) {
					saveBackgroundBitmap(listRecord, listWidth);
				}

				listRecord.lazyRender = list.xml.@lazyRender == "true" || list is UILongList;
				listRecord.recycle = listRecord.lazyRender && list.xml.@recycle == "true";

				_listRecords.push(listRecord);
				
				var isScrolling:Boolean = list is UIScrollVertical;
				var length:int = Math.ceil((isScrolling ? Sprite(list.pages[0]).height : theHeight(list))/STRIP_HEIGHT);
				_listRowBitmapData.push(new Vector.<BitmapData>(length));
				_listRowTextures.push(new Vector.<Texture>(length));
				_recycleRow.push(new Vector.<uint>);
				
				pushVerticesAndUV(listRecord, listWidth);
				
				newScrollbarTexture(list);
			}

			renderCursorBuffers();

			if (ALTERNATIVE_SCHEME) {
				for each (var listRecord0:ListRecord in _listRecords) {
					if (listRecord0.onScreen) {
						takeOverFromListScroller(listRecord0);
					}
					if (!listRecord0.lazyRender) {
						preloadTextures(listRecord0);
					}
				}
			}

			isDefault(this);
			activate(this);

			onEnterFrame(this, updateLists);

			return false;
		}

/**
 * Restore shaders, streams and textures after context loss.
 */
		override public function contextResumed(running:Boolean):void {

			_listScrollingShaderProgram = _context3D.createProgram();
			_listScrollingShaderProgram.upload( _listScrollingVertexShader.agalcode, _listScrollingFragmentShader.agalcode);

			_xyzVertexBuffersAll = new Vector.<VertexBuffer3D>;
			_uvVertexBuffersAll = new Vector.<VertexBuffer3D>;

			for each (var listRecord:ListRecord in _listRecords) {
				var listRowBitmapData:Vector.<BitmapData> = _listRowBitmapData[listRecord.textureIndex];
				var listRowTextures:Vector.<Texture> = _listRowTextures[listRecord.textureIndex];
				for (var i:int = 0; i<= listRowBitmapData.length; i++) {
					pushVerticesAndUV(listRecord, UI.scale * theWidth(listRecord.container));
					var bitmapData:BitmapData = listRowBitmapData[i];
					if (bitmapData) {
						var texture:Texture = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
						texture.uploadFromBitmapData(bitmapData);
						listRowTextures[i] = texture;
					}
					else {
						listRowTextures[i] = null;
					}
				}
			}
			
			_indexBuffer = _context3D.createIndexBuffer(6);
			_indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2,  0, 2, 3]), 0, 6);
			
			renderCursorBuffers();
			
			if (running) {
				enable();
			}
		}
		
/**
 * Preload textures if lazyRender="false" (default).
 */
		protected function preloadTextures(listRecord:ListRecord):void {
			var list:IContainerUI = listRecord.container;
			var isScrolling:Boolean = list is UIScrollVertical;
			var length:int = Math.ceil(UI.scale * (isScrolling ? Sprite(list.pages[0]).height : theHeight(list))/STRIP_HEIGHT);
			for (var i:int = 0; i <= length; i++) {
				loadNewRow(listRecord, i);
			}
		}
		
/**
 * If the list is scrolled, dynamically remove and add texture strips
 */
		protected function updateTextures(listRecord:ListRecord, isScrolling:Boolean, topStrip:Number, bottomStrip:Number, length:Number):void {
			
			if (topStrip == listRecord.firstRowIndex && bottomStrip == listRecord.lastRowIndex) {
				return;
			}
			
			if (isScrolling) {
				
				var recycleRow:Vector.<uint> = _recycleRow[listRecord.textureIndex];
				
				if (topStrip > listRecord.lastRowIndex || bottomStrip < listRecord.firstRowIndex) {
					
					if (listRecord.recycle) {
						for (var m:int = Math.max(listRecord.firstRowIndex, 0); m <= Math.min(listRecord.lastRowIndex, length); m++) {
							removeListRow(recycleRow, m);
						}
					}
					
					for (var n:int = Math.max( Math.min(topStrip, listRecord.finalTexture), 0); n <= Math.min(bottomStrip, length); n++) {
						loadNewRow(listRecord, n, topStrip);
					}
				}
				else {
					
					if (listRecord.recycle) {
						for (var k:int = Math.max(listRecord.firstRowIndex, 0); k < Math.min(topStrip, length); k++) {
							removeListRow(recycleRow, k);
						}
						for (var l:int = Math.max(bottomStrip + 1, 0); l <= Math.min(listRecord.lastRowIndex, length); l++) {
							removeListRow(recycleRow, l);
						}
					}

					for (var j:int = Math.max( topStrip, 0); j < Math.min(listRecord.firstRowIndex, length + 1); j++) { // list scrolled down (new rows higher than old)
						loadNewRow(listRecord, j);
					}
					
					for (var i:int = Math.max( Math.min(listRecord.lastRowIndex + 1, listRecord.finalTexture), 0); i <= Math.min(bottomStrip, length); i++) { // list scrolled up (new rows lower than old)
						loadNewRow(listRecord, i, topStrip);
					}
				}
			
			}
			
			listRecord.firstRowIndex = topStrip;
			listRecord.lastRowIndex = bottomStrip;
			listRecord.finalTexture = Math.max(listRecord.finalTexture, bottomStrip + 1);
		}
	
	
		override protected function makeUV():void {
		}
		
/**
 * Set streams and textures
 */
		protected function setBuffers(listRecord:ListRecord):void {
			_context3D.setVertexBufferAt( 0, _xyzVertexBuffersAll[listRecord.textureIndex],  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvVertexBuffersAll[listRecord.textureIndex],  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
		}
		
		
		override protected function setRegisters():void {
			_context3D.setProgram(_listScrollingShaderProgram);
			clearMotionBlur();
		}
		
/**
 * Apply motion blur.
 */
		protected function setMotionBlur(listRecord:ListRecord):void {
			if (_lastPositionY == _screen.stage.mouseY) {
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 1.0, 0.0, 0.0, 0.0]) );
			}
			else {
				var motionBlur:int = Math.floor(Math.abs(listRecord.delta/MOTION_BLUR_DIVISOR));
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ MOTION_K0, MOTION_K1, MOTION_K2, motionBlur / STRIP_HEIGHT]) );	// fc0
			}
		}
		
/**
 * Fast motion blur.
 */
		protected function fastMotionBlur():void {
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ FAST_MOTION_K0, FAST_MOTION_K1, FAST_MOTION_K2, FAST_MOTION_AMOUNT + FAST_MOTION_AMOUNT * Math.random() ]) );	// fc0
		}
		
/**
 * Clear motion blur.
 */
		protected function clearMotionBlur():void {
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ 1.0, 0.0, 0.0, 0.0]) );	// fc0
		}
		
		
		override protected function startMovement(listRecord:ListRecord):void {
			super.startMovement(listRecord);
			clearMotionBlur();
		}
		
		
		protected function incrementalUpdateTextures(listRecord:ListRecord, isScrolling:Boolean, fromTexture:int, toTexture:int, currentIndex:int, length:Number):int {
			updateTextures(listRecord, isScrolling, fromTexture, fromTexture + currentIndex + _fastScrollingThreshold - 1 , length);
			return (currentIndex >= toTexture - fromTexture) ? -1 : currentIndex + _fastScrollingThreshold;
		}
		
/**
 * Render lists
 */
		override protected function drawLists():void {
			_context3D.clear((_backgroundColour>>32 & 0xff)/0xff, (_backgroundColour>>16 & 0xff)/0xff, (_backgroundColour & 0xff)/0xff);
			for each (var listRecord:ListRecord in _listRecords) {
				if (listRecord.onScreen || listRecord == _listRecordCurrent || listRecord == _listRecordNext) {
					var list:IContainerUI = listRecord.container;
					var isScrolling:Boolean = list is UIScrollVertical;
					var length:int = Math.ceil(_quality * UI.scale * (isScrolling ? Sprite(list.pages[0]).height : theHeight(list))/STRIP_HEIGHT);
					var scrollPositionY:Number =  (isScrolling ? UI.scale * UIScrollVertical(list).scrollPositionY : -_centre.y);
					var topStrip:int =  Math.max(Math.floor(_quality * scrollPositionY/STRIP_HEIGHT), 0);
					var bottomStrip:int = Math.min(topStrip + Math.ceil(_quality * UI.scale * theHeight(list)/STRIP_HEIGHT), length);
					var renderCursorCondition:Boolean = _frameCount <= CLICK_FRAMES && _notTooFastForClick && isScrolling && _showCursor && _activeList == listRecord;
					var goingVeryFast:Boolean = _fastScrolling && listRecord.lazyRender && Math.abs(listRecord.delta) > _fastScrollingThreshold * STRIP_HEIGHT;
					var aboveOrBelow:Boolean = isScrolling && (scrollPositionY < 0 || scrollPositionY > UI.scale * UIScrollVertical(list).maximumSlide);
					
					setBuffers(listRecord);
					
					if (goingVeryFast && !aboveOrBelow) {
						fastMotionBlur();
						_reloadIncremental = -1;
					}
					else if (listRecord.lazyRender) {
						if (aboveOrBelow) {
							_reloadIncremental = -1;
							_wasGoingVeryFast = goingVeryFast = false;
						}
						if (_reloadIncremental >= 0) {
							_reloadIncremental = incrementalUpdateTextures(listRecord, isScrolling, topStrip, bottomStrip, _reloadIncremental, length);
							fastMotionBlur();
						}
						else if (_wasGoingVeryFast) { // To avoid list stuttering as we need to load a lot of texture strips - so slow it down and preload some textures
							listRecord.delta = (listRecord.delta > 0) ? SLOW : -SLOW;
							_reloadIncremental = incrementalUpdateTextures(listRecord, isScrolling, topStrip, bottomStrip, 0, length);
							fastMotionBlur();
						}
						else {
							updateTextures(listRecord, isScrolling, topStrip, bottomStrip, length);
							setMotionBlur(listRecord);
						}
					}
					else {
						setMotionBlur(listRecord);
					}
										
					_wasGoingVeryFast = goingVeryFast;

					var xPosition:Number = (listRecord == _listRecordCurrent) ? _positionCurrent : ((listRecord == _listRecordNext) ? _positionNext : 0);
					var yPosition:Number = 2 * scrollPositionY/_screen.stage.stageHeight;
					
					if (goingVeryFast || _reloadIncremental >= 0) {
						trace("going very fast");
						var textureIndex:int = Math.max(listRecord.firstRowIndex, 0);
						var numberOfTextures:int = listRecord.lastRowIndex - listRecord.firstRowIndex;
						var count:int = Math.floor(Math.random() * numberOfTextures);
						for (var i:int = topStrip; i <= bottomStrip; i++) {
							_context3D.setTextureAt(0, _listRowTextures[listRecord.textureIndex][textureIndex + count]);
							count = Math.max((count + 1) % numberOfTextures, 1);
							_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([ xPosition, yPosition - i * 2 * STRIP_HEIGHT / (_screen.stage.stageHeight * _quality) , 0.0, 0.0 ]) );	// vc0
							_context3D.drawTriangles(_indexBuffer, 0, 2);
						}
					}
					else {
						for (var j:int = topStrip; j <= bottomStrip; j++) {
							_context3D.setTextureAt(0, _listRowTextures[listRecord.textureIndex][j]);
							_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([ xPosition, yPosition - j * 2 * STRIP_HEIGHT / (_screen.stage.stageHeight * _quality) , 0.0, 0.0 ]) );	// vc0
							_context3D.drawTriangles(_indexBuffer, 0, 2);
						}
					}
					_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([ xPosition, yPosition, 0.0, 0.0 ]) );
					
					if (renderCursorCondition) {
						renderCursor(listRecord);
					}
					else if (!(listRecord.container is UIPicker) && (listRecord == _activeList || Math.abs(listRecord.delta) > SHOW_SCROLLBAR_DELTA || !isNaN(listRecord.destination))) {
						renderScrollbar(listRecord);
					}
				}
			}
			_context3D.present();
		}
		
/**
 * Clear bitmaps and textures
 */
		override protected function disposeOfTextures():void {
			for each (var listRowBitmapData:Vector.<BitmapData> in _listRowBitmapData) {
				for each (var bitmapData:BitmapData in listRowBitmapData) {
					bitmapData.dispose();
				}
			}
			for each (var listRowTextures:Vector.<Texture> in _listRowTextures) {
				for each (var texture:Texture in listRowTextures) {
					texture.dispose();
				}
			}
		}
		
/**
 * Sliding transition from currentPage to nextPage.  If back=true, slide right.
 */
		override public function slidePage(currentPage:uint, nextPage:uint, back:Boolean = false):void {
			_listRecordCurrent = _listRecords[currentPage];
			Sprite(_listRecordCurrent.container).visible = false;
			_listRecordNext = _listRecords[nextPage];
			_back = back;
			_count = - 2*INCREMENT;
			_enabled = false;
			_stopping = false;
			onEnterFrame(this, onEnterFrameSlide);
		}
		
/**
 * Update a component appearance within the list.
 */
		override public function updateComponent(pageNumber:int, component:DisplayObject = null):void {
			var listRecord:ListRecord = _listRecords[pageNumber];
			var page:Sprite = Sprite(listRecord.container);
			var globalPoint:Point = component.localToGlobal(new Point(0,0));
			var localPoint:Point = Sprite(page).globalToLocal(globalPoint);
			if (page is UIScrollVertical) {
				localPoint.y -= UIScrollVertical(page).sliderY;
				if (page is UIList) {
					UIList(page).clearPressed();
				}
			}

			var fromStrip:int = Math.floor(UI.scale * (localPoint.y - EXTRA) / STRIP_HEIGHT);
			var toStrip:int = Math.floor(UI.scale * (localPoint.y + component.height + 2 * EXTRA) / STRIP_HEIGHT);
			var listRowBitmapData:Vector.<BitmapData> = _listRowBitmapData[listRecord.textureIndex];
			for (var i:int = fromStrip; i <= toStrip; i++) {
				if (listRowBitmapData[i]) {
					loadNewRow(listRecord, i, 0, true);
				}
			}
		}
		
/**
 * Set Stage3D background colour
 */
		public function set backgroundColour(value:uint):void {
			_backgroundColour = value;
		}
		
/**
 * Render sliding transition
 */
		override protected function drawSlideFrame(event:Event = null):void {
			var shift:Number = (_back ? 1.0 : -1.0) * easing(_count) * _centre.width;
			_positionCurrent = 2.0 * shift / _screen.stage.stageWidth;
			_positionNext = 2.0 * ((_back ? -1.0 : 1.0) * _centre.width + shift) / _screen.stage.stageWidth;
			drawLists();
		}
		
/**
 * Initialise cursor buffers
 */
		protected function renderCursorBuffers():void {
			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			_cursorVertices = _context3D.createVertexBuffer(4, 3);

			_cursorUV = _context3D.createVertexBuffer(4, 2);
			_cursorUV.uploadFromVector(Vector.<Number>([0, 1, 1, 1, 1, 0, 0, 0]), 0, 4);
			
			var cursorBitmap:BitmapData = new BitmapData(1, 1, true, 0x22000000 | UIList.HIGHLIGHT);
			_cursorTexture = _context3D.createTexture(1, 1, Context3DTextureFormat.BGRA, false);
			_cursorTexture.uploadFromBitmapData(cursorBitmap);
		}
		
/**
 * Render a rectangle, either a row highlight, or a scrollbar
 */
		protected function renderRectangle(left:Number, top:Number, right:Number, bottom:Number):void {
			_cursorVertices.uploadFromVector(Vector.<Number>([
				left, 		bottom, 	0.01,
				right,		bottom,		0.01,
				right,		top,		0.01,
				left,		top,		0.01	]), 0, 4);
			
			clearMotionBlur();
			
			_context3D.setVertexBufferAt( 0, _cursorVertices,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _cursorUV,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			
			_context3D.drawTriangles(_indexBuffer, 0, 2);

		}
		
/**
 * Render a row hightlight
 */
		protected function renderCursor(listRecord:ListRecord):void {
			var list:UIScrollVertical = UIScrollVertical(listRecord.container);
			var point:Point = list.globalToLocal(new Point(_screen.stage.mouseX, _screen.stage.mouseY));
			var rectangle:Rectangle = list.rowRectangle(point.y - list.sliderY);
			
			if (rectangle) {
				var globalPoint:Point = list.localToGlobal(new Point(rectangle.x, rectangle.y));
				var left:Number = 2 * globalPoint.x / _screen.stage.stageWidth - 1.0;
				var top:Number = - 2 * globalPoint.y / _screen.stage.stageHeight + 1.0;
				var right:Number = left + 2 * UI.scale * rectangle.width / _screen.stage.stageWidth;
				var bottom:Number = top -  2 * UI.scale * rectangle.height / _screen.stage.stageHeight;
				_context3D.setTextureAt(0, _cursorTexture);
				renderRectangle(left, top, right, bottom);
			}
			
		}
		
/**
 * Initialise scrollbar texture
 */
		protected function newScrollbarTexture(list:IContainerUI):void {
			var scrollbarTexture:Texture = null;
			if (list is UIScrollVertical && !(list is UIPicker)) {
				var colour:uint = list.xml.@scrollBarColour.length() > 0 ? UI.toColourValue(list.xml.@scrollBarColour) : 0x555555;
				var scrollbarBitmap:BitmapData = new BitmapData(1, 1, false, 0xFF000000 | colour);
				scrollbarTexture = _context3D.createTexture(1, 1, Context3DTextureFormat.BGRA, false);
				scrollbarTexture.uploadFromBitmapData(scrollbarBitmap);
			}
			_scrollbarTextures.push(scrollbarTexture);
		}
		
/**
 * Render scrollbar
 */
		protected function renderScrollbar(listRecord:ListRecord):void {
			var list:UIScrollVertical = UIScrollVertical(listRecord.container);
			var scroller:Sprite = Sprite(list.pages[0]);
			var height:Number = theHeight(list);
			var barHeight:Number = (height / scroller.height) * height;
			var barPosition:Number = (- list.sliderY / scroller.height) * height + 2 * SCROLLBAR_POSITION;
			if (barPosition < SCROLLBAR_POSITION) {
				barHeight += barPosition;
				barPosition = SCROLLBAR_POSITION;
			}
			if (barPosition + barHeight > height - 4 * SCROLLBAR_POSITION) {
				barHeight -= barPosition + barHeight - height + 4 * SCROLLBAR_POSITION;
			}
			if (barHeight > 0 && barPosition >= 0) {
				var globalPoint:Point = list.localToGlobal(new Point(theWidth(list), barPosition));
				var left:Number = 2 * (globalPoint.x -  (SCROLLBAR_POSITION + SCROLLBAR_WIDTH) * UI.scale) / _screen.stage.stageWidth - 1.0;
				var top:Number = - 2 *  (globalPoint.y - UI.scale * list.sliderY) / _screen.stage.stageHeight + 1.0;
				var right:Number = left + SCROLLBAR_WIDTH * UI.scale / _screen.stage.stageWidth;
				var bottom:Number = top -  2 * UI.scale * barHeight / _screen.stage.stageHeight;	
				_context3D.setTextureAt(0, _scrollbarTextures[listRecord.textureIndex]);
				renderRectangle(left, top, right, bottom );
			}
		}

	}
}
