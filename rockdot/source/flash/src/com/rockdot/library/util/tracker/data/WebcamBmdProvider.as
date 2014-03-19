package com.rockdot.library.util.tracker.data {
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	
	
	/**
	 * bitmap data is drawn from camera
	 */
	public class WebcamBmdProvider extends BmdProvider {
		
		protected static var cam:Camera;
		protected static var _video:Video;
		
		protected var _maskRect:Rectangle;
		protected var _maskMatrix:Matrix;
		
		//==================================================================
		public function WebcamBmdProvider(bmd : BitmapData = null) {
			super(bmd);
			
			// check if cam already defined in other instance
			if(cam == null) {
				cam = Camera.getCamera();
			
				if(cam == null) {
					throw new Error("No camera found!");
				}
				
				cam.setMode(320, 240, cam.fps, false);
				
				_video = new Video(cam.width, cam.height);
				_video.attachCamera( cam );
			}
			if(!_bmd){
				_bmd = new BitmapData(_video.width, _video.height, false, 0);
			}
			
			update();
		}
		
		override public function update():void {
			_bmd.draw( _video, _maskMatrix, null, null );
		}
		
		/**
		 * enables extraction of a sub-area of the webcam image
		 */
		public function set maskRect( r:Rectangle ):void	{
			_maskRect = new Rectangle(0,0,r.width,r.height);
			_maskMatrix = new Matrix(1,0,0,1, -r.x, -r.y);
			_maskMatrix.scale(-1, 1);
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