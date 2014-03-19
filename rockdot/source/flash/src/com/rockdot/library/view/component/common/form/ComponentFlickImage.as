package com.rockdot.library.view.component.common.form {
	import com.greensock.TweenLite;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;



	/**
	 * @author nilsdoehring
	 */
	public class ComponentFlickImage extends SpriteComponent {
		private static const LEFT : String = "LEFT";
		private static const MIDDLE : String = "MIDDLE";
		private static const RIGHT : String = "RIGHT";
		
		private var _holder : Sprite;
		private var _mask : Shape;
		private var _data : Array;
		private var _currentIndex : int = 0;
		private var _tweening : Boolean = false;
		private var _flickTimer : Timer;

		public function ComponentFlickImage(data : Array, flickInterval : int = 0) {
			_data = data;
			super();
			
			_holder = new Sprite();
			addChild(_holder);

			var bmp : DisplayObject = _data[_currentIndex];

			_mask = new Shape();
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000);
			_mask.graphics.drawRect(0, 0, bmp.width, bmp.height+50);
			addChild(_mask);
			
			_holder.mask = _mask;
			
			_placeItem(bmp, MIDDLE);
			
			if(flickInterval > 0){
				_flickTimer = new Timer(flickInterval);
				_flickTimer.addEventListener(TimerEvent.TIMER, next);
				_flickTimer.start();
			}
		}

		private function _placeItem(data : DisplayObject, position : String) : void {
			var child : DisplayObject;
			switch(position){
				case LEFT :
					child = _holder.getChildAt(0);
					data.x = int(child.x - data.width);
					_holder.addChildAt(data, 0);
					TweenLite.to(data, 1, {x : 0});
					TweenLite.to(child, 1, {x : int(child.width), onComplete: _onTweenComplete, onCompleteParams: [child]});
					_tweening = true;
				break;
				case MIDDLE :
					_holder.addChildAt(data, 0);
				break;
				case RIGHT :
					child = _holder.getChildAt(0);
					data.x = int(child.x + child.width);
					_holder.addChildAt(data, 0);
					TweenLite.to(data, 1, {x : 0});
					TweenLite.to(child, 1, {x : - int(child.width), onComplete: _onTweenComplete, onCompleteParams: [child]});
					_tweening = true;
				break;
			}
		}

		private function _onTweenComplete(child : DisplayObject) : void {
			_holder.removeChild(child);
			_tweening = false;
		}


		public function next(ev : Event = null) : void {
			if(_tweening == true){
				return;
			}
			
			if(++_currentIndex == _data.length){
				_currentIndex = 0;
			}
			
			_placeItem(_data[_currentIndex], RIGHT);
		}


		public function prev() : void {
			if(_tweening == true){
				return;
			}
			if(--_currentIndex == -1){
				_currentIndex = _data.length - 1;
			}
			
			_placeItem(_data[_currentIndex], LEFT);
		}
		
		
		public function gotoPage(page : int) : void {
			if(page == _currentIndex){
				return;
			}
			
			if(page < 0 || page > _data.length){
				page = 0;
			}
			
			_currentIndex = page;
			_placeItem(_data[_currentIndex], LEFT);
		}
		

		override public function setSize(w : int, h : int) : void {
			super.setSize(w, h);

//			for each(var bmp :Bitmap in _data){
//				bmp.width = _width;
//				bmp.height = _height;
//			}
//
//			_holder.width = _width;
//			_holder.height = _height;
			
//			_holder.x = int(_width/2 - _holder.width/2);
//			_holder.y = int(_height/2 - _holder.height/2);
//			
//			_mask.x = _holder.x;
//			_mask.y = _holder.y;
			
		}
		
		override public function render() : void {
			super.render();
			
			
		}

		public function get tweening() : Boolean {
			return _tweening;
		}

		

		
	}
}
