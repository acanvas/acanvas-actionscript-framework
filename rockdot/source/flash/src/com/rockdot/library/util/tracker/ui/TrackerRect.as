package com.rockdot.library.util.tracker.ui {
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	
	//==================================================================
	public class TrackerRect extends Sprite {
		
		//==================================================================
		public static const DEBUG:Boolean = true;
		
		private var _color:int;
		private var _width:int;
		private var _height:int;
		
		//==================================================================
		public function TrackerRect( width:int=32, height:int=32, color:int=0xFFFFFF ) {
			
			this._width = width;
			this._height = height;
			this._color = color;
			
			filters = [new DropShadowFilter(1,90,0x000000,1,4,4,3,2)];
			
			update();
		}
		
		override public function set width( w:Number ):void {
			this._width = w;
			update();
		}
		override public function get width():Number {
			return super.width;
		}
		
		override public function set height( h:Number ):void {
			this._height = h;
			update();
		}
		override public function get height():Number {
			return super.height;
		}
		
		public function get color():int {		return _color;		} 
		public function set color( c:int ):void {
			_color = c;
			update();
		}
		
		//==================================================================
		override public function toString():String {
			return "[ TrackerRect ]";
		}
		private function log( msg:Object ):void {
			if(DEBUG) trace(this+"\t"+msg);
		}
		
		private function update():void {
			graphics.clear();
			graphics.lineStyle(1, _color);
			graphics.drawRect( -_width*0.5, -_height*0.5, _width, _height );
		}
	}
	
}