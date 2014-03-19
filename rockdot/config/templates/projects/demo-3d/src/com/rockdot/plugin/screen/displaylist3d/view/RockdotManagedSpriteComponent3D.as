package com.rockdot.plugin.screen.displaylist3d.view {
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;

	import com.rockdot.plugin.screen.displaylist.view.RockdotManagedSpriteComponent;

	import flash.events.Event;

	/**
	 * @author nilsdoehring
	 */
	public class RockdotManagedSpriteComponent3D extends RockdotManagedSpriteComponent implements IRockdotManagedSpriteComponent3D {
		protected var _stageProxy : Stage3DProxy;

		public function RockdotManagedSpriteComponent3D(id : String) {
			super(id);
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);
			
			_stageProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, _onContextCreated);
			_stageProxy.antiAlias = 8;
			_stageProxy.color = 0x0;
		}

		protected function _onContextCreated(event : Stage3DEvent) : void {
			_stageProxy.removeEventListener(Stage3DEvent.CONTEXT3D_CREATED, _onContextCreated);
		}
		
		protected function _initListeners() : void {
			_stageProxy.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}

		protected function _onEnterFrame(event : Event) : void {
		}

		protected function _removeListeners() : void {
			_stageProxy.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		public function set stageProxy(stageProxy : Stage3DProxy) : void {
			_stageProxy = stageProxy;
		}
	}
}
