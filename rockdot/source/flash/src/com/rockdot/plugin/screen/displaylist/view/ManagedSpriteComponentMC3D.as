package com.rockdot.plugin.screen.displaylist.view {
	import com.danielfreeman.stage3Dacceleration.Stage3DAcceleration;

	import flash.events.Event;

	/**
	 * @author nilsdoehring
	 */
	public class ManagedSpriteComponentMC3D extends RockdotManagedSpriteComponent {

		public function ManagedSpriteComponentMC3D(id : String) {
			super(id);
		}
		
		override protected function _didInit() : void {
			addEventListener(Stage3DAcceleration.CONTEXT_COMPLETE, _onContextCreated);
			Stage3DAcceleration.startStage3D(this);
			super._didInit();
		}

		protected function _onContextCreated(event : Event) : void {
		}

		protected function _pageFlippingFinished(event:Event):void {
		}
		
		override public function destroy() : void {
			//DON'T CALL SUPER!
		}
		
		
	}
}
