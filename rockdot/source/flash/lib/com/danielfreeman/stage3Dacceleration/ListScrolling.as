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
	import com.danielfreeman.extendedMadness.UIPanel;
	import com.danielfreeman.madcomponents.IContainerUI;
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UIForm;
	import com.danielfreeman.madcomponents.UIList;
	import com.danielfreeman.madcomponents.UIPages;
	import com.danielfreeman.madcomponents.UIPicker;
	import com.danielfreeman.madcomponents.UIScrollVertical;
	import com.danielfreeman.madcomponents.UISwitch;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

/**
 * Accelerated list scrolling.
 * This class may only be used where each list is guaranteed to fit within a single 2048x2048 texture.
 * (And this must be guaranteed for all resolutions and screen desities of devices that the app will run on).
 * - note that there is a subclass, LongListScrolling that removes his restriction.
 */
	public class ListScrolling extends Stage3DAcceleration {

		public static const COMPONENT_CHANGED:String = "componentChanged";
		
		protected static const TEXTURE_WIDTH:int = 2048;
		protected static const TEXTURE_HEIGHT:int = 2048;
		protected static const SUPPORTED_LISTS:Vector.<String> = Vector.<String>(["scrollVertical", "list", "dividedList", "groupedList", "picker"]);
		protected static const INCREMENT:Number = 0.1;

		protected static const DECAY:Number = 0.95;
		protected static const FASTER_DECAY:Number = 0.10;
		protected static const DELTA_THRESHOLD:Number = 1.0;
		protected static const MOVE_FACTOR:Number = 2.0;
		protected static const BOUNCE_FACTOR:Number = 0.3;
		protected static const MOVE_THRESHOLD:Number = 1.0;
		protected static const CLICK_FRAMES:int = 3;
		protected static const CLICK_THRESHOLD:Number = 4.0;
		protected static const HIGHLIGHT_FRAMES:int = 10;
		protected static const LONG_PRESS:int = 20;
		protected static const FAST_THRESHOLD:Number = 10.0;
		protected static const ACCELERATE:Number = 3.0;
		protected static const DELTA_LIMIT:Number = 800.0;

		protected static const ALTERNATIVE_SCHEME:Boolean = true;
		protected static const DEBUG:Boolean = false;


		protected var _textureBitMapData:Vector.<BitmapData> = new Vector.<BitmapData>();
		protected var _listRecords:Vector.<ListRecord> = new Vector.<ListRecord>();
		protected var _vertexes:Vector.<Number> = null;
		protected var _uv:Vector.<Number> = null;
		protected var _indices:Vector.<uint>;
		protected var _indexBuffer:IndexBuffer3D;
		protected var _xyzVertexBuffer:VertexBuffer3D;
		protected var _uvVertexBuffer:VertexBuffer3D;

		protected var _listScrollingVertexShader:AGALMiniAssembler = new AGALMiniAssembler();		
		protected var _listScrollingFragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
		protected var _listScrollingShaderProgram:Program3D;
		protected var _listScrollingTexture:Vector.<Texture> = new Vector.<Texture>();
		
		protected var _supportedLists:Vector.<String> = SUPPORTED_LISTS;

		protected var _holes:Vector.<IContainerUI>;
		protected var _lists:Vector.<IContainerUI> = new Vector.<IContainerUI>();
		
		protected var _count:Number = 0.0;
		protected var _textureRegister:int = 0;
		protected var _enabled:Boolean = false;
		protected var _container:UIPages = null;
		
		protected var _slideXyzVertexBuffer:VertexBuffer3D;
		protected var _slideUvVertexBuffer:VertexBuffer3D;
		protected var _listRecordCurrent:ListRecord;
		protected var _listRecordNext:ListRecord;
		protected var _back:Boolean;
		protected var _centre:Rectangle;
		protected var _slideIndexBuffer:IndexBuffer3D;
		protected var _activeList:ListRecord = null;
		protected var _startMouseY:Number;
		protected var _startSliderY:Number;
		protected var _somethingMoving:int = 0;
		protected var _frameCount:int = 0;
		protected var _lastPositionY:Number;
		protected var _searchHit:DisplayObject;
		protected var _searchHitComponent:DisplayObject;
		protected var _listenForChange:UISwitch;
		protected var _clicked:Boolean = false;
		protected var _notTooFastForClick:Boolean = true;
		
		protected var _oldActiveList:ListRecord = null;
		protected var _oldDelta:Number = Number.NaN;
		
		protected var _autoUpdateComponents:Boolean = true;
		protected var _componentChanged:DisplayObject;
		protected var _stopping:Boolean;
		protected var _activeListTextureIndex:int = -1;
		
		protected var _delayedStage3D:Timer = new Timer(50,1);
	
		
		public function ListScrolling() {
			initialise();
			_delayedStage3D.addEventListener(TimerEvent.TIMER, showStage3D);
		}
		
/**
 * A standard and simple vertes shader simply outputs vertices (without transformation), and interpolates UV.
 * 
 * The texture shader is more sophisticated.  List scrolling is accomplished by fast UV animation.
 */
		public function initialise():void {

			_listScrollingVertexShader.assemble( Context3DProgramType.VERTEX,
				"mov op, va0 \n" +	// vertex
				"mov v0, va1 \n"	// interpolate UV
			);
			
			_listScrollingFragmentShader.assemble( Context3DProgramType.FRAGMENT,
				"sge ft0.z, v0.y, fc0.y \n" +				// Deal with negative scroll position
				"mul ft0.z, ft0.z, v0.y \n" +
 				"frc ft0.y, ft0.z \n" +
				"sub ft0.z, ft0.z, ft0.y \n" +				// integer part of V is portion
				"mul ft0.z, ft0.z, fc0.x \n" +				// multiply portion by list width
				"add ft0.x, v0.x, ft0.z \n" +				// add to U.
				"tex oc, ft0.xy, fs0 <2d,linear,nomip> \n" 	// output texture
			);
			
			_listScrollingShaderProgram = _context3D.createProgram();
			_listScrollingShaderProgram.upload( _listScrollingVertexShader.agalcode, _listScrollingFragmentShader.agalcode);
		}
		
/**
 * For custom renderers, if a components is clicked - update textures.
 */
		public function set autoUpdateComponents(value:Boolean):void {
			_autoUpdateComponents = value;
		}
		
/**
 * Extend the set of MadComponents list classes supported.
 * (You might want to do this if you've built your own subclass of a MadComponents UIScrollVertical)
 */
		public function extend(value:Vector.<String>):void {
			_supportedLists = _supportedLists.concat(value);
		}
		
/**
 * Clear all texture and bitmapdata memory.
 */
		public function clear():void {
			for each(var bitmapData:BitmapData in _textureBitMapData) {
				bitmapData.dispose();
			}
			_textureBitMapData = new Vector.<BitmapData>();
			_listRecords = new Vector.<ListRecord>();
			_listScrollingTexture = new Vector.<Texture>();
			_lists = new Vector.<IContainerUI>();
		}
		
/**
 * Generate UV, according to list scroll value.  (UV animation).
 */
		protected function createUV(listRecord:ListRecord):void {
			if (listRecord.container is UIForm) {
				_uv.push(
					0, 						listRecord.uvHeight,
					listRecord.uvWidth,		listRecord.uvHeight,
					listRecord.uvWidth,		0,
					0,						0
				);
			}
			else {
				var textureTop:Number = UI.scale*(UIScrollVertical(listRecord.container).scrollPositionY + 1)/listRecord.textureHeight;
				var textureBottom:Number = textureTop + listRecord.uvHeight;
				_uv.push(
					0, 						textureBottom,
					listRecord.uvWidth,		textureBottom,
					listRecord.uvWidth,		textureTop,
					0,						textureTop
				);
			}
		}
		
/**
 * Search the entire MadComponents layout for ALL supported lists, and accelerate them.
 */
		public function allListTextures():Boolean {
			_lists = new Vector.<IContainerUI>();
			allListTextures0(_screen);
			return listTextures(_lists);
		}
		
/**
 * Perform search for ALL supported lists in the layout.
 */
		protected function allListTextures0(item:Sprite):Boolean {
			for (var i:int = 0; i<item.numChildren; i++) {
				var child:DisplayObject = item.getChildAt(i);
				if (child is UIScrollVertical && _supportedLists.indexOf(UIScrollVertical(child).xml.localName())>=0) {
					_lists.push(child);
				}
				else if (child is Sprite) {
					allListTextures0(Sprite(child));
				}
			}
			return true;
		}

/**
 * Provide a list of the specific lists in your layout that you want accelerated
 */
		public function listTextures(lists:Vector.<IContainerUI>):Boolean {

			var error:Boolean = false;
			_listRecords = new Vector.<ListRecord>();
			_vertexes = new Vector.<Number>();
			_uv = new Vector.<Number>();
			_indices = new Vector.<uint>();
			
			for each (var list:IContainerUI in lists) {
				
				var point:Point = Sprite(list).localToGlobal(new Point(0,0));
				var listWidth:Number = UI.scale * theWidth(list);
				var listHeight:Number = UI.scale * theHeight(list);
				var left:Number = 2 * point.x / _screen.stage.stageWidth - 1.0;
				var top:Number = - 2 * point.y / _screen.stage.stageHeight + 1.0;
				var right:Number = left + 2 * listWidth / _screen.stage.stageWidth;
				var bottom:Number = top - 2 * listHeight / _screen.stage.stageHeight;

				_vertexes.push(
					left, 		bottom, 	0,
					right,		bottom,		0,
					right,		top,		0,
					left,		top,		0
				);
			
				var count:uint = 4*_listRecords.length;
			
				_indices.push(
					count, count+1, count+2,	count, count+2, count+3
				);

				var scroller:Sprite = (list is UIScrollVertical) ? Sprite(list.pages[0]) : null;
				var scrollerHeight:Number =  (scroller ? UI.scale * scroller.height : listHeight);
				var listPortions:Number = Math.ceil(scrollerHeight / TEXTURE_HEIGHT);

				var textureWidth:Number = power2(listWidth * listPortions);
				if (textureWidth>TEXTURE_WIDTH) {
					textureWidth = TEXTURE_WIDTH;
					listPortions = Math.floor(TEXTURE_WIDTH / listWidth);
					error = true;
				}
				
				var textureHeight:Number = (scrollerHeight < TEXTURE_HEIGHT/2) ? power2(scrollerHeight) : TEXTURE_HEIGHT;
				var backgroundColour:uint = list.attributes.backgroundColours.length>0 ? list.attributes.backgroundColours[0] : 0xFFFFFF;
				var bitmapData:BitmapData = new BitmapData(textureWidth, textureHeight, false, DEBUG ? 0xffff00 : backgroundColour);
				
				var listRecord:ListRecord = new ListRecord(list, _listRecords.length, list is UIList && UIList(list).showPressed, listWidth/textureWidth, listHeight/textureHeight, textureHeight);
				_listRecords.push(listRecord);
			
				createUV(listRecord);
			
				var matrix:Matrix = new Matrix();
				matrix.identity();
				matrix.scale(scale, scale);
				matrix.translate(0, 1);
				
				for (var i:int = 0; i < listPortions; i++)
				{
					try {
						var iBitmapDrawable:IBitmapDrawable = IBitmapDrawable((scroller!=null) ? scroller : list);
						bitmapData.draw(iBitmapDrawable, matrix, null, null, new Rectangle(i*listWidth, 0, listWidth, textureHeight));
					}
					catch(err:Error) {
						trace(i+"error in bitmapData.draw :"+err.message+" scroller="+scroller+" list="+list+" scrollerHeight="+scrollerHeight);
						error = true;
					}
					matrix.translate(listWidth, -textureHeight);
				}
				
				bitmapData.fillRect(
					new Rectangle(0, 0, listWidth, 1),
					0xFF000000 | backgroundColour
				);
				
				_textureBitMapData.push(bitmapData);
				var listScrollingTexture:Texture = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
				listScrollingTexture.uploadFromBitmapData(bitmapData);
				_listScrollingTexture.push(listScrollingTexture);
			}
			
			contextResumed(false);

			isDefault(this);
			activate(this);
			onEnterFrame(this, updateLists);

			return error;
		}

/**
 * Restore shaders, streams and textures after context loss.
 */
		override public function contextResumed(running:Boolean):void {

			_listScrollingShaderProgram = _context3D.createProgram();
			_listScrollingShaderProgram.upload( _listScrollingVertexShader.agalcode, _listScrollingFragmentShader.agalcode);
			
			_xyzVertexBuffer = _context3D.createVertexBuffer(_vertexes.length / 3, 3);
			_xyzVertexBuffer.uploadFromVector(_vertexes, 0, _vertexes.length / 3);
			
			_uvVertexBuffer = _context3D.createVertexBuffer(_uv.length / 2, 2);
			
			_indexBuffer = _context3D.createIndexBuffer( _indices.length );
			_indexBuffer.uploadFromVector(_indices, 0, _indices.length );
			
			_listScrollingTexture = new Vector.<Texture>();
			for each (var bitmapData:BitmapData in _textureBitMapData) {
				var texture:Texture = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
				texture.uploadFromBitmapData(bitmapData);
				_listScrollingTexture.push(texture);
			}
			
			if (running) {
				enable();
			}
		}
		
/**
 * For accelerated slide transitions (For navigation based applications), you must specify the container component that holds the pages.
 */
		public function containerPageTextures(container:UIPages):void {
			_container = container;
			_lists = new Vector.<IContainerUI>();
			var page0:UIForm = UIForm(container.pages[container.pageNumber]);
			var point:Point = page0.localToGlobal(new Point(0,0));
			_centre = new Rectangle(
					point.x,
					point.y,
					UI.scale * page0.attributes.width,
					UI.scale * page0.attributes.height
				);
			for each (var page:Sprite in container.pages ) {
				if (page.getChildAt(0) is UIScrollVertical && _supportedLists.indexOf(UIScrollVertical(page.getChildAt(0)).xml.localName())>=0) {
					_lists.push(page.getChildAt(0));
				}
				else {
					_lists.push(page);
				}
			}
			for each (var form:IContainerUI in _lists) {
				if (form is UIForm) {
					allListTextures0(Sprite(form));
				}
			}
			listTextures(_lists);
			
			_slideXyzVertexBuffer = _context3D.createVertexBuffer(8, 3);
			_slideUvVertexBuffer = _context3D.createVertexBuffer(8, 2);
			_slideIndexBuffer = _context3D.createIndexBuffer(12);
			_slideIndexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2,  0, 2, 3,  4, 5, 6,  4, 6, 7]), 0, 12 );
		}
		
		
		public function get lists():Vector.<IContainerUI> {
			return _lists;
		}
		
