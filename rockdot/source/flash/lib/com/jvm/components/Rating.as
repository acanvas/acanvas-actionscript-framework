package com.jvm.components {
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;


	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class Rating extends SpriteComponent {
		public var previewAlpha : Number = 0.6;
		protected var _selected : Sprite;
		protected var _deselected : Sprite;
		protected var _numItmes : uint;
		protected var _rating : uint;
		protected var _id : uint;

		public function Rating(numsItmes : uint, selectedBmd : BitmapData, deselectedBmd : BitmapData, padding : int = 0) {
			_numItmes = numsItmes;
			
			// Holds all selectedBmd instances
			_selected = new Sprite();
			_selected.mouseEnabled = false;
			addChild(_selected);
			
			// Holds all deselectedBmd instances
			_deselected = new Sprite();
			addChild(_deselected);
			
			_arrange(padding, selectedBmd, deselectedBmd);
			
			// Draw invisible bg for hitArea
			var g : Graphics = graphics;
			g.beginFill(0, 0);
			g.drawRect(0, 0, width, height);
			g.endFill();
			addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
		}

		
		protected function _arrange(padding : int, selectedBmd : BitmapData, deselectedBmd : BitmapData) : void {
			var gridWidth : uint = selectedBmd.width + padding;
			var item : Sprite;
			for (var i : int = 0;i < _numItmes;i++) {
				item = new Sprite();
				item.addChild(new Bitmap(deselectedBmd));
				item.x = i * gridWidth;
				_deselected.addChild(item);
				item.addEventListener(MouseEvent.ROLL_OVER, _onItemRollOver);
				item.addEventListener(MouseEvent.MOUSE_UP, _onItemMouseUp);
				
				item = new Sprite();
				item.addChild(new Bitmap(selectedBmd));
				item.x = i * gridWidth;
				item.alpha = 0;
				_selected.addChild(item);
			}
		}

		
		override public function destroy() : void {
			super.destroy();
			var item : DisplayObject;
			for (var i : int = 0;i < _numItmes;i++) {
				item = _deselected.getChildAt(i);
				item.removeEventListener(MouseEvent.ROLL_OVER, _onItemRollOver);
				item.removeEventListener(MouseEvent.MOUSE_UP, _onItemMouseUp);
			}
		}

		
		protected function _onItemMouseUp(event : MouseEvent) : void {
			rate(_deselected.getChildIndex(DisplayObject(event.target)) + 1);
		}

		
		protected function _onItemRollOver(event : MouseEvent) : void {
			showRating(_deselected.getChildIndex(DisplayObject(event.target)) + 1, true);
		}

		
		private function _onRollOut(event : MouseEvent) : void {
			showRating(_rating);
		}

		
		public function showRating(value : uint, preview : Boolean = false) : void {
			var r : uint;
			
			if (value < 0) r = 0;
			else if (value > _numItmes) r = _numItmes;
			else r = value;
			
			var prevAlpha : Number = previewAlpha;
			if (preview == false) {
				_rating = r;
				prevAlpha = 1;
			}
			
			for (var i : int = 0;i < _numItmes;i++) {
				if (i < r) {
					_deselected.getChildAt(i).alpha = 0;
					_selected.getChildAt(i).alpha = prevAlpha;
				} else {
					_deselected.getChildAt(i).alpha = 1;
					_selected.getChildAt(i).alpha = 0;
				}
			}
		}

		
		public function rate(value : uint) : void {
			showRating(value);
		}

		
		public function set id(value : uint) : void {
			_id = value;
		}

		
		public function get rating() : uint {
			return _rating;
		}
	}
}
