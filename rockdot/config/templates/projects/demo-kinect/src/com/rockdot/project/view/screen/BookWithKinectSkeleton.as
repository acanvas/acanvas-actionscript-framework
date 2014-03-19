package com.rockdot.project.view.screen {


	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
	import com.tonybeltramelli.airkinect.ActionManager;
	import com.tonybeltramelli.airkinect.debug.KinectDebugger;
	import com.tonybeltramelli.airkinect.userAction.event.KinectGestureEvent;
	import com.tonybeltramelli.airkinect.userAction.gesture.HorizontalSwipe;
	import com.tonybeltramelli.airkinect.userAction.gesture.settings.part.GesturePart;

	import flash.events.Event;
	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class BookWithKinectSkeleton extends Book {
		private var _kinect : Kinect;
		private var _actionManager : ActionManager;
		private var _debugger : KinectDebugger;
		private var _leftHandVerticalSwipe : HorizontalSwipe;

		public function BookWithKinectSkeleton(id : String)
		{
				super(id);
				_fireInit = false;
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);
			
			if(Kinect.isSupported())
			{
				_initKinect();
			}
			
			_didInit();
		}

		private function _initKinect() : void {
			_kinect = Kinect.getDevice();

			var settings : KinectSettings = new KinectSettings();
			settings.skeletonEnabled = true;

			_kinect.start(settings);
			_kinect.addEventListener(DeviceEvent.STARTED, _started);
			
			//kinect feedback to display skeleton and joints
			_debugger = new KinectDebugger(_kinect, true, true, false, false);
			addChild(_debugger);
			
			//instantiation of our ActionManager with the stage frame rate in parameter in order to compute the gestures analysis
			_actionManager = new ActionManager(stage.frameRate);
			
			//creation of a gesture to track the left swipe with the left hand
			_leftHandVerticalSwipe = new HorizontalSwipe(GesturePart.LEFT_HAND);
			_leftHandVerticalSwipe.dispatcher.addEventListener(KinectGestureEvent.LEFT_SWIPE, _leftSwipeWithLeftHandOccured);
			_leftHandVerticalSwipe.dispatcher.addEventListener(KinectGestureEvent.RIGHT_SWIPE, _rightSwipeWithLeftHandOccured);
			
			_actionManager.add(_leftHandVerticalSwipe);
		}

		private function _started(event : DeviceEvent) : void {
			_kinect.removeEventListener(DeviceEvent.STARTED, _started);
			addEventListener(Event.ENTER_FRAME, _enterFrame);
		}

		private function _enterFrame(event : Event) : void
		{
			for each(var user : User in _kinect.users)
			{
				//draw the kinect feedback in the debugger
				_debugger.draw(user);
				
				//ask your ActionManager to compute and analyze user's actions
				_actionManager.compute(user);	
			}
			
		}
		
		private function _leftSwipeWithLeftHandOccured(event : KinectGestureEvent) : void {
			_book.nextPage();
		}
		private function _rightSwipeWithLeftHandOccured(event : KinectGestureEvent) : void {
			_book.prevPage();
		}
		
		override public function render() : void {
			super.render();
			
			if(_debugger){
				_debugger.x = _width - _debugger.width - 5;
				_debugger.y = _height - _debugger.height - 5;
			}
			
			/* Optionally resize your stuff here. You can use _width and _height.  */
		}
		
		override public function destroy() : void {
			if(_leftHandVerticalSwipe){
				_leftHandVerticalSwipe.dispatcher.removeEventListener(KinectGestureEvent.LEFT_SWIPE, _leftSwipeWithLeftHandOccured);
				_leftHandVerticalSwipe.dispatcher.removeEventListener(KinectGestureEvent.RIGHT_SWIPE, _rightSwipeWithLeftHandOccured);
			}
			
			if(_actionManager){
				_actionManager.clean();
			}
			super.destroy();
		}
	}
}
