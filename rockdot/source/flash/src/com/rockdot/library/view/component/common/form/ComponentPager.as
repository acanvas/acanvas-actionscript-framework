package com.rockdot.library.view.component.common.form {
	import com.rockdot.library.view.component.common.ComponentWithDataProxy;
	import com.rockdot.library.view.component.common.form.button.Button;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Sprite;
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;


	/**
	 * @author nilsdoehring
	 */
	public class ComponentPager extends ComponentWithDataProxy {
		
		protected var _holder : Sprite;

		protected var _chunksPlaced : Array = [];
		protected var _chunkSize : int = 8;

		private var _hasPrev : int;
		private var _hasNext : Boolean;
		protected var _loaded : Boolean;
		
		protected var _btnPrev : Button;
		protected var _btnNext : Button;
		protected var _pressedNext : Boolean;

		protected var disableClick : Boolean;
		
		
		protected var _listItemClass : Class;
		public function set listItemClass(listItemClass : Class) : void {
			_listItemClass = listItemClass;
		}

		protected var _listItemWidth : int;
		public function set listItemWidth(listItemWidth : int) : void {
			_listItemWidth = listItemWidth;
		}

		protected var _listItemHeight : int;
		public function set listItemHeight(listItemHeight : int) : void {
			_listItemHeight = listItemHeight;
		}

		protected var _listItemSpacer : int;
		public function set listItemSpacer(listItemSpacer : int) : void {
			_listItemSpacer = listItemSpacer;
		}


		protected var _rows : int = 1;
		public function set rows(rows : int) : void {
			if(rows==0)rows++;
			_rows = rows;
		}

		public function ComponentPager() {
			super();

			disableClick = false;
			
			_holder = new SpriteComponent();
			addChild(_holder);
		}
		
		override public function render() : void {
			super.render();

			
			_updateControls();
		}
		
		
		override public function set enabled( value : Boolean ) : void {
			if(value == true){
				_registerGestures();
			}
			else {
				_unregisterGestures();
			}
			
			super.enabled = value;
		}
		
		public function setData(data : *) : void {
			disableClick = false;
			this.data = data;
		}

		private function _registerGestures() : void {
			if(!Multitouch.supportsGestureEvents || !_holder) {
				return;
			}
			
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			_holder.addEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe); 
		}

		private function _unregisterGestures() : void {
			if(!Multitouch.supportsGestureEvents || !_holder) {
				return;
			}
			
//			Multitouch.inputMode = null;
			_holder.removeEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe); 
		}
		

		protected function onSwipe(e : TransformGestureEvent) : void {
			if (e.offsetX == 1) { 
//				User swiped towards right
				_onClickPrev();
			}
			if (e.offsetX == -1) { 
//				User swiped towards left
				_onClickNext();
			} 
		}

		public function setFilterVOAndLoad(vo : Object) : void {
			_proxy.dataFilterVO = vo;
			resetAndLoad();
		}

		public function resetAndLoad() : void {
			_loaded = false;
			_chunksPlaced = [];
			_proxy.reset();
			_proxy.requestChunk(setData, _getChunkIndex(_chunksPlaced), _chunkSize);
		}

		protected function _onClickNext() : void {
			if(!_hasNext) {
				return;
			}
			
			disableClick = true;
			_pressedNext = true;
//			uiService.lock();
			
			_btnPrev.enabled = false;
			_btnNext.enabled = false;
			
			_proxy.requestChunk(setData, _getChunkIndex(_chunksPlaced), _chunkSize);
		}

		protected function _onClickPrev() : void {
			if(!_hasPrev) {
				return;
			}

			disableClick = true;
			_pressedNext = false;
//			uiService.lock();
			
			//yes, 2times
			_chunksPlaced.pop();
			_chunksPlaced.pop();
			
			_btnPrev.enabled = true;
			_btnNext.enabled = true;
			_proxy.requestChunk(setData, _getChunkIndex(_chunksPlaced), _chunkSize);
		}

		private function _updateControls() : void {
			var chunks : Array = _chunksPlaced.concat();
			//yes, calling pop twice is correct
			chunks.pop();
			var checkNum : * = chunks.pop();
			_hasPrev = 0;
			
			if(checkNum is int) {
				_hasPrev = _proxy.hasChunk(_getChunkIndex(chunks), _chunkSize);
			}
			_hasNext = _proxy.hasChunk(_getChunkIndex(_chunksPlaced), _chunkSize) > 0;
				
			if(_hasPrev > 0) {
				_btnPrev.enabled = true;			} else {				_btnPrev.enabled = false;			}			if(_hasNext) {
				_btnNext.enabled = true;			}			else {
				_btnNext.enabled = false;
			}
			
//			uiService.unlock();
		}

		protected function _getChunkIndex(chunks : Array) : int {
			var idx : int = 0;
			for each(var num:int in chunks) {
				idx += num;
			}
			return idx;
		}

		

		
		
	}
}
