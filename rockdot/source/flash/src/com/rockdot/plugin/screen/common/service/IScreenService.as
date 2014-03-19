package com.rockdot.plugin.screen.common.service {
	import com.rockdot.plugin.screen.displaylist.view.ManagedSpriteComponent;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.BitmapFilter;






	/**
	 * @author nilsdoehring
	 */
	public interface IScreenService {
		
		function get initialized() : Boolean;
		
		function get background() : ManagedSpriteComponent;
		function get content() : ManagedSpriteComponent;
		function get navi() : ManagedSpriteComponent;
		function get layer() : ManagedSpriteComponent;
		function get foreground() : ManagedSpriteComponent;

		function get stage() : Stage;

		function get modalBackgroundFilter() : BitmapFilter;
		function set modalBackgroundFilter(filter : BitmapFilter) : void;

		function init(callback : Function = null) : void;
		function resize(event : Event = null) : void;

		function lock() : void;
		function unlock() : void;
		
	}
}
