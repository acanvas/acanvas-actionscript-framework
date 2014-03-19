package com.rockdot.library.util.tracker.data {
	import flash.display.BitmapData;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	
	/**
	 * bitmap data is drawn from video
	 */
	public class VideoBmdProvider extends BmdProvider {
		
		private var video:Video;
		private var url:String;
		
		private var nc:NetConnection;
		private var ns:NetStream;
		
		//==================================================================
		public function VideoBmdProvider( url:String="testvideo1.flv" , bmd : BitmapData = null) {
			super(bmd);
			
			this.url = url;
			
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			nc.connect(null);
		}
		
		override public function update():void {
			if(_bmd!=null) _bmd.draw( video );
		}
		
		//==================================================================
		private function netStatusHandler( evt:NetStatusEvent ):void {
			if( evt.info.code != "NetConnection.Connect.Success" ) {
				throw new Error("Error loading video:\n"+evt.toString());
			}
			
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, nsHandler);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncHandler);
			ns.play( url );
			ns.soundTransform = new SoundTransform(0);
			
			video = new Video(320, 240);
			_bmd = new BitmapData(video.width, video.height, false, 0);
			video.attachNetStream( ns );
			
			update();
		}
		private function nsHandler( evt:NetStatusEvent ):void {
			if(evt.info.code=="NetStream.Play.Stop"){
				ns.seek(0);
			}
		}
		private function asyncHandler( evt:Event ):void {
		}
	}
	
}