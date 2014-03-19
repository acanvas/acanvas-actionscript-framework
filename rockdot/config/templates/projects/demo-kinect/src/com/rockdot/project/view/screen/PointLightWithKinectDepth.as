package com.rockdot.project.view.screen {
	import com.rockdot.library.view.util.KeyinputManager;
	import com.rockdot.project.view.element.RockdotBlobTracker;
	import com.rockdot.project.view.element.pointlight.PointLightDemo;

	import flash.display.StageDisplayState;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;


	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class PointLightWithKinectDepth extends AbstractScreen {
		private var _pl : PointLightDemo;
		private var _blobTracker : RockdotBlobTracker;
		private var _keyboardInput : KeyinputManager;
		
		public function PointLightWithKinectDepth(id : String)
		{
				super(id);
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);

			/* Initialize stuff here. You can use _width and _height. */
			_pl = new PointLightDemo();
			_pl.setSize(_width, _height);
			_pl.ignoreCallSetSize = false;
			addChild(_pl);
			
			var showTracker : Boolean = true;
			_blobTracker = new RockdotBlobTracker( showTracker );
			_blobTracker.updateCallback = _onUpdate;
			addChild(_blobTracker);

			_blobTracker.trackColor(new Point(_blobTracker.width/2, _blobTracker.height/2), 0x0000FF);
			
			//register keyboard shortcuts
			_keyboardInput = new KeyinputManager();
			_keyboardInput.init(stage);
			_keyboardInput.registerKeyCodes([Keyboard.R, Keyboard.S, Keyboard.F]);
			_keyboardInput.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyboard);
			_keyboardInput.start();
			
			_didInit();
		}
		
		private function _onKeyboard(event : KeyboardEvent) : void {
			switch(event.keyCode){
				case Keyboard.F:
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				break;
				case Keyboard.S:
					//toggle renderer and settings display
					_blobTracker.visible = !_blobTracker.visible;
				break;
			}
		}

		private function _onUpdate(x: int, y:int) : void {
//			_log.debug("onUpdate: x {0}, y {1}", [x, y]);

			var nx : Number = x / _blobTracker.width * _pl.grid.width;
			var ny : Number = y / _blobTracker.height * _pl.grid.height;
			
			_pl.grid.setCursor(nx, ny);
		}
		
		override public function render() : void {
			super.render();

			_pl.render();
			
			/* Optionally resize your stuff here. You can use _width and _height.  */
			_blobTracker.x = _width - _blobTracker.width - 5;
			_blobTracker.y = _height - _blobTracker.height - 5;
		}
	}
}
