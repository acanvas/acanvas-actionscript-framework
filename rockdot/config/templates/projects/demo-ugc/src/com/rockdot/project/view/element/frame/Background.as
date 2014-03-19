package com.rockdot.project.view.element.frame {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.plugin.screen.displaylist.view.RockdotManagedSpriteComponent;
	import com.rockdot.project.model.Colors;

	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;





	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class Background extends RockdotManagedSpriteComponent{
		private var _top : Header;
		private var _bottom : Footer;
		private var _bg : Shape;


		public function Background(id : String)
		{
				super(id);
				_ignoreCallSetSize = false;
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);

			// bg grey
			_bg = new Shape();
			addChild(_bg);
			
			_top = new Header();
			addChild(_top);

			_bottom = new Footer();
			addChild(_bottom);
			
			_didInit();
		}
		
		
		override public function setSize(w : int, h : int) : void {
			super.setSize(BootstrapConstants.WIDTH_STAGE, BootstrapConstants.HEIGHT_STAGE);
		}

		override public function render() : void {
			super.render();
			
			if(_bg){
				var bgMatrix : Matrix = new Matrix();
				bgMatrix.createGradientBox(_width, _height, Math.PI * 3 / 2);
			
				_bg.graphics.clear();
				_bg.graphics.beginGradientFill(GradientType.LINEAR, [Colors.BACKGROUND_COLOR, Colors.GREY_LIGHT], [1, 1], [127, 255], bgMatrix);
				_bg.graphics.drawRoundRect(0, 0, _width, _height, 8, 8);
				_bg.graphics.endFill();
			}
			if(_top){
				_top.x = BootstrapConstants.SPACER;
				_top.y = BootstrapConstants.SPACER;
				_top.setSize(_width - 2*BootstrapConstants.SPACER, BootstrapConstants.HEIGHT_RASTER);
			}
			if(_bottom){
				_bottom.x = BootstrapConstants.SPACER;
				_bottom.y = _height - BootstrapConstants.HEIGHT_RASTER;
				_bottom.setSize(_width - 2*BootstrapConstants.SPACER, BootstrapConstants.HEIGHT_RASTER);
			}
		}

	}
}
