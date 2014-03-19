package com.rockdot.plugin.screen.displaylist.view {
	import com.rockdot.plugin.screen.common.view.IScreen;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;


	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public interface ISpriteComponent extends IScreen, IDisplayObject {
		
		function setSize(w : int, h : int) : void;
		
		function destroy() : void;
		function appear(duration : Number = 0.5) : void;
		function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void;
		
		//--
		
		function get enabled() : Boolean;
		function set enabled(value : Boolean) : void;

		function getAsBitmapData(rect : Rectangle = null, transparent : Boolean = true, fillColor : uint = 0xFFFFFFFF) : BitmapData;

		function getWidth() : int;
		function setWidth(w : int) : void;
		
		function getHeight() : int;
		function setHeight(h : int) : void;
		
		function render() : void;
		
		/**
		 * Ignore
		 */
		function get ignoreSetEnabled() : Boolean;
		function set ignoreSetEnabled(value : Boolean) : void;
		
		function get ignoreSetTouchEnabled() : Boolean;
		function set ignoreSetTouchEnabled(value : Boolean) : void;
		
		function get ignoreCallDestroy() : Boolean;
		function set ignoreCallDestroy(value : Boolean) : void;
		
		function get ignoreCallSetSize() : Boolean;
		function set ignoreCallSetSize(value : Boolean) : void;
	}
}
