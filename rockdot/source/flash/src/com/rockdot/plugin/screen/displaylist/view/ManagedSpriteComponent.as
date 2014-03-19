package com.rockdot.plugin.screen.displaylist.view {
	import com.rockdot.plugin.screen.common.view.IScreen;

	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 * 
	 * Subclass View to create ViewComponents with a lifecycle.
	 * View does provide a Logger.
	 */
	public class ManagedSpriteComponent extends SpriteComponent implements IScreen, IManagedSpriteComponent {
		protected var _data : *;
		protected var _isInitialized : Boolean;
		protected var _isLoaded : Boolean;
		protected var _isAppeared : Boolean;
		protected var _isDisappeared : Boolean;
		protected var _isDestroyed : Boolean;

		public function ManagedSpriteComponent(name : String = "") {
			var className : String = getQualifiedClassName(this);
			this.name = name == "" ? className : name;
			super();

			_log.debug("create");
		}

		override public function addChild(child : DisplayObject) : DisplayObject {
			if (child is IManagedSpriteComponent) {
				if (this.isInitialized) {
					IManagedSpriteComponent(child).init(_data);
				}
			}
			return super.addChild(child);
		}

		public function init(data : * = null) : void {
			_log.debug("init");
			_data = data;
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.INIT_START));
		}

		protected function _didInit() : void {
			_isInitialized = true;
			_isDestroyed = false;
			render();
			_log.debug("did init");
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.INIT_COMPLETE));
		}
		
		public function setData(data : *) : void {
			_data = data;
		}

		public function load(data : * = null) : void {
			_log.debug("load");
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.LOAD_START));
		}

		protected function _didLoad() : void {
			_isLoaded = true;
			_log.debug("did load");
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.LOAD_COMPLETE));
		}

		protected function _onLoadError(errorMessage : String = null) : void {
			_isLoaded = false;
			_log.debug("onLoadError. " + errorMessage);
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.LOAD_ERROR, errorMessage));
		}

		override public function appear(duration : Number = 0.5) : void {
			_log.debug("appear: " + duration + " seconds");
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.APPEAR_START));
		}

		protected function _onAppear() : void {
			_isAppeared = true;
			_isDisappeared = false;
			_log.debug("did appear");
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.APPEAR_COMPLETE));
		}

		override public function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void {
			_log.debug("disappear: " + duration + " seconds. Autodestroy: " + autoDestroy);
			if (autoDestroy) addEventListener(ManagedSpriteComponentEvent.DISAPPEAR_COMPLETE, _autoDestroy, false, 0, true);
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.DISAPPEAR_START));
		}

		protected function _onDisappear() : void {
			_isDisappeared = true;
			_isAppeared = false;
			_log.debug("did disappear");
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.DISAPPEAR_COMPLETE));
		}

		override public function destroy() : void {
			_log.debug("destroy");
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.DESTROY_START));
			// Will destroy all IComponent children
			super.destroy();
		}

		protected function _autoDestroy(event : ManagedSpriteComponentEvent) : void {
			destroy();
		}

		protected function _didDestroy() : void {
			if (parent) parent.removeChild(this);
			_isDestroyed = true;
			_isInitialized = false;
			// removeEventListener(ViewEvent.DID_DISAPPEAR, destroy);
			_log.debug("did destroy");
			dispatchEvent(new ManagedSpriteComponentEvent(ManagedSpriteComponentEvent.DESTROY_COMPLETE));
		}

		public function get isInitialized() : Boolean {
			return _isInitialized;
		}

		public function get isLoaded() : Boolean {
			return _isLoaded;
		}

		public function get isAppeared() : Boolean {
			return _isAppeared;
		}

		public function get isDisappeared() : Boolean {
			return _isDisappeared;
		}

		public function get isDestroyed() : Boolean {
			return _isDestroyed;
		}
	}
}
