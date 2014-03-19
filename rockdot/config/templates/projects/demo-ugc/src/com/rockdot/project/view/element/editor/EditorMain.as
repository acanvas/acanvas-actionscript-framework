package com.rockdot.project.view.element.editor {
	import com.greensock.TweenLite;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.library.view.component.common.form.ComponentDropdown;
	import com.rockdot.plugin.io.inject.IIOModelAware;
	import com.rockdot.plugin.io.model.IOModel;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.project.inject.IModelAware;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.model.Model;
	import com.rockdot.project.view.element.button.YellowButton;

	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;

	public class EditorMain extends RockdotSpriteComponent implements IIOModelAware, IModelAware
	{
		private var _cmpPhotoEditor : IAMPhotoEditor;
		private var _mask : Shape;
		
		private var _btnSave : YellowButton;
		private var _btnClear : YellowButton;
		
		private var _quoteEditor : IAMLogoEditor;
		private var _bg : Shape;
		
		private var _appModel : Model;
		public function set appModel(appModel : Model) : void {
			_appModel = appModel;
		}
		
		private var _ioModel : IOModel;

		public function set ioModel(ioModel : IOModel) : void {
			_ioModel = ioModel;
		}

		public function set nikonModel(nikonModel : Model) : void {
			_appModel = nikonModel;
		}

		/**
		 * Holds the image, move/zoom functionality, quote editor
		 */
		public function EditorMain(id:String)
		{
			super();
			name = id;
			
			// bg
			_bg = new Shape();
			addChild(_bg);
			
			// holder
			_cmpPhotoEditor = new IAMPhotoEditor(id + ".editor");
			_cmpPhotoEditor.visible = false;
			_cmpPhotoEditor.alpha = 0;
			addChild(_cmpPhotoEditor);
			
			// mask
			_mask = new Shape();
			addChild(_mask);
			
			_cmpPhotoEditor.mask = _mask;
			
			// quote editor
			_quoteEditor = new IAMLogoEditor(name + ".quotes");
			_quoteEditor.submitCallback = _onRolloutChange;
			addChild(_quoteEditor);

			// buttons clear/save
			_btnSave = new YellowButton(getProperty("button.save"));
			_btnSave.submitCallback = _save;
			addChild(_btnSave);
			
			_btnClear = new YellowButton(getProperty("button.clear"));
			_btnClear.submitCallback = _clearImage;
			addChild(_btnClear);

			_hideGui();
		}

		override public function render() : void
		{
			super.render();
			
			// buttons clear/save - below the image!!!!
			_btnClear.x		= 0;
			_btnClear.y		= _height - BootstrapConstants.HEIGHT_RASTER - BootstrapConstants.SPACER;
			_btnClear.setWidth( _width/2 - BootstrapConstants.SPACER/2 );
			_btnSave.x		= _width/2 + BootstrapConstants.SPACER/2;
			_btnSave.y		= _height - BootstrapConstants.HEIGHT_RASTER - BootstrapConstants.SPACER;
			_btnSave.setWidth( _width/2 - BootstrapConstants.SPACER/2 );

			// IMAGE AREA SIZE !!!
			var contentWidth : int = _width;
			var contentHeight : Number = _btnSave.y - BootstrapConstants.SPACER;
			
			// bg - within the image!
			var fillType : String = GradientType.RADIAL;
			var colors : Array = [0x606060, 0x363636];
			var alphas : Array = [1, 1];
			var ratios : Array = [0x00, 0xFF];
			var matr : Matrix = new Matrix();
			matr.createGradientBox(contentWidth, contentHeight - 2*BootstrapConstants.SPACER, 0, 0, 0);
			_bg.graphics.clear();
			_bg.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr);
			_bg.graphics.drawRoundRect(0, BootstrapConstants.SPACER, contentWidth, contentHeight - 2*BootstrapConstants.SPACER, 8, 8);
			_bg.graphics.endFill();
			
			
			//buttons
			_cmpPhotoEditor.setSize(contentWidth, contentHeight);
			_cmpPhotoEditor.y = BootstrapConstants.SPACER;			
			
			// quote editor
			_quoteEditor.setSize(contentWidth, contentHeight);
			_quoteEditor.y = BootstrapConstants.SPACER;			
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(Colors.BACKGROUND_COLOR, 1);
			_mask.graphics.drawRoundRect(0, BootstrapConstants.SPACER, contentWidth, contentHeight - 2*BootstrapConstants.SPACER, 8, 8);
			_mask.graphics.endFill();
		}
		
		/**
		 * Callback for Rollout Button Click and Rollout Entry Click
		 */
		private function _onRolloutChange(text : String) : void {
			switch(text){
				case IAMLogoEditor.DRAG_START:
					_cmpPhotoEditor.disappear();
				break;
				case IAMLogoEditor.DRAG_STOP:
					_cmpPhotoEditor.appear();
				break;
				case ComponentDropdown.ROLLOUT_CLOSE:
					_cmpPhotoEditor.appear();
					TweenLite.to(_cmpPhotoEditor.getPhoto(), 0.5, {alpha:1});
				break;
				case ComponentDropdown.ROLLOUT_OPEN:
					_cmpPhotoEditor.disappear();
					TweenLite.to(_cmpPhotoEditor.getPhoto(), 0.5, {alpha:0});
				break;
			}
		}

		private function _save() : void
		{
			hideControls();
			_appModel.iamline = _quoteEditor.iamInputText;
			_appModel.iamtype = _quoteEditor.getQuoteType();
			_appModel.image = _cmpPhotoEditor.getPhoto();
			_appModel.quote = _quoteEditor;
			_submitCallback.call(null);
		}

		public function setBitmap(image : Bitmap) : void
		{
			_cmpPhotoEditor.setPhoto(image);
			
			// show GUI
			TweenLite.to(_cmpPhotoEditor, 0.5, {autoAlpha:1});
			_showGui();
			
		}

		/***********************************************************************
		 * open confirmation layer
		 ***********************************************************************/
		public function hideControls() : void
		{
			_hideGui();

			_quoteEditor.hideArrows();
		}

		public function showControls() : void
		{
			_showGui();

			_quoteEditor.showArrows();
		}

		/***********************************************************************
		 * clear image
		 ***********************************************************************/
		private function _clearImage() : void
		{
			_hideGui();

			TweenLite.to(_cmpPhotoEditor, 0.5, {autoAlpha:0, onComplete:_clearImageTotal});

			_quoteEditor.minimize();
		}

		private function _clearImageTotal() : void
		{
			_cmpPhotoEditor.reset();
		}

		/***********************************************************************
		 * show/hide gui
		 ***********************************************************************/
		private function _hideGui() : void
		{
			_btnSave.visible = false;
			_btnClear.visible = false;

		}

		private function _showGui() : void
		{
			_btnSave.visible = true;
			_btnClear.visible = true;
		}

		
	}
}
