package com.rockdot.project.view.element {
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.rockdot.library.util.blobtracker.data.KinectBmdProvider;
	import com.rockdot.library.util.tracker.FaceTracker;
	import com.rockdot.library.util.tracker.data.BmdProvider;
	import com.rockdot.library.util.tracker.data.WebcamBmdProvider;
	import com.rockdot.library.util.tracker.ui.TrackerRect;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;




	/**
	 * @author nilsdoehring
	 */
	public class RockdotFaceTracker extends SpriteComponent {
		private var _bmdProvider : BmdProvider;
		private var _shiftTracker : FaceTracker;
		private var _shiftTrackerRect : TrackerRect;
		private var _timer : Timer;
		private var _updateCallback : Function;
		private var _isInitialized : Boolean = false;

		public function RockdotFaceTracker(isVisible : Boolean = true) {
			super();
			
			if(Kinect.isSupported())
			{
				_bmdProvider = new KinectBmdProvider();
			}
			else{
				_bmdProvider = new WebcamBmdProvider();
			}

			//tracker
			_shiftTracker = new FaceTracker( _bmdProvider.bmd );
			
			//tracking indicator
			_shiftTrackerRect = new TrackerRect( _shiftTracker.width, _shiftTracker.height );
			_shiftTrackerRect.x = _bmdProvider.bmd.width/2 - _shiftTrackerRect.width/2;
			_shiftTrackerRect.y = _bmdProvider.bmd.height/2 - _shiftTrackerRect.height/2;
			addEventListener(MouseEvent.MOUSE_UP, _startTracking);
			
			if(isVisible){
				//add bmd provider
				addChild( new Bitmap(_bmdProvider.bmd ));
				
				//add tracking indicator
				addChild( _shiftTrackerRect );
			 	
			}
			
			//update timer
			_timer = new Timer( 30 );
			_timer.addEventListener( TimerEvent.TIMER, update );
			_timer.start();
		}

		private function _startTracking(event : MouseEvent) : void {
//			_shiftTrackerRect.removeEventListener(MouseEvent.MOUSE_UP, _startTracking);
			_shiftTracker.init();
			_isInitialized = true;
		}
		
		public function update( evt:TimerEvent = null):void {
			_bmdProvider.update();
			
			if(!_isInitialized){
				return;
			}
			_shiftTracker.update();
			
			_shiftTrackerRect.x = _shiftTracker.pos.x;
			_shiftTrackerRect.y = _shiftTracker.pos.y;
			
			_log.debug("tracker x: {0}, y: {1}", [_shiftTrackerRect.x, _shiftTrackerRect.y]);
			
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
		
		public function set updateCallback(updateCallback : Function) : void {
			_updateCallback = updateCallback;
		}
	}
}