/**
 * Perform an accelerated slide transitions.
 */		
 		public function slidePage(currentPage:uint, nextPage:uint, back:Boolean = false):void {
			_listRecordCurrent = _listRecords[currentPage];
			Sprite(_listRecordCurrent.container).visible = false;
			_listRecordNext = _listRecords[nextPage];
			_back = back;
			_count = 0;
			_stopping = false;
			_enabled = false;
			_context3D.setVertexBufferAt( 0, _slideXyzVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _slideUvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			
			onEnterFrame(this, onEnterFrameSlide);
			_context3D.setProgram(_listScrollingShaderProgram);
		}
		
/**
 * Calculate quad vertices at a particular slide position
 */	
		protected function offsetPage(position:Number):Vector.<Number> {
			return Vector.<Number> ([
				toGraphX(position+_centre.x),					-toGraphY(_centre.y+_centre.height-1),		0.0,
				toGraphX(position+_centre.x+_centre.width),		-toGraphY(_centre.y+_centre.height-1),		0.0,
				toGraphX(position+_centre.x+_centre.width),		-toGraphY(_centre.y-1),						0.0,
				toGraphX(position+_centre.x),					-toGraphY(_centre.y-1),						0.0
			]);
		}
		
		
		protected function prepareToStop():void {
			_stopping = true;
			if (_container) {
				Sprite(_listRecordCurrent.container).visible = true;
				_container.goToPage(_listRecordNext.textureIndex);
			}
		}
		
/**
 * Do slide
 */	
		protected function onEnterFrameSlide(event:Event):void {
			_count += INCREMENT;
			 drawSlideFrame();
			 if (_stopping) {
				slideComplete();
			 }
			 else if (_count >= 1.0-INCREMENT - 0.0001) {
				prepareToStop();
			}
		}
		
/**
 * Render sliding transition
 */	
		protected function drawSlideFrame(event:Event = null):void {
			var shift:Number = (_back ? 1.0 : -1.0) * easing(_count) * _centre.width;
			var positionCurrent:Number = shift;
			var positionNext:Number = (_back ? -1.0 : 1.0) * _centre.width + shift;
			var slidingVertices:Vector.<Number> = offsetPage(positionCurrent).concat(offsetPage(positionNext));
			_slideXyzVertexBuffer.uploadFromVector(slidingVertices, 0, 8);
			
			_uv = new Vector.<Number>();
			createUV(_listRecordCurrent);
			createUV(_listRecordNext);
			_slideUvVertexBuffer.uploadFromVector(_uv, 0, 8);
			_context3D.setVertexBufferAt( 1, _slideUvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
	
			_context3D.clear(0.9, 0.9, 0.9);
			_context3D.setTextureAt(0, _listScrollingTexture[_listRecordCurrent.textureIndex]);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([_listRecordCurrent.uvWidth, 0.0, 0.0, 1.0 ]) );	// fc0
			_context3D.drawTriangles(_slideIndexBuffer, 0, 2);
			_context3D.setTextureAt(0, _listScrollingTexture[_listRecordNext.textureIndex]);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([_listRecordNext.uvWidth, 0.0, 0.0, 1.0 ]) );	// fc0
			_context3D.drawTriangles(_slideIndexBuffer, 6, 2);
			_context3D.present();
		}
		
