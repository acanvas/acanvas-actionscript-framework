package com.rockdot.project.view.element.home {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.project.model.Assets;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Copy;

	import flash.display.Bitmap;

	/**
	 * @author nilsdoehring
	 */
	public class HomeHeader extends RockdotSpriteComponent {
		
		private var _imageCloud : Bitmap;
		private var _copy : Copy;
	
		public function HomeHeader(id:String) {
			super();
			name = id;
			
			_copy = new Copy(getProperty("copy"), 18, Colors.BLACK);
			addChild(_copy);

			// Image cloud
			_imageCloud = Assets.home_imagecloud;
			addChild(_imageCloud);
			
		}
		
		
		override public function render() : void {
			super.render();
			
			_copy.width = 310;
			_copy.x = 2*BootstrapConstants.SPACER;
			_copy.y = 2*BootstrapConstants.SPACER;
			
			if(_width < _copy.x + _copy.textWidth + _imageCloud.width + 70){
				_imageCloud.visible = false;
			}
			else{
				_imageCloud.visible = true;
				_imageCloud.scaleX = _imageCloud.scaleY = 0.85;
				_imageCloud.x = Math.round( _width - _imageCloud.width - 50);
				_imageCloud.y = - BootstrapConstants.HEIGHT_RASTER - BootstrapConstants.SPACER;
			}
		}
		
		
		override public function get height() : Number {
			return _copy.y + _copy.textHeight;
		}
		
	}
}
