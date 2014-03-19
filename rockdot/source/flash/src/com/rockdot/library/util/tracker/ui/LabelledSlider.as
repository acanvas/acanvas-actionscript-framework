package com.rockdot.library.util.tracker.ui {
	import fl.controls.Slider;
	import fl.events.InteractionInputType;
	import fl.events.SliderEvent;
	import fl.events.SliderEventClickTarget;

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	public class LabelledSlider extends Sprite {
		
		private var _slider:Slider;
		private var _labelTxt:TextField;
		private var _valueTxt:TextField;
		
		private var textFormat:TextFormat;
		private var txtFilters:Array;
		
		public function LabelledSlider( label:String="", min:Number=0, max:Number=1, initValue:Number=0.5, liveDragging:Boolean=false ) {
			
			textFormat = new TextFormat("Verdana",11,0xFFFFFF);
			txtFilters = [/*new DropShadowFilter(1,90,0x000000,1,4,4,3,2)*/];
			
			_labelTxt = new TextField();
			_slider = new Slider();
			_valueTxt = new TextField();
			
			_labelTxt.defaultTextFormat = textFormat;
			_labelTxt.autoSize = TextFieldAutoSize.LEFT;
			_labelTxt.selectable = false;
			_labelTxt.filters = txtFilters;
			_labelTxt.text = label;
			
			_slider.addEventListener( SliderEvent.CHANGE, onSliderChange );
			_slider.minimum = min;
			_slider.maximum = max;
			_slider.value = initValue;
			_slider.liveDragging = liveDragging;
			_slider.width = 128;
			_slider.x = _labelTxt.x + _labelTxt.width + 4;
			_slider.y = 6;
			
			_valueTxt.defaultTextFormat = textFormat;
			_valueTxt.autoSize = TextFieldAutoSize.LEFT;
			_valueTxt.selectable = false;
			_valueTxt.filters = txtFilters;
			_valueTxt.text = initValue.toString();
			_valueTxt.x = _slider.x + _slider.width + 4;
			
			addChild(_labelTxt);
			addChild(_valueTxt);
			addChild(_slider);
		}
		
		public function get slider():Slider {
			return _slider;
		}
		
		public function get value():Number { return _slider.value; }
		public function set value( v:Number ):void {
			_slider.value = v;
			onSliderChange( new SliderEvent( SliderEvent.CHANGE, v, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE) );
		}
		
		public function get sliderX():int {	return _slider.x; }
		
		public function set sliderX( x:int ):void {
			_slider.x = x;
			_valueTxt.x = _slider.x + _slider.width + 4;
		}
		
		private function onSliderChange( evt:SliderEvent ):void {
			_valueTxt.text = _slider.value.toString();
			_valueTxt.filters = txtFilters;
			dispatchEvent( evt );
		}
	}
	
}