/**
 * Sliding transition is complete
 */	
		protected function slideComplete():void {
			setRegisters();
			_listRecordCurrent = null;
			_listRecordNext = null;
			_stopping = false;
			_enabled = true;
			_count = 1.0;
			onEnterFrame(this, updateLists);
		}
		
		
		protected function setRegisters():void {
			_context3D.setVertexBufferAt( 0, _xyzVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, _uvVertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			_context3D.setProgram(_listScrollingShaderProgram);
		}
		
		
		protected function unSetRegisters():void {
			_context3D.setVertexBufferAt( 0, null ); //va0
			_context3D.setVertexBufferAt( 1, null ); //va1
		}
		
/**
 * Render all lists on a page
 */	
		protected function drawLists():void {
			_context3D.clear(0.9, 1.0, 0.9);
			for each (var listRecord:ListRecord in _listRecords) {
				if (listRecord.container is UIScrollVertical && listRecord.onScreen) { // && (!event || !UIScrollVertical(listRecord.container).sliderVisible)) {
					_context3D.setTextureAt(0, _listScrollingTexture[listRecord.textureIndex]);
					_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([ listRecord.uvWidth, 0.0, 0.0, 1.0 ]) );	// fc0
					_context3D.drawTriangles(_indexBuffer, 6 * listRecord.textureIndex, 2);
				}
			}
			_context3D.present();
		}
		
