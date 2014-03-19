package com.rockdot.plugin.screen.displaylist.view {
	/**
	 * @author nilsdoehring
	 */
	public interface IManagedSpriteComponent extends ISpriteComponent {
		
		function init(data : * = null) : void;
		function load(data : * = null) : void;

		function setData(data : *) : void;

		function get isInitialized() : Boolean
		function get isLoaded() : Boolean
		
	}
}
