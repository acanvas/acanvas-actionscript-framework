/*
Copyright (c) 2008 Alexander Milde (alexmilde@web.de)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package de.jvm.next.hid.camera.observer.mode 
{
	import de.jvm.next.hid.camera.observer.controller.Blob_Controller;
	import de.jvm.next.hid.camera.observer.utils.BitmapManipulator;
	import de.jvm.next.hid.camera.observer.utils.Color;
	import de.jvm.next.hid.camera.observer.video.DynamicVideo;

	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Detect a single object. Optimized for round black markers with a white
	 * outline and less motion. 
	 * 
	 * @author Alexander Milde
	 */
	 
	public class SingleBlob implements IVideoObserver
	{
		private var _camera : DynamicVideo;
		
		
		private var _brightness : Number = -63.5;
		private var _mat : Array = [0.6172,1.2188,0.164,0,_brightness,
									0.6172,1.2188,0.164,0,_brightness,
									0.6172,1.2188,0.164,0,_brightness,
									0,0,0,1,0];
									
									
		private var _fClr : ColorMatrixFilter = new ColorMatrixFilter(_mat);		
		private var _blr : BlurFilter = new BlurFilter(3,3);	

		private var _videoFrame : BitmapData;		
		private var _blobFrame : BitmapData;
		private var _rect : Rectangle = new Rectangle();
		private var _blob : Rectangle = new Rectangle();

		private var _blobFound : Boolean = false;	
		private var _markerLost : Boolean = false;
		private var _firstTime : Boolean = true;
		
//		private var _BlobPosition : Point = new Point(150, 80);
//		private var _BlobWidth : int = 40;
//		private var _BlobHeight : int = 40;
		private var _BlobFindTollerance : int = 5;

		private var _internX : int = 0;
		private var _internY : int = 0;
		private var _internZoomX : int = 0;
		private var _internZoomY : int = 0;

		private var _cachedX : int = 0;
		private var _cachedY : int = 0;
		private var _cachedZoomX : int = 0;
		private var _cachedZoomY : int = 0;

		// return value
		private var _x : int = 0;
		private var _y : int = 0;
		private var _zoomX : int = 0;
		private var _zoomY : int = 0;
		private var _initBlob : Rectangle;		

		public function SingleBlob(width : int = 160, fps : int = 30)
		{
			_camera = new DynamicVideo(width, fps);		
			_camera.applyFilterSet(_fClr, _blr);
			
			_videoFrame = new BitmapData(_camera.width, _camera.height, true, 0xff000000);
			_blobFrame = new BitmapData(_camera.width, _camera.height, true, 0xff000000);
			_rect = new Rectangle(0, 0, _camera.width, _camera.height);			

			_initBlob = new Rectangle(20,20,50,50);
		}

		
		public function analyse() : void
		{
			_videoFrame.draw(_camera.video);
			_videoFrame = BitmapManipulator.reduceColors(_videoFrame, _rect, 2);
			_blobFrame.draw(_videoFrame);
			
	
			// initial blob wasnt found
			if(_blobFound == false)
			{
				var _blobController : Blob_Controller;	
				// 
				// collect not everey blob
				var _blobMinHeight : Number = _camera.height / 10;
				var _blobMaxHeight : Number = _camera.height / 3; 
				var _blobMinWidth : Number = _camera.width / 10;
				var _blobMaxWidth : Number = _camera.width / 3; 
				
				_blobController = new Blob_Controller(_blobMinWidth, _blobMaxWidth, _blobMinHeight, _blobMaxHeight);
				_blobController.createBlobs(_blobFrame, 0xff000000);

				_blob = findInitialBlob(_blobController.blobArr, _initBlob, _BlobFindTollerance);
			}
			else if(_markerLost == true)
			{				
				_internX = _blob.x + (_blob.width /2);
				_internY = _blob.y + (_blob.height / 2);
				_internZoomX = _blob.width;
				_internZoomY = _blob.height; 

				// springe in erste schleife
				_markerLost = false;
				_firstTime = true;
				_blobFound = false;					
			}
			
			else if(_blobFound == true)
			{
				if(_firstTime == true)
				{
					_internX = _blob.x + (_blob.width /2);
					_internY = _blob.y + (_blob.height / 2);
					_internZoomX = _blob.width;
					_internZoomY = _blob.height; 					
					
					// save initial values
					_cachedX = _internX;
					_cachedY = _internY;
					_cachedZoomX = _internZoomX;
					_cachedZoomY = _internZoomY; 					
					
					_firstTime = false;
				}
				
				
				var ret : Array = new Array();
				ret = findObject(_videoFrame);				
				
			
				var pt1 : Point = new Point();
				pt1 = ret[0];
				
				
				// marker lost
				if(_internZoomX != 0)
				{
					if(Math.abs((_internZoomX + _internZoomY) - (ret[1] + ret[2])) > ((_internZoomX + _internZoomY)/2))
					{
						_markerLost = true;
					}
					else
					{
						_internX = pt1.x;
						_internY = pt1.y;
						_internZoomX = ret[1];
						_internZoomY = ret[2];
		
					}	
				}	
				else
				{
					//  firsttime found
						_internX = pt1.x;
						_internY = pt1.y;
						_internZoomX = ret[1];
						_internZoomY = ret[2];
				}
							

			}
			else
			{

			}
			
			// return values
			_x = _cachedX - _internX;
			_y = _cachedY - _internY;
			_zoomX = _cachedZoomX - _internZoomX;
			_zoomY = _cachedZoomY - _internZoomY; 				
			
		}

		
		private function findObject(videoFrame : BitmapData) : Array
		{
			var left : int;
			var right : int;
			var top : int;
			var bottom : int;
			
			var retPoint : Point = new Point();
			var ret : Array = new Array();
			
			left = findLeftEdge(_internX, _internY, videoFrame, 500);
			right = findRightEdge(_internX, _internY, videoFrame, 500);
			
			// mitteln dadurch mitte des kreises horizontal
			retPoint.x = Math.round((left + right)/2);
			top = findTopEdge(_internX, _internY, videoFrame, 500);
			bottom = findBottomEdge(_internX, _internY, videoFrame, 500);

			retPoint.y = Math.round((bottom + top) / 2);

			ret.push(retPoint);
			ret.push(right - left);
			ret.push(bottom - top);
			
			
			return ret;
		}
		
		
		public function findLeftEdge(x : int, y : int, videoFrame : BitmapData, maxX : int) : int
		{
			var edgeFound : Boolean = false;
			var i : int = 0;
			var clr : Color = new Color();
			
			while(!edgeFound && i < maxX)
			{
				
				clr.colorUint = videoFrame.getPixel32(x - i, y);
				
				if((clr.channelSum >= 200*3))
				{
						edgeFound = true;
				}
				else if(x - i == 0)
				{
					edgeFound = true;
				}				
				i++;
			}
			
			return (x -i + 2);			
		}
		
		
		public function findRightEdge(x : int, y : int, videoFrame : BitmapData, maxX : int) : int
		{
			var edgeFound : Boolean = false;
			var i : int = 0;
			var clr : Color = new Color();
			
			while(!edgeFound && i < maxX)
			{			
				clr.colorUint = videoFrame.getPixel32(x + i, y);	
				if((clr.channelSum >= 200*3))
				{
						edgeFound = true;
				}
				else if(x + i == _camera.width)
				{
					edgeFound = true;
				}				
				i++;
			}
			
			return (x + i - 2);			
		}
		
		
		public function findTopEdge(x : int, y : int, videoFrame : BitmapData, maxY : int) : int
		{
			var edgeFound : Boolean = false;
			var i : int = 0;
			var clr : Color = new Color();
			
			while(!edgeFound && i < maxY)
			{				
				clr.colorUint = videoFrame.getPixel32(x, y - i);				
				if((clr.channelSum >= 200*3))
				{
						edgeFound = true;
				}
				else if(y - i == 0)
				{
					edgeFound = true;
				}				
				i++;
			}
			
			return (y - i + 2);			
		}
		
		
		public function findBottomEdge(x : int, y : int, videoFrame : BitmapData, maxY : int) : int
		{
		var edgeFound : Boolean = false;
			var i : int = 0;
			var clr : Color = new Color();
			
			while(!edgeFound && i < maxY)
			{
				
				clr.colorUint = videoFrame.getPixel32(x, y + i);
				
				if((clr.channelSum >= 200*3))
				{
					edgeFound = true;
				}
				else if(y + i == _camera.height)
				{
					edgeFound = true;
				}
				
				i++;
			}
			
			return (y + i - 2);			
		}		
		
		
		private function findInitialBlob(blobs : Array, initBlob : Rectangle, Tollerance : int) : Rectangle
		{
			var max : int = blobs.length;
			var i : int = 0;
			var ret : Array = new Array();
			
			while(i < max)
			{
				if(Math.abs(blobs[i].x - initBlob.x) < Tollerance)
					if(Math.abs(blobs[i].y - initBlob.y) < Tollerance)
								ret.push(blobs[i]);
				i++;
			}
			
			// check if there's just one 
			if(ret.length == 1)
			{
				_blobFound = true;					
			}
			
			return ret[0];
		}


		//
		// CONFIG AND RETURN VALUES
		// ________________________________________________________________________________________________
				
		
		public function getVideoframe() : BitmapData
		{
			var tmp_bmd : BitmapData = new BitmapData(_camera.width, _camera.height, true, 0xffff0000);
			tmp_bmd.draw(_videoFrame);
			
			return tmp_bmd;			
		}
		
		public function increaseBrightness() : void
		{
			_brightness += 10;
			_mat = [0.6172,1.2188,0.164,0,_brightness,
					0.6172,1.2188,0.164,0,_brightness,
					0.6172,1.2188,0.164,0,_brightness,
					0,0,0,1,0];
			_fClr = new ColorMatrixFilter(_mat);		
			_camera.applyFilterSet(_fClr, _blr);
		}
		
		public function decreaseBrightness() : void
		{
			_brightness -= 10;
			_mat = [0.6172,1.2188,0.164,0,_brightness,
					0.6172,1.2188,0.164,0,_brightness,
					0.6172,1.2188,0.164,0,_brightness,
					0,0,0,1,0];
			_fClr = new ColorMatrixFilter(_mat);		
			_camera.applyFilterSet(_fClr, _blr);
		}
		
		
		
		
		public function get x() : int
		{
			return _x;
		}
		
		
		public function get y() : int
		{
			return _y;
		}
		
		
		public function get zoomX() : int
		{
			return _zoomX;
		}
		
		
		public function get zoomY() : int
		{
			return _zoomY;
		}
		
		
		public function get firstTime() : Boolean
		{
			return _firstTime;
		}
		
		
		public function get markerLost() : Boolean
		{
			return _markerLost;
		}
		
		
		public function get blobFound() : Boolean
		{
			return _blobFound;
		}
		
		
		public function set initBlob(initBlob : Rectangle) : void
		{
			_initBlob = initBlob;
		}						public function get brightness() : Number		{
			return _brightness;		}	
	}
}