/**
 * Cut a hole in a particular container background so that the accelerated list is visible underneath.
 */	
		public function cutRectangle(container:Sprite, rectangle:Rectangle):void {
		//	if (container is UIList) {
		//		return;
		//	}
			var topLeft:Point = container.globalToLocal(new Point(rectangle.x, rectangle.y));
			if (container is com.danielfreeman.extendedMadness.UIPanel) container.graphics.beginFill(0xffff00, 0);
			container.graphics.drawRect(topLeft.x, topLeft.y, rectangle.width, rectangle.height);
			if (container is IContainerUI && _holes.indexOf(IContainerUI(container)) < 0) {
				_holes.push(container);
			}
		}
		
/**
 * Put a hole in the MadComponents display-list UI, so you can see the accelerated Stage3D list, exactly where the display-list list is.
 * (We can seemlessly switch between the two lists - and the user is unaware of holes in th UI, or this mechanism)
 */	
		public function pokeHole(component:UIScrollVertical, rectangle:Rectangle = null, container:Sprite = null):void {
			if (!rectangle) {
				var point:Point = component.localToGlobal(new Point(0,0));
				rectangle = new Rectangle(point.x, point.y, component.attributes.width, component.height);
				container = component;
			//	cutRectangle(container, rectangle);
			}
			if (container.name=="+" || container.name=="-") {
				container.graphics.clear();
			}
			else {
				if (container != UI.uiLayer && container is IContainerUI && IContainerUI(container).attributes.backgroundColours.length> 0 && !(container is UIForm && UIForm(container).hasPickerBackground)) {
				cutRectangle(container, rectangle);
			}
			}
			if (container == UI.uiLayer) {
				cutRectangle(UI.uiLayer, rectangle);
			}
			else {
				pokeHole(component, rectangle, Sprite(container.parent));
			}
		}
		
