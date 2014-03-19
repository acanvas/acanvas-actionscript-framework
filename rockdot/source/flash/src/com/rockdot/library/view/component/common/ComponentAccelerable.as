package com.rockdot.library.view.component.common {
	import com.jvm.utils.DeviceDetector;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.sensors.Accelerometer;




	/**
	 * @author nilsdoehring
	 */
	public class ComponentAccelerable extends SpriteComponent{

		protected var _acc : Accelerometer;
		protected var _originX : Number;

		override public function set enabled(value : Boolean) : void {
			
			if( value == true && DeviceDetector.IS_MOBILE) {
				_acc = new Accelerometer();
				_acc.setRequestedUpdateInterval(100);
				_acc.addEventListener(AccelerometerEvent.UPDATE, _onUpdating);
			} else if(_acc) {
				_acc.removeEventListener(AccelerometerEvent.UPDATE, _onUpdating);
			}
		}

		protected function _onUpdating(event : Event) : void {
			var e : AccelerometerEvent = event as AccelerometerEvent;
			if(_submitCallback){
				_submitCallback.call(null, {x:e.accelerationX, y:e.accelerationY, z:e.accelerationZ});
			}
		}
	}
}
