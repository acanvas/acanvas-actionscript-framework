package com.rockdot.library.view.component.example.scrolling.slider {
	import com.rockdot.library.view.component.common.scrollable.event.SliderEvent;
	import com.jvm.components.Orientation;

	import flash.display.Sprite;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Sliders extends Sprite {
		public function Sliders() {
			// Slider1
			var slider1H : Slider1 = new Slider1(Orientation.HORIZONTAL, 0, 300, 300);
			slider1H.addEventListener(SliderEvent.INTERACTION_END, _onSliderDragEnd);
			slider1H.addEventListener(SliderEvent.INTERACTION_START, _onSliderDragStart);
			slider1H.addEventListener(SliderEvent.MOMENTUM_END, _onSliderWorkingEnd);
			slider1H.addEventListener(SliderEvent.MOMENTUM_START, _onSliderWorkingStart);
			slider1H.addEventListener(SliderEvent.VALUE_CHANGE, _onSliderValueChange);
			slider1H.addEventListener(SliderEvent.CHANGE_START, _onSliderChangeStart);
			slider1H.addEventListener(SliderEvent.CHANGE_END, _onSliderChangeEnd);
			slider1H.x = 100;
			slider1H.y = 10;
			slider1H.momentumEnabled = true;
			slider1H.mouseWheelSensitivity = 1;
			addChild(slider1H);

			var slider1V : Slider1 = new Slider1(Orientation.VERTICAL, 0, 10, 300);
			slider1V.x = 480;
			slider1V.y = 10;
			addChild(slider1V);

			// Slider2
			var slider2H : Slider2 = new Slider2(Orientation.HORIZONTAL, 0, 10, 300, true);
			slider2H.x = slider1H.x;
			slider2H.y = slider1H.y + slider1H.height + 20;
			slider2H.value = 5;
			addChild(slider2H);

			var slider2V : Slider2 = new Slider2(Orientation.VERTICAL, 0, 10, 300, true);
			slider2V.x = slider1V.x + slider1V.width + 20;
			slider2V.y = slider1V.y;
			slider2V.value = 5;
			addChild(slider2V);

			// Slider3
			var slider3H : Slider3 = new Slider3(Orientation.HORIZONTAL, 0, 10, 300, true);
			slider3H.x = slider2H.x;
			slider3H.y = slider2H.y + slider2H.height + 20;
			addChild(slider3H);

			var slider3V : Slider3 = new Slider3(Orientation.VERTICAL, 0, 10, 300, true);
			slider3V.x = slider2V.x + slider2V.width + 20;
			slider3V.y = slider2V.y;
			addChild(slider3V);

			// Slider4
			var slider4H : Slider4 = new Slider4(Orientation.HORIZONTAL, 0, 300, 300, false);
			slider4H.x = slider3H.x;
			slider4H.y = slider3H.y + slider2H.height + 20;
			slider4H.mouseWheelSensitivity = 1;
			slider4H.momentumEnabled = true;
			slider4H.momentumFriction = 1;

			addChild(slider4H);

			var slider4V : Slider4 = new Slider4(Orientation.VERTICAL, 0, 10, 300, false);
			slider4V.x = slider3V.x + slider3V.width + 20;
			slider4V.y = slider3V.y;
			slider4V.mouseWheelSensitivity = 1;
			addChild(slider4V);

			// Slider5
			var slider5H : Slider5 = new Slider5(Orientation.HORIZONTAL, 0, 8, 300, false);
			slider5H.x = slider4H.x;
			slider5H.y = slider4H.y + slider4H.height + 20;
			slider5H.mouseWheelSensitivity = 1;
			addChild(slider5H);

			var slider5V : Slider5 = new Slider5(Orientation.VERTICAL, 0, 8, 300, false);
			slider5V.x = slider4V.x + slider4V.width + 20;
			slider5V.y = slider4V.y;
			slider5V.mouseWheelSensitivity = 1;
			addChild(slider5V);

			// Slider6
			var slider6H : Slider6 = new Slider6(Orientation.HORIZONTAL, 0, 800, 300, true);
			slider6H.x = slider5H.x;
			slider6H.y = slider5H.y + slider5H.height + 20;
			addChild(slider6H);

			var slider6V : Slider6 = new Slider6(Orientation.VERTICAL, 0, 800, 300, true);
			slider6V.x = slider5V.x + slider5V.width + 20;
			slider6V.y = slider5V.y;
			addChild(slider6V);
		}


		private function _onSliderDragEnd(event : SliderEvent) : void {
			trace("INTERACTION END", event.value);
		}


		private function _onSliderDragStart(event : SliderEvent) : void {
			trace("INTERACTION START", event.value);
		}


		private function _onSliderWorkingEnd(event : SliderEvent) : void {
			trace("WORKING END", event.value);
		}


		private function _onSliderWorkingStart(event : SliderEvent) : void {
			trace("WORKING START", event.value);
		}


		private function _onSliderValueChange(event : SliderEvent) : void {
			trace("VALUE", event.value);
		}


		private function _onSliderChangeStart(event : SliderEvent) : void {
			trace("CHANGE START", event.value);
		}


		private function _onSliderChangeEnd(event : SliderEvent) : void {
			trace("CHANGE END", event.value);
		}
	}
}
