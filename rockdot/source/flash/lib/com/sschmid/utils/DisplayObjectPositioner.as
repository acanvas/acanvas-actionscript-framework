package com.sschmid.utils {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class DisplayObjectPositioner {
		private var _stage : Stage;
		private var _target : DisplayObject;
		private var _previewTarget : DisplayObject;
		private var _offsetX : Number = 0;
		private var _offsetY : Number = 0;
		private var _selectedRect : Shape;
		private var _previewRect : Shape;

		public function DisplayObjectPositioner(stage : Stage) {
			_stage = stage;
			_selectedRect = new Shape();
			_previewRect = new Shape();
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, _enable);
		}


		private function _onStageMouseDown(event : MouseEvent) : void {
			if (event.target is Stage) return;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
			_target = DisplayObject(event.target);
			_offsetX = _stage.mouseX - _target.x;
			_offsetY = _stage.mouseY - _target.y;
			_updateRect();
			_stage.addChild(_selectedRect);
		}


		private function _onMouseOver(event : MouseEvent) : void {
			if (event.target is Stage) return;
			_previewTarget = DisplayObject(event.target);
			_updatePreviewRect();
			_stage.addChild(_previewRect);
		}


		private function _onStageMouseMove(event : MouseEvent) : void {
			_target.x = _stage.mouseX - _offsetX;
			_target.y = _stage.mouseY - _offsetY;
			_updateRect();
		}


		private function _updateRect() : void {
			if (_target.parent) {
				var rect : Rectangle = _target.getBounds(_stage);
				var g : Graphics = _selectedRect.graphics;
				g.clear();
				g.beginFill(0xFF0000);
				g.drawRect(rect.x, rect.y, rect.width, rect.height);
				g.drawRect(rect.x + 1, rect.y + 1, rect.width - 2, rect.height - 2);
				g.beginFill(0x00FF00, 0.3);
				g.drawRect(rect.x + 1, rect.y + 1, rect.width - 2, rect.height - 2);
				g.endFill();
				trace(_target.name + "   x: " + _target.x + "   y: " + _target.y + "   scaleX: " + _target.scaleX + "   scaleY: " + _target.scaleY + "   rotation: " + _target.rotation + "   width: " + _target.width + "   height: " + _target.height);
			} else {
				_selectedRect.parent.removeChild(_selectedRect);
				_target = null;
			}
		}


		private function _updatePreviewRect() : void {
			var rect : Rectangle = _previewTarget.getBounds(_stage);
			var g : Graphics = _previewRect.graphics;
			g.clear();
			g.beginFill(0xFF0000);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
			g.drawRect(rect.x + 1, rect.y + 1, rect.width - 2, rect.height - 2);
			g.beginFill(0x0000FF, 0.3);
			g.drawRect(rect.x + 1, rect.y + 1, rect.width - 2, rect.height - 2);
			g.endFill();
		}


		private function _onStageMouseUp(event : MouseEvent) : void {
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
		}


		private function _onStageKeyDown(event : KeyboardEvent) : void {
			if (_target) {
				var step : Number = event.shiftKey ? 10 : 1;

				switch(event.keyCode) {
					case Keyboard.UP:
						if (event.altKey) {
							_target.scaleX *= 1.1;
							_target.scaleY *= 1.1;
						} else {
							_target.y -= step;
						}
						break;
					case Keyboard.DOWN:
						if (event.altKey) {
							_target.scaleX *= 0.9;
							_target.scaleY *= 0.9;
						} else {
							_target.y += step;
						}
						break;
					case Keyboard.LEFT:
						if (event.altKey) _target.rotation--;
						else _target.x -= step;
						break;
					case Keyboard.RIGHT:
						if (event.altKey) _target.rotation++;
						else _target.x += step;
						break;
					case Keyboard.DELETE:
						if (_target.parent) _target.parent.removeChild(_target);
						break;
					case Keyboard.ESCAPE:
						_stage.removeEventListener(MouseEvent.MOUSE_DOWN, _onStageMouseDown);
						_stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onStageKeyDown);
						_stage.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
						_target = null;
						_previewTarget = null;
						_stage.addEventListener(KeyboardEvent.KEY_DOWN, _enable);
						if (_selectedRect.parent) _stage.removeChild(_selectedRect);
						if (_previewRect.parent) _stage.removeChild(_previewRect);
						return;
					default:
				}
				_updateRect();
			}
		}


		private function _enable(event : KeyboardEvent) : void {
			if (event.shiftKey && event.altKey && event.ctrlKey) {
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, _enable);
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, _onStageMouseDown);
				_stage.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, _onStageKeyDown);
			}
		}
	}
}
