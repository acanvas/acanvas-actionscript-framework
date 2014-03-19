package com.rockdot.project.view.element.editor {
	import com.greensock.TweenLite;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.project.inject.IModelAware;
	import com.rockdot.project.model.Model;

	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;




	public class IAMPhotoEditor extends RockdotSpriteComponent implements IModelAware
	{
		private var _photo : Bitmap;
		
		private var _shaBackground : Shape;
		private var _btnZoomOut : IAMPhotoEditorScaleButton;
		private var _btnZoomIn : IAMPhotoEditorScaleButton;
		private var _btnTop : IAMPhotoEditorMoveButton;
		private var _btnRight : IAMPhotoEditorMoveButton;
		private var _btnBottom : IAMPhotoEditorMoveButton;
		private var _btnLeft : IAMPhotoEditorMoveButton;
		
		private var _intPhotoLeftX : int;
		private var _intPhotoRightX : int;
		private var _intPhotoWidthCurrent : int;
		private var _intPhotoHeightCurrent : int;
		private var _intPhotoWidthOriginal : int;
		private var _intPhotoHeightOriginal : int;
		
		private var _appModel : Model;
		private var _sprButtonHolder : Sprite;
		public function set appModel(appModel : Model) : void {
			_appModel = appModel;
		}

		/**
		 * Holds the image and move/zoom functionality
		 */
		public function IAMPhotoEditor(id : String)
		{
			super();
			name = id;
			
			_sprButtonHolder = new Sprite();
			addChild(_sprButtonHolder);
			
			// buttons zoom
			_shaBackground = new Shape();
			_shaBackground.graphics.beginFill(0x1e1e1e);
			_shaBackground.graphics.drawRoundRect(0, 0, BootstrapConstants.HEIGHT_RASTER + 3*BootstrapConstants.SPACER, BootstrapConstants.HEIGHT_RASTER, 4, 4);
			_sprButtonHolder.addChild(_shaBackground);
			
			_btnZoomOut = new IAMPhotoEditorScaleButton("minus");
			_btnZoomOut.submitCallback = _zoomOut;
			_sprButtonHolder.addChild(_btnZoomOut);
			
			_btnZoomIn = new IAMPhotoEditorScaleButton("plus");
			_btnZoomIn.submitCallback = _zoomIn;
			_sprButtonHolder.addChild(_btnZoomIn);

			// buttons move
			_btnTop = new IAMPhotoEditorMoveButton();
			_btnTop.rotation = -90;
			_btnTop.submitCallback = _move;
			_btnTop.submitCallbackParams = ["up"];
			_sprButtonHolder.addChild(_btnTop);
			
			_btnBottom = new IAMPhotoEditorMoveButton();
			_btnBottom.rotation = 90;
			_btnBottom.submitCallback = _move;
			_btnBottom.submitCallbackParams = ["down"];
			_sprButtonHolder.addChild(_btnBottom);
			
			_btnLeft = new IAMPhotoEditorMoveButton();
			_btnLeft.scaleX = -1;
			_btnLeft.submitCallback = _move;
			_btnLeft.submitCallbackParams = ["left"];
			_sprButtonHolder.addChild(_btnLeft);
			
			_btnRight = new IAMPhotoEditorMoveButton();
			_btnRight.submitCallback = _move;
			_btnRight.submitCallbackParams = ["right"];
			_sprButtonHolder.addChild(_btnRight);
			
		}

		override public function render() : void
		{
			super.render();
			
			// buttons zoom - within the image!
			_shaBackground.x		= _width - _shaBackground.width - BootstrapConstants.SPACER;
			_shaBackground.y		= BootstrapConstants.SPACER;
			_btnZoomOut.x	= _shaBackground.x + BootstrapConstants.SPACER;
			_btnZoomOut.y	= _shaBackground.y + BootstrapConstants.SPACER;
			_btnZoomIn.x	= _btnZoomOut.x + _btnZoomOut.width + BootstrapConstants.SPACER;
			_btnZoomIn.y	= _btnZoomOut.y;
			
			
			// buttons move - within the image!
			_btnTop.x		= _width / 2;
			_btnTop.y		= BootstrapConstants.SPACER + _btnTop.height/2;
			_btnBottom.x	= _width / 2;
			_btnBottom.y	= _height-BootstrapConstants.SPACER - _btnBottom.height/2 ;
			_btnLeft.x		= BootstrapConstants.SPACER + _btnLeft.width/2;
			_btnLeft.y		= (_height)/2;
			_btnRight.x		= _width - BootstrapConstants.SPACER - _btnRight.width/2;
			_btnRight.y		= (_height)/2;
			
		}
		
		override public function appear(duration : Number = 0.5) : void {
			super.appear(duration);
			TweenLite.to(_sprButtonHolder, duration, {autoAlpha:1});
		}

		override public function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void {
			super.disappear(duration, autoDestroy);
			TweenLite.to(_sprButtonHolder, duration, {autoAlpha:0});
		}

		public function setPhoto(image : Bitmap) : void
		{
			// image
			_photo = image;
			_photo.smoothing = true;

			_intPhotoWidthOriginal = _photo.width;
			_intPhotoHeightOriginal = _photo.height;


			_updateBitmapPositions();
			addChildAt(_photo, 0);
		}
		
		public function getPhoto() : Bitmap {
			return _photo;
		}

		public function reset() : void {
			if(_photo){
				disposeChild(_photo);
			}
		}
		
		private function _updateBitmapPositions() : void
		{
			var newHeight : Number;
			var newWidth : Number;

			var scale : Number;
			if (_photo.width >= _photo.height) {
				
				// landscape

				scale = _width / _photo.width;

				// falls die Höhe des Bildes zu gering ist ...
				newWidth = _photo.width * scale;
				newHeight = _photo.height * scale;
				if (newHeight < _height) {
					_log.info("landcape: height too small!");
					newHeight = _height;
					newWidth = _photo.width * newHeight / _photo.height;
				}

				_intPhotoLeftX = 0;
				_intPhotoRightX = _width;
				
			} else {
				
				// portrait

				scale = _height / _photo.height;

				// falls die Breite des Bildes zu gering ist ...
				newWidth	= _photo.width * scale;
				newHeight	= _photo.height * scale;
				if (newWidth < _width) {
					_log.info("portrait: width too small!");
					newWidth = _width;
					newHeight = _photo.height * newWidth / _photo.width;
				}

				_intPhotoLeftX	= _width/2 - newWidth / 2;
				_intPhotoRightX	= _width/2 + newWidth / 2;
				
			}

			_intPhotoWidthCurrent = _intPhotoRightX - _intPhotoLeftX;
			_intPhotoHeightCurrent = _height;

			_photo.width	= newWidth;
			_photo.height	= newHeight;
			_photo.x		= ( _width - _photo.width ) / 2;
			_photo.y		= ( _height - _photo.height ) / 2;
			
			
			
			
		}


		/***********************************************************************
		 * move image
		 ***********************************************************************/
		private function _move(dir : String) : void
		{
			var step : Number = 20;
			var newX : Number = _photo.x;
			var newY : Number = _photo.y;
			var temp : Number;

			switch( dir ) {
				case "up":
					_log.info("----- _move . up : " + _photo.y + " + " + _photo.height + " - " + step + " >= " + _intPhotoHeightCurrent);
					temp = _photo.y + _photo.height - step;
					if ( temp >= _intPhotoHeightCurrent ) {
						newY -= step;
					} else {
						newY = -_photo.height + _intPhotoHeightCurrent;
					}
					break;
				case "down":
					temp = _photo.y + step;
					if ( temp <= 0 ) {
						newY += step;
					} else {
						newY = 0;
					}
					break;
				case "left":
					temp = _photo.x + _photo.width - step;
					if ( temp >= _intPhotoRightX ) {
						newX -= step;
					} else {
						newX = _intPhotoLeftX - _photo.width + _intPhotoWidthCurrent;
					}
					break;
				case "right":
					temp = _photo.x + step;
					if ( temp <= _intPhotoLeftX ) {
						newX += step;
					} else {
						newX = _intPhotoLeftX;
					}
					break;
				default:
			}

			TweenLite.to(_photo, 0.3, {x:newX, y:newY});
		}

		private function _zoomOut() : void {
			var numScale : Number = _photo.scaleX;
			
			var newWidth : Number = _intPhotoWidthOriginal * (numScale - .1);
			var newHeight : Number = _intPhotoHeightOriginal * (numScale - .1);
			var newX : Number = _photo.x + (_photo.width - newWidth) / 2;
			var newY : Number = _photo.y + (_photo.height - newHeight) / 2;

			if ( newX > _intPhotoLeftX ) {
				_log.info("bild muss links anstossen");
				newX = _intPhotoLeftX;
			}
			if ( newX + newWidth < _intPhotoRightX ) {
				_log.info("bild muss rechts anstossen");
				newX = _intPhotoRightX - newWidth;
			}
			if ( newY > 0 ) {
				_log.info("bild muss oben anstossen");
				newY = 0;
			}
			if ( newY + newHeight < _intPhotoHeightCurrent ) {
				_log.info("bild muss unten anstossen");
				newY = _intPhotoHeightCurrent - newHeight;
			}

			if ( newWidth >= _width && newHeight >= _height  ) {
				numScale -= .1;

				// bild so platzieren, dass einen etwaige lücke am rand wieder aufgefüllt wird
				TweenLite.to(_photo, .5, {x:newX, y:newY, transformAroundCenter:{scaleX:numScale, scaleY:numScale}});
			}
		}

		private function _zoomIn() : void {
			var numScale : Number = _photo.scaleX + .1;
			TweenLite.to(_photo, .5, {transformAroundCenter:{scaleX:numScale, scaleY:numScale}});
		}

		
	}
}
