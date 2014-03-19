package com.rockdot.plugin.screen.displaylist3d.service {
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;

	import starling.core.Starling;

	import com.rockdot.plugin.screen.displaylist.service.ScreenDisplaylistService;





	/**
	 * @author nilsdoehring
	 */
	public class ScreenDisplaylist3DService extends ScreenDisplaylistService implements IScreen3DService {
		private var _stage3DManager : Stage3DManager;
		private var _callback : Function;
		
		public function get stage3DProxy() : Stage3DProxy {
			return _stage3DManager.getFreeStage3DProxy();
		}

		public function ScreenDisplaylist3DService() {
			super();
		}
		
		
		override public function init(callback : Function = null) : void {
			
			super.init(callback);
			
			// Define a new Stage3DManager for the Stage3D objects
			_stage3DManager = Stage3DManager.getInstance(stage);

			_initialized = true;
			
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;

			
			if(_callback != null){
				_callback.call();
			}
			
			
		}

		
		
	}
}
