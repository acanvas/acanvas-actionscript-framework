package com.rockdot.library.view.component.example.scrolling.scrollbars {
	import com.rockdot.library.view.component.common.scrollable.event.SliderEvent;
	import com.jvm.components.Orientation;

	import flash.display.Sprite;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Scrollbars extends Sprite {
		public function Scrollbars() {
			// Slider1
			var slider1H : Scrollbar1 = new Scrollbar1(Orientation.HORIZONTAL, 700, 200);
			slider1H.addEventListener(SliderEvent.INTERACTION_END, _onSliderDragEnd);
			slider1H.addEventListener(SliderEvent.INTERACTION_START, _onSliderDragStart);
			slider1H.addEventListener(SliderEvent.MOMENTUM_END, _onSliderWorkingEnd);
			slider1H.addEventListener(SliderEvent.MOMENTUM_START, _onSliderWorkingStart);
			slider1H.addEventListener(SliderEvent.VALUE_CHANGE, _onSliderValueChange);
			slider1H.addEventListener(SliderEvent.CHANGE_START, _onSliderChangeStart);
			slider1H.addEventListener(SliderEvent.CHANGE_END, _onSliderChangeEnd);
			
			slider1H.x = 100;
			slider1H.y = 10;
			slider1H.bounce = true;
			slider1H.mouseWheelSensitivity = 1;
			slider1H.pages = 10;
			slider1H.momentumEnabled = true;
			slider1H.snapToPage = true;
			addChild(slider1H);

			var slider1V : Scrollbar1 = new Scrollbar1(Orientation.VERTICAL, 700, 700);
			slider1V.x = 830;
			slider1V.y = 10;
			slider1V.bounce = true;
			slider1V.mouseWheelSensitivity = 1;
			slider1V.pages = 10;
			slider1V.momentumEnabled = true;
			addChild(slider1V);

			return;

			// Slider2
			var slider2H : Scrollbar2 = new Scrollbar2(Orientation.HORIZONTAL, 10, 300);
			slider2H.x = slider1H.x;
			slider2H.y = slider1H.y + slider1H.height + 20;
			slider2H.value = 5;
			addChild(slider2H);

			var slider2V : Scrollbar2 = new Scrollbar2(Orientation.VERTICAL, 10, 300);
			slider2V.x = slider1V.x + slider1V.width + 20;
			slider2V.y = slider1V.y;
			slider2V.value = 5;
			addChild(slider2V);

			// Slider3
			var slider3H : Scrollbar3 = new Scrollbar3(Orientation.HORIZONTAL, 10, 300);
			slider3H.x = slider2H.x;
			slider3H.y = slider2H.y + slider2H.height + 20;
			addChild(slider3H);

			var slider3V : Scrollbar3 = new Scrollbar3(Orientation.VERTICAL, 10, 300);
			slider3V.x = slider2V.x + slider2V.width + 20;
			slider3V.y = slider2V.y;
			addChild(slider3V);

			// Slider4
			var slider4H : Scrollbar4 = new Scrollbar4(Orientation.HORIZONTAL, 10, 300);
			slider4H.x = slider3H.x;
			slider4H.y = slider3H.y + slider2H.height + 20;
			slider4H.mouseWheelSensitivity = 1;
			addChild(slider4H);

			var slider4V : Scrollbar4 = new Scrollbar4(Orientation.VERTICAL, 10, 300);
			slider4V.x = slider3V.x + slider3V.width + 20;
			slider4V.y = slider3V.y;
			slider4V.mouseWheelSensitivity = 1;
			addChild(slider4V);

			// Slider5
			var slider5H : Scrollbar5 = new Scrollbar5(Orientation.HORIZONTAL, 8, 300);
			slider5H.x = slider4H.x;
			slider5H.y = slider4H.y + slider4H.height + 20;
			slider5H.mouseWheelSensitivity = 1;
			addChild(slider5H);

			var slider5V : Scrollbar5 = new Scrollbar5(Orientation.VERTICAL, 8, 300);
			slider5V.x = slider4V.x + slider4V.width + 20;
			slider5V.y = slider4V.y;
			slider5V.mouseWheelSensitivity = 1;
			addChild(slider5V);

			// Slider6
			var slider6H : Scrollbar6 = new Scrollbar6(Orientation.HORIZONTAL, 800, 300);
			slider6H.x = slider5H.x;
			slider6H.y = slider5H.y + slider5H.height + 20;
			addChild(slider6H);

			var slider6V : Scrollbar6 = new Scrollbar6(Orientation.VERTICAL, 800, 300);
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