/**
 * Is the list on a page which is visible?
 */	
		protected function isVisible(container:Sprite):Boolean {
			if (!container.visible) {
				return false;
			}
			else if (container != UI.uiLayer) {
				return isVisible(Sprite(container.parent));
			}
			return true;
		}
		
/**
 * You must call this if you change page.
 * (But if you utilise this class and accelerated page transition slides - then no need.)
 */	
		public function pageChanged():void {
			disable();
			enable();
		}
		
		
		override public function enable():void {
			if (!_enabled) {
				_enabled = true;
				_holes = new Vector.<IContainerUI>();
				for each (var listRecord:ListRecord in _listRecords) {
					var onScreen:Boolean = isVisible(Sprite(listRecord.container));
					listRecord.onScreen = onScreen;
					if (onScreen && listRecord.container is UIScrollVertical) {
						pokeHole(UIScrollVertical(listRecord.container));
						if (ALTERNATIVE_SCHEME) {
							takeOverFromListScroller(listRecord);
						}
					}
				}
				_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_screen.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			}
			setRegisters();
			makeUV();
			onEnterFrame(this, updateLists);
		}
		
		
		override public function disable():void {
			if (_enabled) {
				_enabled = false;
				for each (var container:IContainerUI in _holes) {
					container.drawComponent();
				}
				_holes = new Vector.<IContainerUI>();
				UI.drawStageBackground();
				unSetRegisters();
				_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			}
		}
		
