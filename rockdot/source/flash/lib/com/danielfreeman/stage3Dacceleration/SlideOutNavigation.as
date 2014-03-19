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
	import com.danielfreeman.extendedMadness.UISlideOutNavigation;
	import com.danielfreeman.extendedMadness.UIe;
	import com.danielfreeman.madcomponents.IContainerUI;
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UINavigationBar;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	public class SlideOutNavigation extends LongListScrolling {	
		
		protected static const BEHIND:Number = 0.1;	
		protected static const SLIDE_INCREMENT:Number = 0.2;
		
		protected var _slideOutNavigation:UISlideOutNavigation;
		protected var _listWidth:Number;
		protected var _listWidthNormalised:Number;
		protected var _open:Boolean = false;
		protected var _dragging:Boolean = false;
		
/**
 * Stage3D acceleration for the new SlideOutNavigation component
 */
		public function SlideOutNavigation() {
			super();
			backgroundColour = 0x333333;
		}
		
/**
 * Search the MadComponents tree, and find a UISlideOutNavigation component.
 * Return true if found.
 */
		override protected function allListTextures0(item:Sprite):Boolean {
			var found:Boolean = false;
			for (var i:int = 0; i<item.numChildren && !found; i++) {
				var child:DisplayObject = item.getChildAt(i);
				if (child is UISlideOutNavigation) {
					var slideOutNavigation:UISlideOutNavigation = UISlideOutNavigation(child);
					setSlideOutNavigation(slideOutNavigation);
					_lists.push(slideOutNavigation.list, slideOutNavigation.detail);
					return true;
				}
				else if (child is Sprite) {
					found = allListTextures0(Sprite(child));
				}
			}
			return false;
		}
		
/**
 * Determine component size, and take over control from the component
 */
		protected function setSlideOutNavigation(value:UISlideOutNavigation):void {
			var point:Point = value.localToGlobal(new Point(0,0));
			_centre = new Rectangle(
					point.x,
					point.y,
					UI.scale*value.attributes.width,
					UI.scale*value.attributes.height
			);
			_slideOutNavigation = value;
			_slideOutNavigation.enabled = false;
			_listWidth = _slideOutNavigation.listWidth;
			_listWidthNormalised = 2 * UI.scale * _listWidth / _screen.stage.stageWidth;
		//	_slideOutNavigation.addEventListener(UISlideOutNavigation.CLICKED, slideOutButton);
			_slideOutNavigation.navigationBar.leftButton.addEventListener(MouseEvent.MOUSE_DOWN, slideOutButton);
		}

/**
 * Capture SlideOutNavigation textures.  Specify the component as a parameter.
 */
		public function slideOutNavigation(value:UISlideOutNavigation):void {
			setSlideOutNavigation(value);
			listTextures(Vector.<IContainerUI>([value.list, value.detail]));
		}
		
/**
 * Vertices of a list strip quad
 */
		override protected function pushVerticesAndUV(listRecord:ListRecord, listWidth:Number):void {
			var pointList:Point = Sprite(listRecord.container).localToGlobal(new Point(0, 0));
			var left:Number = 2 * pointList.x / _screen.stage.stageWidth - 1.0;
			var top:Number = - 2 * pointList.y / _screen.stage.stageHeight + 1.0;
			var right:Number = left + 2 * listWidth / _screen.stage.stageWidth;
			var bottom:Number = top - 2 * STRIP_HEIGHT / _screen.stage.stageHeight;
			var z:Number = (listRecord.textureIndex==0) ? BEHIND : 0;
			
			var xyzVertexBuffer:VertexBuffer3D = _context3D.createVertexBuffer(4, 3);
			xyzVertexBuffer.uploadFromVector(Vector.<Number>([
				left, 		bottom, 	z,
				right,		bottom,		z,
				right,		top,		z,
				left,		top,		z	]), 0, 4);
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
 * Handler for the slide button being pressed.
 */
		protected function slideOutButton(event:Event):void {
			if (!_listRecordNext) {
				_slideOutNavigation.detail.visible = false;
				if (_open) {
					slidePage(0, 1, true);
				}
				else {
					slidePage(0, 1);
					doTakeOverFromListScroller(_slideOutNavigation.list);
				}
			}
		}

/**
 * MouseDown Handler for list scroll or detail sliding
 */
		override protected function mouseDown(event:MouseEvent):void {
			var point:Point = _slideOutNavigation.globalToLocal(new Point(_screen.stage.mouseX, _screen.stage.mouseY));
			if (_open && point.x > _listWidth && point.y > UINavigationBar.HEIGHT) {
				startDragging();
			}
			else {
				super.mouseDown(event);
			}
		}
		
/**
 * Start dragging the detail page
 */
		protected function startDragging():void {
			stopMovement(_listRecords[0]);
			_slideOutNavigation.detail.visible = false;
			_dragging = true;
			_stopping = false;
			_listRecordNext = _listRecords[1];
			_screen.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			onEnterFrame(this, dragDetail);
		}
		
/**
 * Mouse-Up handler
 */
		override protected function mouseUp(event:MouseEvent):void {
			if (_dragging) {
				stopDragging();
			}
			else {
				super.mouseUp(event);
			}
		}
		
/**
 * Do slide
 */	
		override protected function onEnterFrameSlide(event:Event):void {
			_count += SLIDE_INCREMENT;
			 drawSlideFrame();
			 if (_stopping) {
				slideComplete();
			 }
			 else if (_count >= 1.0) {
				prepareToStop();
			}
		}
		
		
		override protected function prepareToStop():void {
			_stopping = true;
			_open = !_open;
			if (_open) {
				_slideOutNavigation.open(false);
			}
			else {
				_slideOutNavigation.close(false);
			}
			_slideOutNavigation.list.visible = !_open;
			_slideOutNavigation.detail.visible = true;
		}
		
/**
 * Stop dragging the detail page - it will snap open or shut.
 */
		protected function stopDragging():void {
			var point:Point = _slideOutNavigation.globalToLocal(new Point(_screen.stage.mouseX, _screen.stage.mouseY));
			_count = point.x / _listWidth;
			_dragging = false;
			_back = _count < 0.5;
			if (_back) _count = 1 - _count;
			_open = _back;
			if (!_open) {
				_slideOutNavigation.open(false);
			}
			else {
				_slideOutNavigation.close(false);
			}
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_enabled = false;
			onEnterFrame(this, onEnterFrameSlide);
		}
		
/**
 * Slide transition complete
 */
		override protected function slideComplete():void {
			_listRecords[1].onScreen = !_open;
			setRegisters();
			_listRecordNext = null;
			_enabled = true;
			_count = 1.0;
			onEnterFrame(this, updateLists);
		}
		
/**
 * Dragging the detail page
 */
		protected function dragDetail(event:Event):void {
			var point:Point = _slideOutNavigation.globalToLocal(new Point(_screen.stage.mouseX, _screen.stage.mouseY));
			_positionNext = Math.min(Math.max(2.0 * UI.scale * point.x / _screen.stage.stageWidth, 0), _listWidthNormalised);
			drawLists();
		}
		
/**
 * Sliding the detail page
 */
		override protected function drawSlideFrame(event:Event = null):void {
			var shift:Number = easing(Math.min( Math.max(_count, 0), 1));
			_positionNext = 2.0 * UI.scale * _listWidth * (_back ? (1-shift) : shift) / _screen.stage.stageWidth;
			drawLists();
		}
		
		
		public static const READY:String = "slideOutReady";
				
		protected static var _slideOutNavigation:SlideOutNavigation;
		protected static var _screenS:Sprite;

		
		public static function create(screen:Sprite, xml:XML, width:Number = -1, height:Number = -1):Sprite {
			_screenS = screen;
			var result:Sprite = UIe.create(screen, xml, width, height);
			screen.addEventListener(Stage3DAcceleration.CONTEXT_COMPLETE, contextComplete);
			Stage3DAcceleration.startStage3D(screen);
			return result;
		}
		
		
		protected static function contextComplete(event:Event):void {
			_screenS.removeEventListener(Stage3DAcceleration.CONTEXT_COMPLETE, contextComplete);
			_slideOutNavigation = new SlideOutNavigation();
			_slideOutNavigation.allListTextures();
			_screenS.dispatchEvent(new Event(READY));
		}
		
		
		public static function get slideOutNavigation():SlideOutNavigation {
			return _slideOutNavigation;
		}
	}
}
