package com.rockdot.plugin.screen.displaylist.command.event.vo {
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	/**
	 * @author nilsdoehring
	 */
	public class ScreenDisplaylistAppearDisappearVO {
		public var target : ISpriteComponent;
		public var duration : Number;
		public var autoDestroy : Boolean;

		public function ScreenDisplaylistAppearDisappearVO(target : ISpriteComponent, duration : Number, autoDestroy : Boolean = false) {
			this.autoDestroy = autoDestroy;
			this.duration = duration;
			this.target = target;
		}
	}
}