/**
 * Mouse down handler
 */
		protected function mouseDown(event:MouseEvent):void {
			for each (var listRecord:ListRecord in _listRecords) {
				if (listRecord.onScreen && listRecord.container is UIScrollVertical) {
					var point:Point = Sprite(listRecord.container).localToGlobal(new Point(0,0));
					if (isNaN(listRecord.destination) &&
						_screen.stage.mouseX > point.x &&
						_screen.stage.mouseX < point.x + listRecord.container.attributes.width * UI.scale &&
						_screen.stage.mouseY > point.y &&
						_screen.stage.mouseY < point.y + Sprite(listRecord.container).height * UI.scale) {
							_activeList = listRecord;
						}
				}
			}
			if (_activeList) {
				_oldDelta = (_activeList == _oldActiveList) ? _activeList.delta : Number.NaN;
				startMovement(_activeList);
				_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_screen.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
				event.stopPropagation();
			}
		}
		
/**
 * The last custom-row component clicked
 */
		public function get componentChanged():DisplayObject {
			return _componentChanged;
		}
		
/**
 * Not implemented in ListScrolling - override in extended class
 */
		public function updateComponent(pageNumber:int, component:DisplayObject = null):void {
			//Not implemented
		}
		
/**
 * Update texture for last component clicked
 */
		public function updateClickedComponent():void {
			if (_activeListTextureIndex >= 0 && _componentChanged) {
				updateComponent(_activeListTextureIndex, _componentChanged);
			}
		}
		
/**
 * Mouse up handler
 */
		protected function mouseUp(event:MouseEvent):void {
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_screen.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			if (_activeList) {
				var noMove:Boolean = Math.abs(_screen.stage.mouseY - _startMouseY) < UI.scale;
				
				if (_searchHitComponent) {
					_componentChanged = _searchHitComponent;
					_screen.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, false));
					_searchHit.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
					_screen.stage.dispatchEvent(new Event(COMPONENT_CHANGED));
					_activeListTextureIndex = _activeList.textureIndex;
					
					if (!_listenForChange) {
						if (_autoUpdateComponents) {
							updateComponent(_activeList.textureIndex, _componentChanged);
						}

						if (ALTERNATIVE_SCHEME) {
							takeOverFromListScroller(_activeList);
						}
					}
				}
				else if (_clicked && _activeList.container is UIList && !_activeList.showPressed) {
					UIList(_activeList.container).clearPressed(_frameCount < HIGHLIGHT_FRAMES);
				}
				else if (_frameCount < CLICK_FRAMES && _notTooFastForClick && noMove && _activeList.container is UIList) {
					// Very brief list click heurustic
					listClick(_activeList);
					UIList(_activeList.container).clearPressed(true);
				}
				
				if (noMove && _activeList.container is UIPicker) {
					_oldActiveList = _activeList;
					_activeList = null;
					return;
				}
				else if (!_clicked) {  //  && !_searchHit
					_somethingMoving++;
					_activeList.inertia = true;
					_activeList.delta = (_screen.stage.mouseY - _lastPositionY) * MOVE_FACTOR / UI.scale;
					if (!isNaN(_oldDelta) && _activeList.delta * _oldDelta > 0 && Math.abs(_activeList.delta) > FAST_THRESHOLD && Math.abs(_oldDelta) > FAST_THRESHOLD) { // swipe twice to make it accelerate
						_activeList.delta = ACCELERATE * (_activeList.delta + _oldDelta)/2;
						trace("accelerate scrolling",_activeList.delta);
						if (_activeList.delta < - DELTA_LIMIT) {
							_activeList.delta = - DELTA_LIMIT;
						}
						else if (_activeList.delta > DELTA_LIMIT) {
							_activeList.delta = DELTA_LIMIT;
						}
					}
				}
	
				_searchHit = null;
				_searchHitComponent = null;
				_clicked = false;
				_oldActiveList = _activeList;
				_activeList = null;
			}
			else {
				_oldActiveList = null;
			}
		}
		
		
		protected function isClickOnComponent(listRecord:ListRecord):void {
			var list:UIScrollVertical = UIScrollVertical(listRecord.container);

				if (_notTooFastForClick) {
					if (ALTERNATIVE_SCHEME && list is UIList) {
						UIList(list).sliderVisible = false;
					}
					_searchHitComponent = UIScrollVertical.searchHit(list.pages[0]);
					if (_searchHitComponent is UISwitch && _autoUpdateComponents) {
						if (_listenForChange) {
							_listenForChange.removeEventListener(Event.CHANGE, changeHandler);
							_listenForChange = null;
						}
						_listenForChange = UISwitch(_searchHitComponent);
						_listenForChange.addEventListener(Event.CHANGE, changeHandler);
					}
					if (_searchHitComponent) {
						_searchHit = UIScrollVertical.searchHitChild(_searchHitComponent);
						if (ALTERNATIVE_SCHEME) {
							showRealListScroller(listRecord);
						}
					}
				}
				else {
					_searchHit = null;
					_searchHitComponent = null;
				}
		}
		
		
		protected function changeHandler(event:Event):void {
			if (_autoUpdateComponents && _componentChanged) {
				updateComponent(_activeListTextureIndex, _componentChanged);
			}
			_listenForChange.removeEventListener(Event.CHANGE, changeHandler);
			_listenForChange = null;
		//	takeOverFromListScroller(_oldActiveList);
			_delayedStage3D.reset();
			_delayedStage3D.start();
		}
		
		
		protected function showStage3D(event:TimerEvent):void {
			takeOverFromListScroller(_oldActiveList);
		}
		
