package com.rockdot.project.view.element.pointlight {
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import org.zozuar.volumetrics.VolumetricPointLight;

	import flash.events.Event;
	import flash.events.MouseEvent;

    public class PointLightDemo extends SpriteComponent {
        private var _fx:VolumetricPointLight;
        private var _grid:Grid = new Grid();
        private var _sun:SunIcon = new SunIcon();

        public function PointLightDemo():void {
			super();

            // Create a VolumetricPointLight object, use the grid as the occlusion object.
            _fx = new VolumetricPointLight(800, 600, _grid, [0xc08040, 0x4080c0, 0]);
            // You can also specify a single color instead of gradient params, for example:
            //   fx = new VolumetricPointLight(800, 600, grid, 0xc08040);
            // is equivalent to:
            //   fx = new VolumetricPointLight(800, 600, grid, [0xc08040, 0], [1, 1], [0, 255]);

            addChild(_fx);

//			render();

            // Sun icon used to control light source position
            addChild(_sun);
            _sun.buttonMode = true;
			
			
			_sun.visible = false;
        }
		
		
		override public function set enabled(value : Boolean) : void {
			super.enabled = value;
			
			if(value == true){
	            _sun.addEventListener(MouseEvent.MOUSE_DOWN, _onStartDrag);
	            _sun.addEventListener(MouseEvent.MOUSE_UP, _onStopDrag);
	            addEventListener(Event.ENTER_FRAME, _onEnterFrame);
            	
				// Render on every frame.
            	_fx.startRendering();
			}
			else{
	            _sun.removeEventListener(MouseEvent.MOUSE_DOWN, _onStartDrag);
	            _sun.removeEventListener(MouseEvent.MOUSE_UP, _onStopDrag);
	            removeEventListener(Event.ENTER_FRAME, _onEnterFrame);

            	_fx.stopRendering();
			}
			
		}
		
		override public function render() : void {
			super.render();
			
            _fx.setViewportSize(_width, _height);
            _sun.x = _fx.srcX = _width/2;
            _sun.y = _fx.srcY = _height/2;
            _grid.x = _width/2-232;
            _grid.y = _height/2-232;

		}

		private function _onEnterFrame(event : Event) : void {
			_fx.srcX = _sun.x;
			_fx.srcY = _sun.y;
		}

		private function _onStartDrag(event : MouseEvent) : void {
			_sun.startDrag();
		}

		private function _onStopDrag(event : MouseEvent) : void {
			_sun.stopDrag();
		}

		public function get grid() : Grid {
			return _grid;
		}


    }
}


