package com.rockdot.plugin.screen.feathers.service {
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;

	import feathers.system.DeviceCapabilities;

	import starling.core.Starling;

	import com.rockdot.plugin.screen.common.service.AbstractScreenService;
	import com.rockdot.plugin.screen.displaylist3d.service.IScreen3DService;
	import com.rockdot.plugin.screen.feathers.view.FeatherNavigatorScreen;

	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * @author nilsdoehring
	 */
	public class ScreenFeathersService extends AbstractScreenService  implements IScreen3DService{
		private var _starling : Starling;
		private var _stage3DProxy : Stage3DProxy;
		private var _callback : Function;

		public function get stage3DProxy() : Stage3DProxy {
			return _stage3DProxy;
		}

		public function ScreenFeathersService() {
			super();
		}

		override public function init(callback : Function = null) : void {
			// DON'T CALL SUPER!

			_callback = callback;
			DeviceCapabilities.dpi = 326;
			DeviceCapabilities.screenPixelWidth = stage.stageWidth;
			DeviceCapabilities.screenPixelHeight = stage.stageHeight;
			
			_onContextCreated();
		}

		protected function _onContextCreated(event : Stage3DEvent=null) : void {
			
			
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;

			_starling = new Starling(FeatherNavigatorScreen, stage);
			_starling.enableErrorChecking = true;
			_starling.start();
			resize();
			
			stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
			stage.addEventListener(Event.RESIZE, resize);
			_initialized = true;

			if (_callback != null) {
				_callback.call();
			}

		}

		private function stage_deactivateHandler(event : Event) : void {
			this._starling.stop();
			this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
		}

		private function stage_activateHandler(event : Event) : void {
			this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
			this._starling.start();
		}

		override public function resize(event : Event = null) : void {
			// DON'T CALL SUPER!

			this._starling.stage.stageWidth = this.stage.stageWidth;
			this._starling.stage.stageHeight = this.stage.stageHeight;

			const viewPort : Rectangle = _starling.viewPort;
			viewPort.width = this.stage.stageWidth;
			viewPort.height = this.stage.stageHeight;
			try {
				this._starling.viewPort = viewPort;
			} catch(error : Error) {
			}

//			new RockdotEvent(UIEvents.RESIZE).dispatch();
		}
	}
}
