package com.rockdot.project.view.layer {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.plugin.screen.displaylist.view.RockdotManagedSpriteComponent;
	import com.rockdot.project.inject.IModelAware;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.model.Model;
	import com.rockdot.project.view.text.Headline;

	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFieldAutoSize;



	/**
	 * @author nilsdoehring
	 */
	public class AbstractLayer extends RockdotManagedSpriteComponent implements IModelAware{
		
		protected static const LAYER_Y : int = 60;
		protected static const LAYER_WIDTH_MAX : int = 480;

		protected var _appModel : Model;
		public function set appModel(appModel : Model) : void {
			_appModel = appModel;
		}
		
		protected var _headline : Headline;
		protected var _headlineY : int;
		protected var _bg : Sprite;
		

		public function AbstractLayer(id : String) {
			super(id);
		}
		
		override public function init(data : * = null) : void {
			
			super.init(data);
			
			// bg image
			_bg = new Sprite();
			_bg.filters = [new GlowFilter(0x000000, .5)];
			addChild(_bg);

			_headlineY = BootstrapConstants.SPACER;
			_headline = new Headline(getProperty("headline"), 24, Colors.GREY_DARK);
			_headline.autoSize = TextFieldAutoSize.CENTER;
			addChild(_headline);
		}
		
		override public function setSize(w : int, h : int) : void {
			super.setSize(Math.min(LAYER_WIDTH_MAX, BootstrapConstants.WIDTH_STAGE), BootstrapConstants.HEIGHT_STAGE);
		}
		
		override public function render() : void {
			super.render();
			
			//background
			_bg.graphics.clear();
			
			var bgMatrix : Matrix = new Matrix();
			bgMatrix.createGradientBox(_width, height, Math.PI * 3 / 2);
			_bg.graphics.beginGradientFill(GradientType.LINEAR, [Colors.WHITE, Colors.BACKGROUND_COLOR], [1, 1], [127, 255], bgMatrix);
			_bg.graphics.drawRoundRect(0, 0, _width, height + 3*BootstrapConstants.SPACER, 8, 8);
			_bg.graphics.endFill();

			// position center
			x = BootstrapConstants.WIDTH_STAGE / 2 - _bg.width / 2;
			y = BootstrapConstants.HEIGHT_STAGE / 2 - _bg.height / 2;

		}
		
		override public function appear(duration : Number = 0.5) : void {
			super.appear(duration);
		//	TweenLite.to(this, duration, {autoAlpha:1, onComplete:_didAppear});
		}

		override public function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void {
			super.disappear(duration, autoDestroy);
		//	TweenLite.to(this, duration, {autoAlpha:0, onComplete:_didDisappear});
		}

		
		
	}
}
