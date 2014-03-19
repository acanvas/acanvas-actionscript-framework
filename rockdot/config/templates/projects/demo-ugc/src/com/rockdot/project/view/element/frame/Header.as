package com.rockdot.project.view.element.frame {
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.project.model.Assets;
	import com.rockdot.project.view.element.shared.IAMLogo;

	import flash.display.Bitmap;

	/**
	 * @author nilsdoehring
	 */
	public class Header extends RockdotSpriteComponent {
		private var _logo : IAMLogo;
		private var _icon : Bitmap;
		private var _menu : AbstractMenuBar;
		public function Header() {
			name = "element.header";
			super();
			
			_logo = new IAMLogo(getProperty("logo.text"));
			addChild(_logo);
			
			_icon = Assets.icon_nikon;
			addChild(_icon);
			
			_menu = new MenuBar(name + ".menu");
			_menu.ignoreCallSetSize = true;
			addChild(_menu);
		}
		
		
		override public function render() : void {
			super.render();
			_icon.x = Math.round(_width - _icon.width);
			_icon.y = Math.round(_logo.height/2 - _icon.height/2);
			_menu.y = Math.round(_logo.height + 10);
			_menu.setWidth(_width);
			
		}
	}
}
