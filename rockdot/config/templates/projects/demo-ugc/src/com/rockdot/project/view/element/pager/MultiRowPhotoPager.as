package com.rockdot.project.view.element.pager {
	import com.greensock.TweenLite;
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

	import org.as3commons.lang.ClassUtils;

	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	/**
	 * @author nilsdoehring
	 */
	public class MultiRowPhotoPager extends ComponentPager {
		private static const DATA_PAGESIZE : Number = 30;
		protected static const WIDTH_BUTTON : Number = BootstrapConstants.HEIGHT_RASTER;
		
		protected var _imageListMask : Sprite;
		protected var _tfNothingFound : UITextField;
		private var _bg : Shape;

		public function MultiRowPhotoPager() {
			name = "element.pager.multi";
			
			super();
			_chunkSize = 30;
			
			// bg
			_bg = new Shape();
			addChildAt(_bg, 0);
			
			_imageListMask = new Sprite();
			addChild(_imageListMask);
			
			_holder.mask = _imageListMask;
			
			// gallery display
			var pagerProxy : DataProxy = new DataProxy();
			pagerProxy.dataRetrieveCommand = _context.getObject(UGCEvents.ITEMS_FILTER);
			pagerProxy.dataFilterVO = new UGCFilterVO(UGCFilterVO.CONDITION_ALL, UGCFilterVO.ORDER_DATE_DESC, DATA_PAGESIZE);
			
			listItemClass = ImageItemButton;
			listItemWidth = 90;
			listItemHeight = 90;
			listItemSpacer = 0;
			proxy = pagerProxy;
			
			_btnPrev = new PagerPrevNextButton(getProperty("button.prev"));
			_btnPrev.submitCallback = _onClickPrev;
			addChild(_btnPrev);
			
			_btnNext = new PagerPrevNextButton(getProperty("button.next"));
			_btnNext.submitCallback = _onClickNext;
			addChild(_btnNext);
		}
		
		
		override public function setSize(w : int, h : int) : void {
			super.setSize(w - 2*WIDTH_BUTTON, h);
		}
		
		override public function render() : void {
			rows = Math.floor(_height/ (_listItemHeight + _listItemSpacer));
			_chunkSize = _rows * 9;
			
			super.render();
			
			_imageListMask.graphics.clear();
			_imageListMask.graphics.beginFill(Colors.HIGHLIGHT, .3);
			_imageListMask.graphics.drawRect(_listItemSpacer, 0, _width-2*_listItemSpacer, (_listItemHeight + _listItemSpacer) * _rows);
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
			_bg.graphics.drawRect(WIDTH_BUTTON, 0, _imageListMask.width, _imageListMask.height);
			_bg.graphics.endFill();
			
			
			if(_loaded==true){
				if(_holder.numChildren > 0){
					
					disposeChild(_holder.getChildAt(0));
				}

				resetAndLoad();
			}
			
			
			_holder.x = WIDTH_BUTTON;
			_imageListMask.x = _holder.x;	
			
			_btnPrev.x = WIDTH_BUTTON;
			_btnPrev.y = 0;
			_btnPrev.setSize(WIDTH_BUTTON,  _rows * (_listItemHeight + _listItemSpacer));
			_btnPrev.scaleX = -1;

			_btnNext.x = WIDTH_BUTTON + _width;
			_btnNext.y = 0;
			_btnNext.setSize(WIDTH_BUTTON,  _rows * (_listItemHeight + _listItemSpacer));
			
			if(_tfNothingFound){
				_tfNothingFound.x = WIDTH_BUTTON + BootstrapConstants.SPACER;
			}
			
		}
		
		override public function setData(data : *) : void {
			if (_pressedNext == true) {
				_pageChange(super.setData, data, -_holder.width, _imageListMask.x+_imageListMask.width, 0);
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

			if (current && _chunksPlaced.length>0) {
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
			
			if( !_tfNothingFound ) {
				_tfNothingFound = new Copy(getProperty("nothingfound"), 11, Colors.GREY);
				_tfNothingFound.alpha = 0;
				addChild(_tfNothingFound);
			}
			
			TweenLite.to(_tfNothingFound, .3, {alpha:1});
		}

		
		protected function _pageCreate(listItems : Array) : Sprite {
			var imageListHolder : Sprite = new Sprite();
			
			var numPlacedPhotos : int = 0;
			var item : SpriteComponent;
			var currentWidth : int = 0;
			var currentLine : int = 0;

			// --- lineSprite: one sprite for each line - to center!
			var lineSprite : Sprite = new Sprite();
			lineSprite.name = "lineSprite" + currentLine;
			imageListHolder.addChild(lineSprite);

			var dao : UGCItemVO;
			for (var i : int = 0;i < listItems.length;i++) {
				if ( currentLine < _rows) {
					dao = new UGCItemVO(listItems[i]);

					item = ClassUtils.newInstance(ClassUtils.forInstance(_listItemClass), [(dao.type_dao as UGCImageItemVO).url_thumb, _listItemWidth, _listItemHeight]);
					item.submitCallback = _onItemClicked;
					item.submitCallbackParams = [dao];

					// --- new line
					if( _rows > 1 && currentWidth + _listItemWidth > _width - 2*_listItemSpacer && ++currentLine < _rows ) {
						item.x = 0;
						currentWidth = 0;

						lineSprite = new Sprite();
						lineSprite.name = "lineSprite" + currentLine;
						lineSprite.y = (_listItemHeight + _listItemSpacer) * currentLine;
						imageListHolder.addChild(lineSprite);
						// --- same line
					} else {
						item.x = currentWidth;
					}

					// --- update currentWidth
					currentWidth += _listItemWidth + _listItemSpacer;

					// --- display photo: big: don't show cutted image / small: show cutted image and mask
					if( _rows > 1 ) {
						if( currentWidth - _listItemSpacer < _width  ) {
							
							lineSprite.addChild(item);
							numPlacedPhotos++;
						}
						else{
							currentWidth -= _listItemWidth + _listItemSpacer;
						}

						lineSprite.x = int(_width/2 - (currentWidth)/2);
						 
					} else {
						lineSprite.addChild(item);
						if( currentWidth - _listItemSpacer < _width  ) {
							numPlacedPhotos++;
						}
						else{
							break;
						}
					}

				} else {
					break;
				}
			}
			
				
			if(numPlacedPhotos == 0){
				_createNothingFoundInfo();
			}

			_chunksPlaced.push(numPlacedPhotos);
			return imageListHolder;
		}
		
		private function _onItemClicked(vo : UGCItemVO) : void {
			if(disableClick == false){
				_submitCallback(vo);
			}
		}
		
	}
}
