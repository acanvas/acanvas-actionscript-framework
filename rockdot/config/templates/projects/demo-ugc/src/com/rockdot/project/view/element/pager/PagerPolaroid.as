package com.rockdot.project.view.element.pager {
	import com.greensock.OverwriteManager;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.library.view.component.common.form.ComponentPager;
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.plugin.io.model.DataProxy;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;
	import com.rockdot.plugin.ugc.command.event.UGCEvents;
	import com.rockdot.plugin.ugc.command.event.vo.UGCFilterVO;
	import com.rockdot.plugin.ugc.model.vo.UGCImageItemVO;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Copy;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class PagerPolaroid extends ComponentPager {
		private static const PHOTO_W_H : Number = 120;
		private static const PHOTO_SPACER : Number = 100;
		protected static const WIDTH_BUTTON : Number = BootstrapConstants.HEIGHT_RASTER;
		protected var _imageListMask : Sprite;
		protected var _tfNothingFound : UITextField;
		private var _bg : Shape;
		private var _photos : Array;

		public function PagerPolaroid() {
			name = "element.pager.single";

			super();

			// bg
			_bg = new Shape();
			addChildAt(_bg, 0);

			_imageListMask = new Sprite();
			addChild(_imageListMask);

			_holder.mask = _imageListMask;

			// gallery display
			_chunkSize = 50;
			var pagerProxy : DataProxy = new DataProxy();
			pagerProxy.dataRetrieveCommand = _context.getObject(UGCEvents.ITEMS_FILTER);
			pagerProxy.dataFilterVO = new UGCFilterVO(UGCFilterVO.CONDITION_ALL, UGCFilterVO.ORDER_DATE_DESC, _chunkSize);
			proxy = pagerProxy;

			_btnPrev = new PagerPrevNextButton(getProperty("button.prev"));
			_btnPrev.submitCallback = _onClickPrev;
			addChild(_btnPrev);

			_btnNext = new PagerPrevNextButton(getProperty("button.next"));
			_btnNext.submitCallback = _onClickNext;
			addChild(_btnNext);
		}

		// override public function setSize(w : int, h : int) : void {
		// super.setSize(w - 2*WIDTH_BUTTON, h);
		// }
		override public function render() : void {
			rows = Math.floor(_height / (PHOTO_W_H));
			_chunkSize = _rows * Math.floor(_width / (PHOTO_W_H));

			super.render();

			_imageListMask.graphics.clear();
			_imageListMask.graphics.beginFill(Colors.HIGHLIGHT, .3);
			_imageListMask.graphics.drawRect(0, 0, _width, _height);
			_imageListMask.graphics.endFill();

			// bg - within the image!
			var fillType : String = GradientType.RADIAL;
			var colors : Array = [0x606060, 0x363636];
			var alphas : Array = [1, 1];
			var ratios : Array = [0x00, 0xFF];
			var matr : Matrix = new Matrix();
			matr.createGradientBox(_imageListMask.width, _imageListMask.height, 0, 0, 0);
			_bg.graphics.clear();
			_bg.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr);
			_bg.graphics.drawRect(0, 0, _imageListMask.width, _imageListMask.height);
			_bg.graphics.endFill();

			if (_loaded == true) {
				if (_holder.numChildren > 0) {
					disposeChild(_holder.getChildAt(0));
				}

				resetAndLoad();
			}

			_holder.x = 0;
			// WIDTH_BUTTON;
			_imageListMask.x = _holder.x;

			_btnPrev.setSize(WIDTH_BUTTON, _rows * (_listItemHeight + _listItemSpacer));
			_btnPrev.x = WIDTH_BUTTON;
			_btnPrev.y = _height - _btnPrev.height;
			_btnPrev.scaleX = -1;

			_btnNext.setSize(WIDTH_BUTTON, _rows * (_listItemHeight + _listItemSpacer));
			_btnNext.x = _width - WIDTH_BUTTON;
			_btnNext.y = _height - _btnNext.height;

			if (_tfNothingFound) {
				_tfNothingFound.x = WIDTH_BUTTON + BootstrapConstants.SPACER;
			}
		}

		override public function appear(duration : Number = 0.5) : void {
			super.appear(duration);
			if (_photos != null) {
				if (_photos && _photos.length != 0) {
					var n : uint = _photos.length;
					for (var i : int = 0; i < n; i++) {
						TweenLite.to(_photos[i], duration, {x:_photos[i].xPos - 100, delay:i * 0.05});
					}
				}
			}
		}

		override public function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void {
			var n : uint = _photos.length;
			for (var i : int = 0; i < n; i++) {
				TweenLite.to(_photos[i], duration, {x:-_photos[i].width - 100, delay:(i * 0.05)});
			}
		}

		override public function setData(data : *) : void {
			if (_pressedNext == true) {
				_pageChange(super.setData, data, -_holder.width, _imageListMask.x + _imageListMask.width, 0);
			} else {
				_pageChange(super.setData, data, _imageListMask.width, -_imageListMask.width, 0);
			}

			_loaded = false;
			render();
			_loaded = true;
		}

		protected function _pageChange(cb : Function, listItems : Array, xCurrentTarget : Number, xComingInitial : int, xComingTarget : int) : void {
			var current : DisplayObject = _holder.numChildren == 0 ? null : _holder.getChildAt(0) ;

			var coming : Sprite = _pageCreate(listItems);
			coming.x = xComingInitial;
			_holder.addChildAt(coming, 0);

			if (current && _chunksPlaced.length > 0) {
				TweenLite.to(current, 0.5, {x:xCurrentTarget, onComplete:disposeChild, onCompleteParams:[current]});
				TweenLite.to(coming, 0.5, {x:xComingTarget});
				if (_pressedNext) TweenLite.delayedCall(0.75, cb, [listItems]);
				else TweenLite.delayedCall(1, cb, [listItems]);
			} else {
				disposeChild(current);
				coming.x = xComingTarget;
				cb.call(null, listItems);
			}
		}

		protected function _createNothingFoundInfo() : void {
			if ( !_tfNothingFound ) {
				_tfNothingFound = new Copy(getProperty("nothingfound"), 11, Colors.GREY);
				_tfNothingFound.alpha = 0;
				addChild(_tfNothingFound);
			}

			TweenLite.to(_tfNothingFound, .3, {alpha:1});
		}

		protected function _pageCreate(listItems : Array) : Sprite {
			var imageListHolder : SpriteComponent = new SpriteComponent();
			var numPlacedPhotos : int = 0;

			var photo : ButtonPolaroid;
			var currentWidth : int = 50;
			var currentLine : int = 0;
			var rot : int;

			_photos = [];
			enabled = false;

			var dao : UGCItemVO;
			for (var i : int = 0; i < listItems.length; i++) {
				if ( currentLine < _rows) {
					dao = new UGCItemVO(listItems[i]);
					
					photo = new ButtonPolaroid(new UGCImageItemVO(listItems[i]), PHOTO_W_H, PHOTO_W_H);
					photo.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
					photo.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
					photo.submitCallback = _onPhotoClicked;
					photo.submitCallbackParams = [dao];
					

					if (_pressedNext) {
						photo.x = _width + 150;
					} else {
						photo.x = -photo.width - 150;
					}
					photo.y = Math.random() * _height;
					if (i % 2) {
						rot = Math.random() * 20;
					} else {
						rot = -Math.random() * 20;
					}
					photo.filters = [new DropShadowFilter(2, 90, 0, 0.8, 10, 10)];
					photo.rot = rot;
					photo.name = i.toString();

					photo.xPos = currentWidth;
					photo.yPos = 20 + PHOTO_W_H * (currentLine);
					if ( _rows > 1 && currentWidth + PHOTO_W_H > _width - 80 && ++currentLine < _rows ) {
						currentWidth = 50;
					} else {
						currentWidth += PHOTO_SPACER;
					}

					_photos[i] = photo;
					
					TweenLite.to(photo, 0.5, {delay:i * 0.1, x:photo.xPos, y:photo.yPos, rotation:rot});
					// --- update currentWidth

					imageListHolder.addChild(photo);
					numPlacedPhotos++;
				} else {
					break;
				}
			}
			
			_chunksPlaced.push(numPlacedPhotos);
			return imageListHolder;
		}


		private function _onPhotoClicked(dao : UGCItemVO) : void {
			_submitCallback(dao);
		}

		private function _onMouseOver(event : MouseEvent) : void {
			var photo : ButtonPolaroid = ButtonPolaroid(event.target);
			var otherPhoto : ButtonPolaroid;
			var holder : DisplayObjectContainer = photo.parent;

			var intersectRect : Rectangle;
			var photoIndex : uint = holder.getChildIndex(photo);
			var dir : int;

			if (photoIndex != holder.numChildren - 1) {
				// Is not on top. Move other away
				// graphics.clear();
				for (var i : int = photoIndex + 1; i < holder.numChildren; i++) {
					otherPhoto = ButtonPolaroid(holder.getChildAt(i));
					intersectRect = photo.getRect(this).intersection(otherPhoto.getRect(this));
					if (intersectRect.width > 0) {
						// graphics.lineStyle(8,0xff0000);
						// graphics.drawRect(intersectRect.x, intersectRect.y, intersectRect.width, intersectRect.height);
						dir = otherPhoto.x > photo.x ? 1 : -1;
						TweenMax.to(otherPhoto, 0.3, {x:otherPhoto.xPos + dir * (intersectRect.width + 10), repeat:1, yoyo:true, overwrite:OverwriteManager.AUTO});
					}
				}
				TweenLite.to(photo, 0.3, {delay:0.2, rotation:0, scaleX:1.2, scaleY:1.2, dropShadowFilter:{distance:20, blurX:30, blurY:30}, onStart:function() : void {
					photo.parent.addChild(photo);
				}});
			} else {
				// Is on top. Do nothing.
				TweenLite.to(photo, 0.3, {rotation:0, scaleX:1.2, scaleY:1.2, dropShadowFilter:{distance:20, blurX:30, blurY:30}});
			}
		}

		private function _onMouseOut(event : MouseEvent) : void {
			var photo : ButtonPolaroid = ButtonPolaroid(event.target);
			TweenLite.to(photo, 0.3, {rotation:photo.rot, x:photo.xPos, y:photo.yPos, scaleX:1, scaleY:1, dropShadowFilter:{distance:2, blurX:10, blurY:10}});
		}
	}
}
