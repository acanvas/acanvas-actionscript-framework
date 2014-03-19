package com.rockdot.library.util.blobtracker.data {
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
	import com.rockdot.library.util.tracker.data.BmdProvider;

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;

	
	
	/**
	 * bitmap data is drawn from camera
	 */
	public class KinectBmdProvider extends BmdProvider {
		
		protected static var cam:Camera;
		protected static var _video:Video;
		
		protected var _maskRect:Rectangle;
		protected var _maskMatrix : Matrix;
		private var _kinect : Kinect;
		private var _imgData : BitmapData;
		
		// ==================================================================
		public function KinectBmdProvider(bmd : BitmapData = null) {
			super(bmd);
			
			// check if cam already defined in other instance
			_kinect = Kinect.getDevice();

			var settings : KinectSettings = new KinectSettings();
			settings.depthEnabled = true;
			settings.depthResolution = CameraResolution.RESOLUTION_320_240;
//			settings.depthShowUserColors = true;

			_kinect.addEventListener(DeviceEvent.STARTED, _started);
			_kinect.addEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, _depthImageUpdateHandler);
			_kinect.start(settings);
			
			if(!_bmd){
				_bmd = new BitmapData(settings.depthResolution.x, settings.depthResolution.y, false, 0);
			}
			
			update();
		}
		
		override public function update():void {
			if(_imgData){
//				_bmd.draw( _imgData, null, null, null );
				_bmd.copyChannel(_imgData, _imgData.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			}
		}
		
		private function _started(event : DeviceEvent) : void {
			_kinect.removeEventListener(DeviceEvent.STARTED, _started);
		}
		
		private function _depthImageUpdateHandler(event : CameraImageEvent) : void {
			_imgData = event.imageData;
		}
		
		/**
		 * enables extraction of a sub-area of the webcam image
		 */
		public function set maskRect( r:Rectangle ):void	{
			_maskRect = new Rectangle(0,0,r.width,r.height);
			_maskMatrix = new Matrix(1,0,0,1, -r.x, -r.y);
			_bmd.dispose();
			_bmd = new BitmapData( r.width, r.height, false, 0);
		}
		public function get maskRect():Rectangle		{
			var r:Rectangle = _maskRect.clone();
			r.x = _maskMatrix.tx;
			r.y = _maskMatrix.ty;
			return r;
		}
	}
	
}