/**
 * Start scroll movement
 */
		protected function startMovement(listRecord:ListRecord):void {
			var list:UIScrollVertical = UIScrollVertical(listRecord.container);
			if (!ALTERNATIVE_SCHEME || list.sliderVisible) { //|| list.sliderVisible should restore lost sync.
				doTakeOverFromListScroller(list);
			}
			_notTooFastForClick = !listRecord.inertia || Math.abs(listRecord.delta) < FAST_THRESHOLD;
			if (listRecord.inertia || !isNaN(listRecord.destination)) {
				_somethingMoving--;
				listRecord.destination = Number.NaN;
				listRecord.inertia = false;
			}

			isClickOnComponent(listRecord);
			
			_frameCount = 0;
			_lastPositionY = _startMouseY = _screen.stage.mouseY;
			_startSliderY = list.sliderY;
		}
		
/**
 * The user has swiped the screen, and removed their finger.  The scrolling motion has momentum,
 */
		protected function inertiaMovement(listRecord:ListRecord):void {
			var sliderY:Number = UIScrollVertical(listRecord.container).sliderY;
			var maximumSlide:Number = -UIScrollVertical(listRecord.container).maximumSlide;
			
		//	if (listRecord.container is UIPicker) {
		//		maximumSlide = -(listRecord.container.pages[0].height - Sprite(listRecord.container).height);
		//	}
	
			listRecord.delta *= (sliderY > 0 || sliderY < maximumSlide) ? FASTER_DECAY : DECAY;
			UIScrollVertical(listRecord.container).sliderY = sliderY + listRecord.delta;

			if (Math.abs(listRecord.delta) < DELTA_THRESHOLD) {
				listRecord.inertia = false;
				if (listRecord.container is UIPicker) {
					listRecord.destination = - UIPicker(listRecord.container).snapToCellPosition;
				}
				else if (sliderY > 0) {
					listRecord.destination = 0;
				}
				else if (sliderY < maximumSlide) {
					listRecord.destination = maximumSlide;
				}
				else {
					stopMovement(listRecord);
				}
			}
		}

/**
 * Scroll to a position
 */
		protected function destinationMovement(listRecord:ListRecord):void {
			var sliderY:Number = UIScrollVertical(listRecord.container).sliderY;
			var distance:Number = listRecord.destination - sliderY;
			if (Math.abs(distance) < MOVE_THRESHOLD) {
				stopMovement(listRecord, true);
			}
			else {
				UIScrollVertical(listRecord.container).sliderY = sliderY + distance * BOUNCE_FACTOR ;
			}
		}
		
/**
 * Stop list scrolling
 */
		protected function stopMovement(listRecord:ListRecord, destination:Boolean = false):void {
			var list:UIScrollVertical = UIScrollVertical(listRecord.container);
			if (destination) {
				list.sliderY = listRecord.destination;
			}
			if (!isNaN(listRecord.destination) || listRecord.inertia) {
				listRecord.inertia = false;
				listRecord.destination = Number.NaN;
				_somethingMoving--;
			}
			if (!ALTERNATIVE_SCHEME) {
				showRealListScroller(listRecord);
			}

		}
		
/**
 * Generate UV for each list
 */
		protected function makeUV():void {
			_uv = new Vector.<Number>();
			for each (var listRecord:ListRecord in _listRecords) {
				createUV(listRecord);
				if (_uvVertexBuffer) {
					_uvVertexBuffer.uploadFromVector(_uv, 0, _uv.length / 2);
				}
			}
		}
		
