package com.rockdot.library.util.tracker.ui {
	import com.rockdot.library.util.tracker.events.ColorPanelEvent;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	//==================================================================
	public class ColorPanel extends Sprite {
		
		//==================================================================
		public static const DEBUG:Boolean = true;
		
		private var _color:int;
		private var _width:int;
		private var _height:int;
		
		private var txt:TextField;
		private var sprite:Sprite;
		private var selector:ColorSelector;
		
		private var txtFilters:Array;
		
		//==================================================================
		public function ColorPanel( width:int=256, height:int=32, color:int=0 ) {
			
			this._width = width;
			this._height = height;
			this._color = color;
			
			txtFilters = [new DropShadowFilter(1,90,0x000000,0.5,4,4,3,2)];
			
			sprite = new Sprite();
			
			txt = new TextField();
			txt.defaultTextFormat = new TextFormat("Verdana",11,0xFFFFFF);
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.selectable = false;
			
			selector = new ColorSelector();
			
			addChild( sprite );
			addChild( txt );
			
			update();
			
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
		}
		
		public function get color():int {		return _color;		} 
		public function set color( c:int ):void {
			_color = c;
			update();
		}
		
		//==================================================================
		override public function toString():String {
			return "[ ColorPanel ]";
		}
		private function log( msg:Object ):void {
			if(DEBUG) trace(this+"\t"+msg);
		}
		
		private function update():void {
			sprite.graphics.clear();
			sprite.graphics.beginFill( _color );
			sprite.graphics.drawRect(0,0,_width,_height);
			sprite.graphics.endFill();
			
			var r:int = (_color&0xFF0000)>>16;
			var g:int = (_color&0x00FF00)>>8;
			var b:int = (_color&0x0000FF);
			
			txt.text = "rgb: "+r+","+g+","+b;
			txt.filters = txtFilters;
			txt.x = 0.5*(sprite.width-txt.width);
			txt.y = 0.5*(sprite.height-txt.height);
		}
		
		private function mouseDownHandler( evt:MouseEvent ):void {
			addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			addEventListener( MouseEvent.ROLL_OUT, mouseUpHandler );
			selector.addEventListener( MouseEvent.MOUSE_MOVE, selectorMoveHandler );
			
			selector.x = mouseX -selector.width*0.5;
			selector.y = mouseY -selector.height*0.5;
			
			addChild( selector );
		}
		private function selectorMoveHandler( evt:MouseEvent ):void {
			color = selector.getColorAt( evt.localX, evt.localY );
		}
		private function mouseUpHandler( evt:MouseEvent ):void {
			removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			removeEventListener( MouseEvent.ROLL_OUT, mouseUpHandler );
			selector.removeEventListener( MouseEvent.MOUSE_MOVE, selectorMoveHandler );
			
			dispatchEvent( new ColorPanelEvent( ColorPanelEvent.COLOR_SELECTED, _color ));
			
			removeChild( selector );
		}
	}
	
}