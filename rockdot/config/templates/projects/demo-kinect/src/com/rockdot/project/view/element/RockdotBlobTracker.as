package com.rockdot.project.view.element {
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.rockdot.library.util.blobtracker.data.KinectBmdProvider;
	import com.rockdot.library.util.gesture.GestureDictionary;
	import com.rockdot.library.util.gesture.GestureProcessor;
	import com.rockdot.library.util.tracker.MeanshiftTracker;
	import com.rockdot.library.util.tracker.data.BmdProvider;
	import com.rockdot.library.util.tracker.data.WebcamBmdProvider;
	import com.rockdot.library.util.tracker.ui.TrackerRect;
	import com.rockdot.library.util.tracker.vo.Preset;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;




	/**
	 * @author nilsdoehring
	 */
	public class RockdotBlobTracker extends SpriteComponent {
		private var _bmdProvider : BmdProvider;
		private var _shiftTracker : MeanshiftTracker;
		private var _shiftTrackerRect : TrackerRect;
		private var _timer : Timer;
		private var _isTracking : Boolean;
		private var _dataPoints : Vector.<Point> = new Vector.<Point>();
		private var _gestureZone : TrackerRect;
		private var _gestureProcessor : GestureProcessor;
		private var _gestureDictionary : GestureDictionary;
		private var _updateCallback: Function;
		
		public function RockdotBlobTracker(isVisible : Boolean = true) {
			super();
			
			if(Kinect.isSupported())
			{
				_bmdProvider = new KinectBmdProvider();
			}
			else{
				_bmdProvider = new WebcamBmdProvider();
			}

			
			//tracker preset
			var p:Preset = Preset.PRESETS[2];
			
			//tracker
			_shiftTracker = new MeanshiftTracker( _bmdProvider.bmd, p );
			
			//tracking indicator
			_shiftTrackerRect = new TrackerRect( _shiftTracker.width, _shiftTracker.height );

			//zone in which gestures will be detected
			_gestureZone = new TrackerRect( 80, 30 );
		 	_gestureZone.x = 160;
		 	_gestureZone.y = 120;
			
			if(isVisible){
				//listener for adjusting tracking zone
				addEventListener( MouseEvent.MOUSE_DOWN, _onClickVideo );

				//add bmd provider
				addChild( new Bitmap(_bmdProvider.bmd ));
				
				//add tracking indicator
				addChild( _shiftTrackerRect );
			 	
				//add gesture zone
			 	addChild(_gestureZone);
			}
			
			//add gesture detectors
			_gestureProcessor = new GestureProcessor();
			_gestureDictionary = new GestureDictionary();
			
			//initial position
			_trackPosition( new Point(_bmdProvider.bmd.width*0.5, _bmdProvider.bmd.height*0.5) );
			
			//update timer
			_timer = new Timer( 30 );
			_timer.addEventListener( TimerEvent.TIMER, update );
			_timer.start();
		}
		
		public function update( evt:TimerEvent = null):void {
			_bmdProvider.update();
			_shiftTracker.update();
			
			_shiftTrackerRect.x = _shiftTracker.pos.x;
			_shiftTrackerRect.y = _shiftTracker.pos.y;
			
			if(_shiftTrackerRect.getRect(this).intersects(_gestureZone.getRect(this))){
				if(!_isTracking){
					_log.debug("track start");
					_isTracking = true;
				}
				_dataPoints.push(new Point(mouseX, mouseY));
			}
			else{
				if(_isTracking){
					_log.debug("track stop");
					_isTracking = false;
					
					if (_dataPoints && _dataPoints.length > 0) {
						var gesturePoints:Vector.<Point> = _gestureProcessor.process(_dataPoints);
						var index:int = int(_gestureDictionary.findMatch(gesturePoints).matchingIndex);
						
						_log.debug("gesture: " + index + " (8: right, 9: left)");
						if(_submitCallback != null){
							_submitCallback.call(null, index);
						}
					}
					
					_dataPoints = new Vector.<Point>();
				}
			}
			
			if(_updateCallback != null){
				_updateCallback.call(null, _shiftTracker.pos.x, _shiftTracker.pos.y);
			}
		}
		
		
		override public function destroy() : void {
			_timer.removeEventListener( TimerEvent.TIMER, update );
			_timer.stop();
			
			_bmdProvider.bmd.dispose();
			
			super.destroy();
		}
		
		public function trackColor( pos:Point, color:int ):void {
			_shiftTracker.trackColor(pos, color);
		}
		
		protected function _onClickVideo( evt:MouseEvent ):void {
			_trackPosition( new Point( evt.localX, evt.localY ) );
		}
		
		private function _trackPosition( pos:Point ):void {
			_shiftTracker.trackArea(pos);
		}

		public function set updateCallback(updateCallback : Function) : void {
			_updateCallback = updateCallback;
		}
	}
}
