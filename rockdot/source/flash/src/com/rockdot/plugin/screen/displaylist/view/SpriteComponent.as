package com.rockdot.plugin.screen.displaylist.view {
	import com.rockdot.core.mvc.RockdotEvent;

	import org.as3commons.lang.ClassUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class SpriteComponent extends Sprite implements ISpriteComponent {
		protected var _width : int;
		protected var _height : int;
		protected var _enabled : Boolean;
		//
		protected var _ignoreSetEnabled : Boolean;
		protected var _ignoreSetTouchEnabled : Boolean;
		protected var _ignoreCallDestroy : Boolean;
		protected var _ignoreCallSetSize : Boolean;
		protected var _log : ILogger = getLogger(ClassUtils.forInstance(this));
		/*
		 * COMMIT VARIABLE SETTERS
		 */
		protected var _submitEvent : RockdotEvent;

		public function set submitEvent(submitEvent : RockdotEvent) : void {
			_submitEvent = submitEvent;
		}

		protected var _submitCallback : Function;

		public function set submitCallback(submitCallback : Function) : void {
			_submitCallback = submitCallback;
		}

		protected var _submitCallbackParams : Array;

		public function set submitCallbackParams(submitCallbackParams : Array) : void {
			_submitCallbackParams = submitCallbackParams;
		}

		public function SpriteComponent() : void {
			_ignoreCallSetSize = true;
		}

		override public function addChild(child : DisplayObject) : DisplayObject {
			var ret : DisplayObject = super.addChild(child);
			if (ret is ISpriteComponent) {
				if (!ISpriteComponent(ret).ignoreSetEnabled && this.enabled) {
					ISpriteComponent(ret).enabled = true;
				}
			}
			return ret;
		}

		public function get enabled() : Boolean {
			return _enabled;
		}

		public function set enabled(value : Boolean) : void {
			_enabled = mouseEnabled = mouseChildren = tabEnabled = value;
			var child : DisplayObject;
			for (var i : int = 0; i < numChildren; i++) {
				child = getChildAt(i);
				if (child is ISpriteComponent && !ISpriteComponent(child).ignoreSetEnabled) ISpriteComponent(child).enabled = _enabled;
			}
		}

		public function getWidth() : int {
			return _width;
		}

		public function setWidth(w : int) : void {
			setSize(w, _height);
		}

		public function getHeight() : int {
			return _height;
		}

		public function setHeight(h : int) : void {
			setSize(_width, h);
		}

		public function setSize(w : int, h : int) : void {
			if (w != _width || h != _height) {
				if (w > 0) _width = w;
				if (h > 0) _height = h;
				if (!(this is IManagedSpriteComponent) || (this is IManagedSpriteComponent && (this as IManagedSpriteComponent).isInitialized)) {
					// if IView, only render if already initialized
					render();
				}
				var child : DisplayObject;
				for (var i : int = 0; i < numChildren; i++) {
					child = getChildAt(i);
					if (child is ISpriteComponent && !ISpriteComponent(child).ignoreCallSetSize){
						 ISpriteComponent(child).setSize(w, h);
					}
					// if (child is TextField) TextField(child).width = w - 10;
				}
			}
		}

		public function render() : void {
			// Override this method, if you want to respond to setSize
		}

		/**
		 * @return BitmapData of this Component
		 */
		public function getAsBitmapData(rect : Rectangle = null, transparent : Boolean = true, fillColor : uint = 0x00FFFFFF) : BitmapData {
			rect ||= new Rectangle(0, 0, _width, _height);
			var bmd : BitmapData = new BitmapData(rect.width, rect.height, transparent, fillColor);
			bmd.lock();
			bmd.draw(this, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
			bmd.unlock();
			return bmd;
		}

		public function destroy() : void {
			while (numChildren > 0) {
				disposeChild(getChildAt(numChildren - 1));
			}
			disposeChild(this);
		}

		protected function disposeChild(dobj : DisplayObject = null) : void {
			if (dobj) {
				if (dobj is ISpriteComponent && !ISpriteComponent(dobj).ignoreCallDestroy && dobj != this) {
					ISpriteComponent(dobj).destroy();
					dobj = null;
					return;
				}
				if ( dobj.parent) {
					dobj.parent.removeChild(dobj);
				}
				if (dobj is Bitmap) {
					(dobj as Bitmap).bitmapData.dispose();
				}
				if (dobj is BitmapData) {
					(dobj as BitmapData).dispose();
				}
				if (dobj is Shape) {
					(dobj as Shape).graphics.clear();
				}
				if (dobj is Sprite) {
					(dobj as Sprite).graphics.clear();
				}
				dobj = null;
			}
		}

		/**
		 * 
		 * Ignore
		 * 
		 */
		public function get ignoreSetEnabled() : Boolean {
			return _ignoreSetEnabled;
		}

		public function set ignoreSetEnabled(value : Boolean) : void {
			_ignoreSetEnabled = value;
		}

		public function get ignoreSetTouchEnabled() : Boolean {
			return _ignoreSetTouchEnabled;
		}

		public function set ignoreSetTouchEnabled(value : Boolean) : void {
			_ignoreSetTouchEnabled = value;
		}

		public function get ignoreCallDestroy() : Boolean {
			return _ignoreCallDestroy;
		}

		public function set ignoreCallDestroy(value : Boolean) : void {
			_ignoreCallDestroy = value;
		}

		public function get ignoreCallSetSize() : Boolean {
			return _ignoreCallSetSize;
		}

		public function set ignoreCallSetSize(value : Boolean) : void {
			_ignoreCallSetSize = value;
		}

		protected function _getBitmap(swc : Class) : DisplayObject {
			return new Bitmap(new swc(), PixelSnapping.ALWAYS, true);
		}

		public function appear(duration : Number = 0.5) : void {
			var child : DisplayObject;
			for (var i : int = 0; i < numChildren; i++) {
				child = getChildAt(i);
				if (child is ISpriteComponent) ISpriteComponent(child).appear(duration);
			}
		}

		public function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void {
			var child : DisplayObject;
			for (var i : int = 0; i < numChildren; i++) {
				child = getChildAt(i);
				if (child is ISpriteComponent) ISpriteComponent(child).disappear(duration, autoDestroy);
			}
		}
	}
}
