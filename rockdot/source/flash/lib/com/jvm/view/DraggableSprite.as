package com.jvm.view {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 24.11.2011 14:08:25
	 * 
	 * DraggableSprite is a Sprite that has the ability to interact with the Mouse in drag and drop scenarios.
	 * 
	 */
	public class DraggableSprite extends Sprite {
		
		private var _xOffset : Number = 0;
		private var _yOffset : Number = 0;
		
		// Area where dragging is allowed
		private var _bounds : Rectangle;
		
		public function DraggableSprite() {
		}
		
		/**
		 * Starts a dragging operation, forcing the player to redraw the Sprite after every mouse move. 
		 * Cancel the drag() operation by calling the drop() method.
		 */
		public function drag(lockCenter : Boolean = false, rectangle : Rectangle = null) : void {
			var pt : Point;
			if(!lockCenter) pt = localToGlobal(new Point(mouseX, mouseY));
				else pt = localToGlobal(new Point(0, 0));
				
			_xOffset = pt.x - x;
			_yOffset = pt.y - y;
			
			_bounds = rectangle;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp, false, 0, true);
		}


		private function _onMouseMove(event : MouseEvent) : void {
			x = event.stageX - _xOffset;
			y = event.stageY - _yOffset;
			
			if (_bounds != null) {
				if (x < _bounds.left) {
					x = _bounds.left;
				} else if(x > _bounds.right) {
					x = _bounds.right;
				}
				if (y < _bounds.top) {
					y = _bounds.top;	
				} else if (y > _bounds.bottom) {
					y = _bounds.bottom;	
				}
			}
			
			event.updateAfterEvent();
		}

		private function _onMouseUp(event : MouseEvent) : void {
			drop();
		}
		
		/**
		 * Stops a dragging operation
		 */
		public function drop() : void {
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, _onMouseUp );
		}
	}
}
