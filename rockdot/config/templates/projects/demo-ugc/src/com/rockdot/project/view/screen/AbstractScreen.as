package com.rockdot.project.view.screen {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.plugin.screen.displaylist.view.RockdotManagedSpriteComponent;
	import com.rockdot.project.inject.IModelAware;
	import com.rockdot.project.model.Model;


	/**
	 * @author nilsdoehring
	 */
	public class AbstractScreen extends RockdotManagedSpriteComponent implements IModelAware{
		
		protected var _appModel : Model;
		public function set appModel(appModel : Model) : void {
			_appModel = appModel;
		}

		public function AbstractScreen(id : String) {
			super(id);
		}
		
		override public function init(data : * = null) : void {
			
			super.init(data);
			
		}
		
		
		override public function setSize(w : int, h : int) : void {
			super.setSize(BootstrapConstants.WIDTH_STAGE - 2*BootstrapConstants.X_PAGES, BootstrapConstants.HEIGHT_STAGE - BootstrapConstants.Y_PAGES - BootstrapConstants.HEIGHT_RASTER - 2*BootstrapConstants.SPACER);
		}
		
		
		override public function render() : void {
			super.render();
			x = BootstrapConstants.X_PAGES;
			y = BootstrapConstants.Y_PAGES;
		}
		
		override public function appear(duration : Number = 0.5) : void {
//			super.appear(duration);
//			TweenLite.to(this, duration, {autoAlpha:1});
			_onAppear();
		}

		override public function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void {
//			super.disappear(duration, autoDestroy);
//			TweenLite.to(this, duration, {autoAlpha:0});
			_onDisappear();
		}

		
		
	}
}
