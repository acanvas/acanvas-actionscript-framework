package com.rockdot.library.view.component.example {
	import com.rockdot.library.view.component.common.box.accordeon.Accordion;
	import com.rockdot.library.view.component.common.form.button.RadioGroupEvent;
	import com.rockdot.library.view.component.common.form.button.RadioGroupH;
	import com.rockdot.library.view.component.common.form.button.RadioGroupV;
	import com.rockdot.library.view.component.common.video.VideoPlayer;
	import com.rockdot.library.view.component.example.button.ExampleRadioButton;
	import com.rockdot.library.view.component.example.video.MyControls;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Demo extends SpriteComponent {
		private var _radioGroupH : *;
		private var _acc : Accordion;

		public function Demo() {
//			_button();
//			_toggleButton();
//			_radioButton();
//			_grid();
//			_accordion();
//			_slider();
			
			// _sliders();
			// _scrollbars();
			
			// _scrollView();
			// _list();
				
			super();

			var videoPlayer : VideoPlayer = new VideoPlayer(360, 240, MyControls);
			addChild(videoPlayer);
			videoPlayer.video.play("video/pyro.flv");
		}



//
//		private function _button() : void {
//			var button : Button = new ExampleButton("Button - enabled");
//			addChild(button);
//
//			button = new ExampleButton("Button - disabled");
//			button.enabled = false;
//			button.y = 30;
//			addChild(button);
//		}
//
//
//		private function _toggleButton() : void {
//			var button : ToggleButton = new ExampleToggleButton();
//			button.y = 60;
//			addChild(button);
//		}
//

		private function _radioButton() : void {
			var radioGroupV : RadioGroupV = new RadioGroupV(10);
			radioGroupV.addChild(new ExampleRadioButton());
			radioGroupV.addChild(new ExampleRadioButton());
			radioGroupV.addChild(new ExampleRadioButton());
			radioGroupV.addChild(new ExampleRadioButton());
			radioGroupV.addChild(new ExampleRadioButton());
			radioGroupV.addChild(new ExampleRadioButton());
			radioGroupV.addEventListener(RadioGroupEvent.BUTTON_SELECTED, _onSelected);
			radioGroupV.y = 100;
			addChild(radioGroupV);

			_radioGroupH = new RadioGroupH(10);
			_radioGroupH.x = 50;
			_radioGroupH.y = 100;
			_radioGroupH.addChild(new ExampleRadioButton());
			_radioGroupH.addChild(new ExampleRadioButton());
			_radioGroupH.addChild(new ExampleRadioButton());
			_radioGroupH.addChild(new ExampleRadioButton());
			_radioGroupH.addChild(new ExampleRadioButton());
			_radioGroupH.addChild(new ExampleRadioButton());
			addChild(_radioGroupH);

			radioGroupV.selectButton(0);
		}


		private function _onSelected(event : RadioGroupEvent) : void {
			_radioGroupH.selectButton(event.index);
		}

//
//		private function _grid() : void {
//			var tiles : Array = [];
//			for (var i : int = 0; i < 10; i++) {
//				tiles[i] = _getTile();
//			}
//			var grid : Grid = new Grid(tiles, 4, 10);
//			grid.x = 50;
//			grid.y = 150;
//			addChild(grid);
//		}
//
//
//		private function _getTile() : Sprite {
//			return new ExampleButton("X");
//		}
//
//
//		private function _accordion() : void {
//			_acc = new Accordion(0.2, 2);
//			_acc.addChild(new ExampleAccordionCell());
//			_acc.addChild(new ExampleAccordionCell());
//			_acc.addChild(new ExampleAccordionCell());
//			_acc.addChild(new ExampleAccordionCell());
//			_acc.addChild(new ExampleAccordionCell());
//			_acc.addChild(new ExampleAccordionCell());
//			_acc.addChild(new ExampleAccordionCell());
//			_acc.x = 250;
//			_acc.y = 50;
//			addChild(_acc);
//		}
//
//
//		private function _slider() : void {
//			var slider : Slider1 = new Slider1(Orientation.HORIZONTAL, 80, 300, 100);
//			slider.x = 250;
//			slider.addEventListener(SliderEvent.VALUE_CHANGE, _onSliderValueChanged);
//			addChild(slider);
//		}
//
//
//		private function _onSliderValueChanged(event : SliderEvent) : void {
//			_acc.setWidth(event.value);
//		}
//
//
//		private function _sliders() : void {
//			addChild(new Sliders()).x = 20;
//		}
//
//
//		private function _scrollbars() : void {
//			addChild(new Scrollbars());
//		}
//
//
//		private function _video() : void {
//			var videoPlayer : VideoPlayer = new VideoPlayer(320, 240, MyControls);
//			addChild(videoPlayer);
//			videoPlayer.video.autoPlay = false;
//			videoPlayer.video.smoothing = true;
//			videoPlayer.video.play("video/pyro.flv");
//		}
//
//
//		private function _list() : void {
//			var list : IPhoneWithList = new IPhoneWithList(1);
//			addChild(list);
//		}
//
//
//		private function _scrollView() : void {
//			var scrollView0 : IPhoneWithScrollView = new IPhoneWithScrollView(0);
//			addChild(scrollView0);
//
//			// var scrollView1 : IPhoneWithScrollView = new IPhoneWithScrollView(1);
//			// scrollView1.x = scrollView0.x + 581;
//			// addChild(scrollView1);
//		}
	}
}
