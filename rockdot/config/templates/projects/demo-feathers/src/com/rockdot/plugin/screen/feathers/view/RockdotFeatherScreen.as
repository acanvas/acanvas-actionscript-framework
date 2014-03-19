package com.rockdot.plugin.screen.feathers.view {
	import away3d.core.managers.Stage3DProxy;

	import feathers.controls.Screen;

	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.plugin.screen.displaylist3d.view.IRockdotManagedSpriteComponent3D;





	/**
	 * @author nilsdoehring
	 */
	public class RockdotFeatherScreen extends Screen implements IRockdotManagedSpriteComponent3D {
		protected var _stageProxy : Stage3DProxy;

		public function RockdotFeatherScreen() {
			super();
			RockdotHelper.wire(this);

		}

		public function set stageProxy(stageProxy : Stage3DProxy) : void {
			_stageProxy = stageProxy;
		}

	}
}
