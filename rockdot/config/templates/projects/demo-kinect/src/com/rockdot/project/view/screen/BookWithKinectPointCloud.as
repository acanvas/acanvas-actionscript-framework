package com.rockdot.project.view.screen {
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.data.PointCloudRegion;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.PointCloudEvent;
	import com.as3nui.nativeExtensions.air.kinect.examples.pointCloud.PointCloudRenderer;
	import com.rockdot.core.model.RockdotConstants;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class BookWithKinectPointCloud extends Book {
		private var _kinect : Kinect;
		private var _region1 : PointCloudRegion;
		private var _region2 : PointCloudRegion;
		private var _renderer : PointCloudRenderer;
		private var _boxTimers:Vector.<int>;
		private var MAX_TIME_BETWEEN_REGIONS : Number;
		private var MIN_TIME_BETWEEN_FLICKS : Number;
		
		private var _flickInverted : Boolean = false;

		public function BookWithKinectPointCloud(id : String) {
			super(id);
			_fireInit = false;
		}

		override public function init(data : * = null) : void {
			super.init(data);
			
			
			MAX_TIME_BETWEEN_REGIONS = parseInt(getProperty("max.time.between.regions"));
			MIN_TIME_BETWEEN_FLICKS  = parseInt(getProperty("min.time.between.flicks"));

			if (Kinect.isSupported()) {
				_initKinect();
			}

			_didInit();
		}

		private function _initKinect() : void {
			_kinect = Kinect.getDevice();

			var settings : KinectSettings = new KinectSettings();
			settings.pointCloudEnabled = true;
			settings.pointCloudResolution = CameraResolution.RESOLUTION_320_240;
			settings.pointCloudDensity = 4;

			//prepare inactivity timers for each box (left, right, both)
			_boxTimers = Vector.<int>([0, 0]);
			
			_kinect.addEventListener(DeviceEvent.STARTED, _started);
			_kinect.start(settings);

			_region1 = new PointCloudRegion(  parseInt(getProperty("leftbox.x"))
											, parseInt(getProperty("leftbox.y"))
											, parseInt(getProperty("leftbox.z"))
											, parseInt(getProperty("leftbox.w"))
											, parseInt(getProperty("leftbox.h"))
											, parseInt(getProperty("leftbox.d")));

			_region2 = new PointCloudRegion(  parseInt(getProperty("rightbox.x"))
											, parseInt(getProperty("rightbox.y"))
											, parseInt(getProperty("rightbox.z"))
											, parseInt(getProperty("rightbox.w"))
											, parseInt(getProperty("rightbox.h"))
											, parseInt(getProperty("rightbox.d")));

			var pointCloudRegions : Vector.<PointCloudRegion> = Vector.<PointCloudRegion>([_region1, _region2]);
			_kinect.setPointCloudRegions(pointCloudRegions);

			if(RockdotConstants.DEBUG || getProperty("renderer.show") == "true"){
				_renderer = new PointCloudRenderer(settings);
				_renderer.visible = false;
				addChild(_renderer);
				_renderer.updateRegions(pointCloudRegions);
			}
		}

		private function _started(event : DeviceEvent) : void {
			_kinect.removeEventListener(DeviceEvent.STARTED, _started);
			_log.debug("Kinect started.");
			_kinect.addEventListener(PointCloudEvent.POINT_CLOUD_UPDATE, pointCloudUpdateHandler);
		}

		protected function pointCloudUpdateHandler(event:PointCloudEvent):void
		{
			if(_renderer){
				_renderer.updatePoints(event.pointCloudData);
			}
			
			if(_region1.numPoints>0){
				_log.debug("points in region 1: " + _region1.numPoints);
			}
			if(_region2.numPoints>0){
				_log.debug("points in region 2" + _region2.numPoints);
			}
			
			//box1activeTimer--
			for (var i : int = 0; i < _boxTimers.length; i++) {
				_boxTimers[i]--;
			}
			
			//if a flick action just happened, cancel
			if(_boxTimers[2] > 0){
				return;
			}
			//if no flick action for a minute: flick page
			else if(_boxTimers[2] < - (stage.frameRate * 60) ){	
				_book.nextPage();
				_boxTimers[2] = 0;
			}
			
			if(_region1.numPoints > 10){
				//was the other box active recently?
				if (_boxTimers[1] > 0){ //yes
					
					//reset all
					_boxTimers[0] = 0;
					_boxTimers[1] = 0;
					
					//set 'both' box timer
					_boxTimers[2] = MIN_TIME_BETWEEN_FLICKS;
					
					//goto next page
					if(_flickInverted){
						_book.prevPage();
					}
					else{
						_book.nextPage();
					}
					
					_log.debug("next");
				}
				else{ //no
					//set "active" timer for this box
					_boxTimers[0] = MAX_TIME_BETWEEN_REGIONS;
				}
			}
			else if(_region2.numPoints > 10){
				
				//was the other box active recently?
				if (_boxTimers[0] > 0){ //yes
					
					//reset all
					_boxTimers[0] = 0;
					_boxTimers[1] = 0;

					//set 'both' box timer
					_boxTimers[2] = MIN_TIME_BETWEEN_FLICKS;
					
					//goto previous page
					if(_flickInverted){
						_book.nextPage();
					}
					else{
						_book.prevPage();
					}
					
					_log.debug("prev");
				}
				else{ //no
					//set "active" timer for this box
					_boxTimers[1] = MAX_TIME_BETWEEN_REGIONS;
				}
			}
			
				
			
			
		}


		override public function render() : void {
			super.render();

			if (_renderer) {
//				_renderer.width = _width;
//				_renderer.height = _height;
				_renderer.x = _width - _renderer.width - 5;
				_renderer.y = _height - _renderer.height - 5;
			}

			/* Optionally resize your stuff here. You can use _width and _height.  */
		}
		override public function destroy() : void {
			_kinect.removeEventListener(PointCloudEvent.POINT_CLOUD_UPDATE, pointCloudUpdateHandler);
			_kinect.stop();
			
			super.destroy();
		}
	}
}
