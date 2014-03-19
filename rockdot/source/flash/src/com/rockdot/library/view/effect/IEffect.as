package com.rockdot.library.view.effect {
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import flash.display.Sprite;




	/**
	 * @author nilsdoehring
	 */
	public interface IEffect {
		function set duration(duration : Number) : void;
		function get duration() : Number;
		function set initialAlpha(initialAlpha : Number) : void;
		function get initialAlpha() : Number;
		function set type(type : String) : void;
		function get type() : String;
		function get applyRecursively() : Boolean;
		function set sprite(spr : Sprite) : void;
		function get sprite() : Sprite;
		function useSprite() : Boolean;
		function runInEffect(target : ISpriteComponent, duration : Number, callback : Function) : void;
		function runOutEffect(target : ISpriteComponent, duration : Number, callback : Function) : void;
		function cancel(target : ISpriteComponent = null) : void; 
		function destroy() : void; 
		}
}
