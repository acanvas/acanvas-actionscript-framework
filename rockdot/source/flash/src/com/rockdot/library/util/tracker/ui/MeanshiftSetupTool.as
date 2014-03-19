package com.rockdot.library.util.tracker.ui {
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.events.SliderEvent;

	import com.rockdot.library.util.gesture.GestureDictionary;
	import com.rockdot.library.util.gesture.GestureProcessor;
	import com.rockdot.library.util.tracker.AbstractColorTracker;
	import com.rockdot.library.util.tracker.AbstractTracker;
	import com.rockdot.library.util.tracker.MeanshiftTracker;
	import com.rockdot.library.util.tracker.data.BmdProvider;
	import com.rockdot.library.util.tracker.data.VideoBmdProvider;
	import com.rockdot.library.util.tracker.data.WebcamBmdProvider;
	import com.rockdot.library.util.tracker.events.AutoAdjustEvent;
	import com.rockdot.library.util.tracker.events.ColorPanelEvent;
	import com.rockdot.library.util.tracker.events.TrackerEvent;
	import com.rockdot.library.util.tracker.histogramm.AbstractHistogramm;
	import com.rockdot.library.util.tracker.histogramm.BrightnessHistogramm;
	import com.rockdot.library.util.tracker.histogramm.view.HistogrammSprite;
	import com.rockdot.library.util.tracker.utils.AutoColorAdjuster;
	import com.rockdot.library.util.tracker.vo.Preset;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;


	
	
	//==================================================================
	/**
	 * interface stuff - pretty messy :)
	 */
	public class MeanshiftSetupTool extends MovieClip {
		
		public static const DEBUG:Boolean = true;
		
		protected var bmdProvider:BmdProvider;
		protected var tracker:AbstractColorTracker;
		protected var brightnessHg:AbstractHistogramm;
		protected var autoAdjuster:AutoColorAdjuster;
		
		protected var timer:Timer;
		
		protected var videoSprite:Sprite;
		
		protected var trackerRect:TrackerRect;
		protected var colorPanel:ColorPanel;
		
		protected var presetCombo:ComboBox;
		
		protected var trackerSizeSlider:LabelledSlider;
		protected var toleranceSlider:LabelledSlider;
		protected var minPixSlider:LabelledSlider;
		
		protected var rSlider:LabelledSlider;
		protected var gSlider:LabelledSlider;
		protected var bSlider:LabelledSlider;
		
		protected var brightnessHgSprite:HistogrammSprite;
		protected var brightnessHgTxt:TextField;
		
		protected var autoCheckBox:CheckBox;
		protected var brightnessCheckBox:CheckBox;
		protected var motionCheckBox:CheckBox;
		protected var freezeCheckBox:CheckBox;
		
		protected var trackerPath:TrackerPathPanel;
		
		protected var infoTxt : TextField;
		private var _gestureProcessor : GestureProcessor;
		private var _gestureDictionary : GestureDictionary;
		private var _trackerZone : TrackerRect;
		private var _drawPoints : Vector.<Point>;
		private var _dataPoints : Vector.<Point>;
		private var _isTracking : Boolean;
		
		// ==================================================================
		public function MeanshiftSetupTool() {
			
			addEventListener(Event.CLOSE, unloadHandler);
			
			initBmd();
			initTracker();
			initTrackerAssets();
			
			initGui();
			addGuiChildren();
			arrangeGui();
			
			initGestures();
			start();
		}

		private function initGestures() : void {
			 _trackerZone = new TrackerRect( 160, 80 );
			 videoSprite.addChild(_trackerZone);
			 _trackerZone.x = 160;
			 _trackerZone.y = 120;
			 
			
			_dataPoints = new Vector.<Point>();
		}
		
		private function updateGestures() : void {
			if(trackerRect.getRect(videoSprite).intersects(_trackerZone.getRect(videoSprite))){
				trace("bäm");
				_isTracking = true;
				_dataPoints.push(new Point(mouseX, mouseY));
			}
			else{
				if(_isTracking){
					trace("unbäm");
					_isTracking = false;
					
					if (_dataPoints && _dataPoints.length > 0) {
						var gesturePoints:Vector.<Point> = _gestureProcessor.process(_dataPoints);
						var index:int = int(_gestureDictionary.findMatch(gesturePoints).matchingIndex);
						
						trace("gesture: " + index + " (8: right, 9: left)");
					}
					
					_dataPoints = new Vector.<Point>();
				}
			}
		}

		private function unloadHandler(event : Event) : void {
			timer.removeEventListener( TimerEvent.TIMER, update );
			timer.stop();
		}
		
		//==================================================================
		public function update( evt:TimerEvent ):void {
			if(!freezeCheckBox.selected) bmdProvider.update();
			updateBrightness();
			
			tracker.update();
			
			trackerRect.x = tracker.pos.x;
			trackerRect.y = tracker.pos.y;
			
			trackerPath.addNode( tracker.pos );
			
			updateGestures();
			
			updateInfoTxt();
		}

		
		//==================================================================
		// event handlers
		protected function onAddedToStage( evt:Event ):void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener( Event.RESIZE, onResize );
			
			onResize();
			
			timer.start();
		}
		protected function onClickVideo( evt:MouseEvent ):void {
			trackPosition( new Point( evt.localX, evt.localY ) );
		}
		protected function onTrackerResize( evt:TrackerEvent ):void {
			trackerRect.width = evt.width;
			trackerRect.height = evt.height;
		}
		
		protected function onPresetChange( evt:Event ):void {
			var p:Preset = Preset( presetCombo.selectedItem );
			tracker.color = p.color;
			tracker.width = p.trackerSize;
			tracker.height = p.trackerSize;
			tracker.tolerance = p.tolerance;
			tracker.minPixelsFound = p.minPixelsFound;
			
			updateUIComponents();
		}
		
		protected function onTrackerSizeSliderChange( evt:SliderEvent ):void {
			tracker.width = tracker.height = evt.value;
			trackerRect.width = tracker.width;
			trackerRect.height = tracker.height;
		}
		protected function onMinPixSliderChange( evt:SliderEvent ):void {
			tracker.minPixelsFound = evt.value;
		}
		protected function onToleranceSliderChange( evt:SliderEvent ):void {
			tracker.tolerance = evt.value;
		}
		
		protected function onColorSliderChange( evt:SliderEvent ):void {
			var r:int = rSlider.value;
			var g:int = gSlider.value;
			var b:int = bSlider.value;
			var c:int = ( r<<16 | g<<8 | b );
			if(c!=tracker.color) trackColor( c );
		}
		
		protected function onAutoCheckBoxChange( evt:Event ):void {
			var selected:Boolean = CheckBox( evt.target ).selected;
			toleranceSlider.slider.enabled = !selected;
			minPixSlider.slider.enabled = !selected;
			brightnessCheckBox.enabled = !selected;
			if(selected) {
				brightnessCheckBox.selected = true;
				brightnessCheckBox.dispatchEvent( new Event( Event.CHANGE ) );
			}
		}
		
		protected function onAutoAdjust( evt:AutoAdjustEvent ):void {
			updateUIComponents();
		}
		
		protected function onBrightnessCheckBoxChange( evt:Event ):void {
			brightnessHgSprite.enabled = brightnessCheckBox.selected;
		}
		protected function onMotionCheckBoxChange( evt:Event ):void {
			var selected:Boolean = CheckBox( evt.target ).selected;
			MeanshiftTracker( tracker ).motionPrediction = selected;
		}
		protected function onColorSelected( evt:ColorPanelEvent ):void {
			trackColor(evt.color);
		}
		protected function onResize( evt:Event=null ):void {
			x = y = 8;
			filters = [new DropShadowFilter(1,90,0x000000,0.5,4,4,3,2)];;
		}
		
		//==================================================================
		protected function trackPosition( pos:Point ):void {
			tracker.trackArea(pos);
			trackerRect.width = tracker.width;
			trackerRect.height = tracker.height;
			updateUIComponents();
		}
		protected function trackColor( color:int ):void {
			tracker.color = color;
			updateUIComponents();
		}
		protected function updateBrightness():void {
			if(!brightnessCheckBox.selected) return;
			
			brightnessHg.update();
			brightnessHgSprite.update();
			brightnessHgTxt.text = "brightness median: "+brightnessHg.median;
			
			if(autoCheckBox.selected) autoAdjuster.update();
		}
		protected function updateInfoTxt():void {
			
			if(tracker.status==AbstractTracker.STATUS_OK) {
				infoTxt.textColor = 0x66FF00;
				infoTxt.text = "found object at x: "+int(tracker.pos.x+0.5)+", y: "+int(tracker.pos.y+0.5);
				
			} else if(tracker.status==AbstractTracker.STATUS_NOTHING_FOUND) {
				infoTxt.textColor = 0xFF6600;
				infoTxt.text = "no matching object found";
				
			}
		}
		protected function updateUIComponents( evt:Event=null ):void {
			var color:int = tracker.color;
			colorPanel.color = color;
			
			rSlider.value = (color&0xFF0000)>>16;
			gSlider.value = (color&0xFF00)>>8;
			bSlider.value = (color&0xFF);
			
			trackerSizeSlider.value = Math.max(tracker.width, tracker.height);
			toleranceSlider.value = tracker.tolerance;
			minPixSlider.value = tracker.minPixelsFound;
		}
		
		//==================================================================
		protected function initBmd():void {

			if(Camera.isSupported)
			{
				bmdProvider = new WebcamBmdProvider();
			}
			else{
				bmdProvider = new VideoBmdProvider();
			}
		}
		
		protected function initTracker():void {
			tracker = new MeanshiftTracker( bmdProvider.bmd );
			tracker.width = 64;
			tracker.height = 64;
			tracker.maxWidth = 4*bmdProvider.bmd.width;
			tracker.maxHeight = 4*bmdProvider.bmd.height;
			tracker.tolerance = 8;
			tracker.minPixelsFound = 8;
		}
		
		protected function initTrackerAssets():void  {
			brightnessHg = new BrightnessHistogramm( bmdProvider.bmd, true );
			autoAdjuster = new AutoColorAdjuster( tracker, brightnessHg );
			autoAdjuster.addEventListener( AutoAdjustEvent.ADJUST, onAutoAdjust );
		}
		
		//==================================================================
		protected function initGui():void {
			// video
			videoSprite = new Sprite();
			videoSprite.addEventListener( MouseEvent.MOUSE_DOWN, onClickVideo );
			
			trackerRect = new TrackerRect( tracker.width, tracker.height );
			
			videoSprite.addChild( new Bitmap( bmdProvider.bmd ) );
			videoSprite.addChild( trackerRect );
			
			// color panel
			colorPanel = new ColorPanel( bmdProvider.bmd.width, 32, tracker.color );
			colorPanel.addEventListener( ColorPanelEvent.COLOR_SELECTED, onColorSelected );
			
			// brightness histogramm
			brightnessHgSprite = new HistogrammSprite( brightnessHg );
			
			// histogramm txt
			brightnessHgTxt = new StandardTxt();
			brightnessHgTxt.width = brightnessHgSprite.width;
			brightnessHgTxt.text = " ";
			
			// tracker path panel
			trackerPath = new TrackerPathPanel( 256, 256*0.75, videoSprite.width, videoSprite.height );
			
			// preset combo
			presetCombo = new ComboBox();
			presetCombo.width = 256;
			presetCombo.addEventListener( Event.CHANGE, onPresetChange );
			var p:Array = Preset.PRESETS;
			for(var i:int=0; i<p.length; i++) {
				presetCombo.addItem( Preset(p[i]) );
			}
			presetCombo.selectedIndex = Preset.DEFAULT_ID;
			
			// sliders
			trackerSizeSlider = new LabelledSlider("tracker size",2,128,tracker.width,true);
			trackerSizeSlider.sliderX = 100;
			trackerSizeSlider.addEventListener( SliderEvent.CHANGE, onTrackerSizeSliderChange );
			
			toleranceSlider = new LabelledSlider("tolerance",0,64,tracker.tolerance,true);
			toleranceSlider.sliderX = 100;
			toleranceSlider.addEventListener( SliderEvent.CHANGE, onToleranceSliderChange );
			
			minPixSlider = new LabelledSlider("min pixels found",0,64,tracker.minPixelsFound,true);
			minPixSlider.sliderX = 100;
			minPixSlider.addEventListener( SliderEvent.CHANGE, onMinPixSliderChange );
			
			// rgb sliders
			rSlider = new LabelledSlider("red",0,255,(tracker.color&0xFF0000)>>16,true);
			rSlider.sliderX = 100;
			rSlider.addEventListener( SliderEvent.CHANGE, onColorSliderChange );
			
			gSlider = new LabelledSlider("green",0,255,(tracker.color&0xFF0000)>>16,true);
			gSlider.sliderX = 100;
			gSlider.addEventListener( SliderEvent.CHANGE, onColorSliderChange );
			
			bSlider = new LabelledSlider("blue",0,255,(tracker.color&0xFF0000)>>16,true);
			bSlider.sliderX = 100;
			bSlider.addEventListener( SliderEvent.CHANGE, onColorSliderChange );
			
			// auto check box
			autoCheckBox = new CheckBox();
			autoCheckBox.addEventListener( Event.CHANGE, onAutoCheckBoxChange );
			autoCheckBox.setStyle("textFormat", StandardTxt.defTextFormat );
			autoCheckBox.textField.autoSize = TextFieldAutoSize.LEFT;
			autoCheckBox.label = "adjust settings to brightness";
			
			// brightness check box
			brightnessCheckBox = new CheckBox();
			brightnessCheckBox.addEventListener( Event.CHANGE, onBrightnessCheckBoxChange );
			brightnessCheckBox.setStyle("textFormat", StandardTxt.defTextFormat );
			brightnessCheckBox.textField.autoSize = TextFieldAutoSize.LEFT;
			brightnessCheckBox.label = "display current brightness";
			
			// motion check box
			motionCheckBox = new CheckBox();
			motionCheckBox.addEventListener( Event.CHANGE, onMotionCheckBoxChange );
			motionCheckBox.setStyle("textFormat", StandardTxt.defTextFormat );
			motionCheckBox.textField.autoSize = TextFieldAutoSize.LEFT;
			motionCheckBox.label = "motion prediction";
			
			// freeze check box
			freezeCheckBox = new CheckBox();
			freezeCheckBox.setStyle("textFormat", StandardTxt.defTextFormat );
			freezeCheckBox.textField.autoSize = TextFieldAutoSize.LEFT;
			freezeCheckBox.label = "freeze picture";
			
			// init ui component setups
			autoCheckBox.selected = false;
			autoCheckBox.dispatchEvent( new Event( Event.CHANGE ) );
			
			brightnessCheckBox.selected = true;
			brightnessCheckBox.dispatchEvent( new Event( Event.CHANGE ) );
			
			motionCheckBox.selected = MeanshiftTracker( tracker ).motionPrediction;
			motionCheckBox.dispatchEvent( new Event( Event.CHANGE ) );
			
			// info txt
			infoTxt = new StandardTxt();
			infoTxt.width = videoSprite.width;
			infoTxt.filters = [ new DropShadowFilter(1,90,0x000000,1,4,4,3,2) ];
		}
		
		protected function addGuiChildren():void {
			addChild( videoSprite );
			addChild( colorPanel );
			
			addChild( brightnessHgSprite );
			addChild( brightnessHgTxt );
			addChild( trackerPath );
			addChild( presetCombo );
			
			addChild( trackerSizeSlider );
			addChild( toleranceSlider );
			addChild( minPixSlider );
			
			addChild( rSlider );
			addChild( gSlider );
			addChild( bSlider );
			
			addChild( autoCheckBox );
			addChild( brightnessCheckBox );
			addChild( motionCheckBox );
			addChild( freezeCheckBox );
			
			addChild( infoTxt );
			
			// depths
			swapChildren( infoTxt, colorPanel );
		}
		
		protected function arrangeGui():void {
			// info
			trackerRect.x = trackerRect.width*0.5;	// avoids that trackerRect pos influences width/height of video sprite
			trackerRect.y = trackerRect.height*0.5;
			
			colorPanel.y = videoSprite.y+bmdProvider.bmd.height + 2;
			
			brightnessHgSprite.x = videoSprite.x + videoSprite.width + 8;
			brightnessHgSprite.y = videoSprite.y;
			
			brightnessHgTxt.x = brightnessHgSprite.x;
			brightnessHgTxt.y = brightnessHgSprite.y + brightnessHgSprite.height;
			
			trackerPath.x = brightnessHgTxt.x;
			trackerPath.y = brightnessHgTxt.y + brightnessHgTxt.height + 4;
			
			// options
			presetCombo.x = colorPanel.x;
			presetCombo.y = colorPanel.y + colorPanel.height + 4;
			
			trackerSizeSlider.y = presetCombo.y + presetCombo.height + 4;
			toleranceSlider.y = trackerSizeSlider.y + trackerSizeSlider.height;
			minPixSlider.y = toleranceSlider.y + toleranceSlider.height;
			
			rSlider.y = minPixSlider.y + minPixSlider.height + 8;
			gSlider.y = rSlider.y + rSlider.height;
			bSlider.y = gSlider.y + gSlider.height;
			
			// check boxes
			autoCheckBox.x = bSlider.x - 4;
			autoCheckBox.y = bSlider.y + bSlider.height + 8;
			
			brightnessCheckBox.x = autoCheckBox.x;
			brightnessCheckBox.y = autoCheckBox.y + autoCheckBox.height;
			
			motionCheckBox.x = brightnessCheckBox.x;
			motionCheckBox.y = brightnessCheckBox.y + brightnessCheckBox.height;
			
			freezeCheckBox.x = motionCheckBox.x;
			freezeCheckBox.y = motionCheckBox.y + motionCheckBox.height;
			
			infoTxt.y = videoSprite.y + videoSprite.height - 16;
		}
		
		//==================================================================
		protected function start():void {
			timer = new Timer( 30 );
			timer.addEventListener( TimerEvent.TIMER, update );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			trackPosition( new Point(bmdProvider.bmd.width*0.5, bmdProvider.bmd.height*0.5) );
			presetCombo.dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		//==================================================================
		public override function toString():String {
			return "[ MeanshiftSetup ]";
		}
		protected function log( msg:Object ):void {
			if(DEBUG) trace(this+"\t"+msg);
		}
	}
	
}