/**
 * Render lists
 */
		protected function updateLists(event:Event):void {
			
			if (_activeList) {
				_lastPositionY = _screen.stage.mouseY;
				if (!_clicked) {
					UIScrollVertical(_activeList.container).sliderY = _startSliderY + (_screen.stage.mouseY - _startMouseY); 
				}
				else if (_searchHitComponent) {
					_screen.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, false));
				}
				_frameCount++;
				if (_frameCount == CLICK_FRAMES && Math.abs(_startMouseY - _screen.stage.mouseY ) < CLICK_THRESHOLD) {
					if (_notTooFastForClick) {
						listClick(_activeList);
					}
					else {
						trace("too fast for click");
					}
				}
				else if (_clicked && _frameCount == LONG_PRESS && Math.abs(_startMouseY - _screen.stage.mouseY ) < CLICK_THRESHOLD *UI.scale) {
					(_searchHit ? _searchHit : UIScrollVertical(_activeList.container)).dispatchEvent(new Event(UIList.LONG_CLICK));
				}
			}

			if (_activeList || _somethingMoving) {
				for each (var listRecord:ListRecord in _listRecords) {
					if (listRecord.inertia) {
						inertiaMovement(listRecord);
					}
					if (!isNaN(listRecord.destination)) {
						destinationMovement(listRecord);
					}
				}
				makeUV();
			}
			drawLists();
		}
		
/**
 * Handle click on a list row
 */
		protected function listClick(listRecord:ListRecord):void {
			var list:UIScrollVertical = UIScrollVertical(listRecord.container);
			if (_searchHit) {
				_searchHit.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
				_clicked = true;
			}
			else {
				if (list is UIList && !(list is UIPicker)) {
					if (ALTERNATIVE_SCHEME) {
						showRealListScroller(listRecord);
						list.removeEventListener(UIList.CLICKED_END, clickedEndHandler);
						list.addEventListener(UIList.CLICKED_END, clickedEndHandler);
					}
					_clicked = UIList(list).doClickRow();
				}
			}
			if (_clicked) {
				stopMovement(listRecord);
			}
		}
		
/**
 * End of click sequence
 */
		protected function clickedEndHandler(event:Event):void {
			var list:UIScrollVertical = UIScrollVertical(event.currentTarget);
			doTakeOverFromListScroller(list);
			list.removeEventListener(UIList.CLICKED_END, clickedEndHandler);
		}
		
/**
 * Show the accelerated Stage3D list
 */
		protected function takeOverFromListScroller(listRecord:ListRecord):void {
			doTakeOverFromListScroller(UIScrollVertical(listRecord.container));
		}
		
/**
 * Show the accelerated Stage3D list
 */
		protected function doTakeOverFromListScroller(list:UIScrollVertical):void {//UI.uiLayer.visible = false;return;
			if (!(list is UIPicker)) {
				list.visible = false;
				list.mouseEnabled = list.mouseChildren = false;
			}
			else if (list.sliderVisible) {
				list.sliderVisible = false;
				list.graphics.clear();
				list.graphics.beginFill(0,0);
				list.graphics.drawRect(0, 0, list.attributes.width, list.attributes.height);
			}
		}
		
/**
 * Show the display-list list (you are interacting with it - not scrolling it)
 */
		protected function showRealListScroller(listRecord:ListRecord):void {//UI.uiLayer.visible = true;return;
			var list:UIScrollVertical = UIScrollVertical(listRecord.container);
			if (!(list is UIPicker)) {
				list.visible = true;
				list.mouseEnabled = list.mouseChildren = true;
			}
			else if (!list.sliderVisible) {
				list.drawComponent();
			}
			list.sliderVisible = true;
		}
		
/**
 * Clear all textures and bitmaps
 */
		protected function disposeOfTextures():void {
			for each (var bitmapData:BitmapData in _textureBitMapData) {
				bitmapData.dispose();
			}
			for each (var texture:Texture in _listScrollingTexture) {
				texture.dispose();
			}
		}
		
			
		public function freezeLists():void {
			for each (var listRecord:ListRecord in _listRecords) {
				var list:IContainerUI = listRecord.container;
				if (list is UIScrollVertical) {
					if (!(list is UIPicker)) {
						stopMovement(listRecord);
					}
					showRealListScroller(listRecord);
				}
			}
		}
		
		
		override public function destructor():void {
			super.destructor();
			_screen.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_screen.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_delayedStage3D.removeEventListener(TimerEvent.TIMER, showStage3D);
		}
	}
}
