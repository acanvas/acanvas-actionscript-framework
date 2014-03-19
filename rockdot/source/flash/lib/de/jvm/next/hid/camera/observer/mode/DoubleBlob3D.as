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
	import de.jvm.next.hid.camera.observer.video.DynamicVideo;

	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * DoubleBlob3D tracks two blobs of similar size and calulates position, angle 
	 * and distance between theese two objects. its goal is to simulate headtracking 
	 * but it can also be used to stear a car or something similar. 
	 * 
	 * @author Alexander Milde
	 * 
	 */
	 
	public class DoubleBlob3D 
	{
		private var _camera : DynamicVideo;
		// creates blobs and stores them
		private var _blobController : Blob_Controller;
		// contrast = 50, saturation = -100, brightness: 0,
		// standard configuration brightness can be adjustet by user
		private var _brightness : Number = -63.5;
		private var _mat : Array = [0.6172,1.2188,0.164,0,_brightness,
									0.6172,1.2188,0.164,0,_brightness,
									0.6172,1.2188,0.164,0,_brightness,
									0,0,0,1,0];
		
		private var _fClr : ColorMatrixFilter = new ColorMatrixFilter(_mat);		
		private var _blr : BlurFilter = new BlurFilter(3, 3);	
		private var _videoFrame : BitmapData;		
		private var _blobFrame : BitmapData;
		private var _rect : Rectangle = new Rectangle();
		private var _blobMaxHeight : int;
		private var _blobMinWidth : int;
		private var _blobMinHeight : int;
		private var _blobMaxWidth : int;
		private var _eyesFound : Boolean = false;
		private var _selectedBlobs : Array = new Array();
		//
		// return values
		private var _referencePoint : Point = new Point();
		private var _referenceZoom : Number = 0;
		private var _referenceRotation : Number = 0;
		private var _referencePointSet : Boolean = false;
		//
		private var _x : Number;
		private var _y : Number;
		private var _rotation : Number = 0;
		private var _zoom : Number;
		// vars for initial eyefinding
		//
		private var _findRect : Rectangle = new Rectangle(50, 50, 50, 50);
		private var _yTol : int = 3;
		// vars for eyes
		private var _initialEye1 : Rectangle;
		private var _initialEye2 : Rectangle;
		private var _currentEye1 : Rectangle;
		private var _currentEye2 : Rectangle;
		// je nach videogröße machen
		private var _reiinitializeEyes : Boolean;
		// rechteck in dem die blobdetection gemahct wird
		private var _searchRect : Rectangle;
		private var _reset : Boolean;

		private var _debugMode : Boolean = true;
		
		public function DoubleBlob3D(width : int = 160, fps : int = 30)
		{
			//
			// setting up the camera with proper quality
			// and filters
			_camera = new DynamicVideo(width, fps);		
			_camera.applyFilterSet(_fClr, _blr);
			
			_videoFrame = new BitmapData(_camera.width, _camera.height, true, 0xff000000);
			_blobFrame = new BitmapData(_camera.width, _camera.height, true, 0xff000000);
			_rect = new Rectangle(0, 0, _camera.width, _camera.height);
		
		
			// 
			// collect not everey blob
			_blobMinHeight = _camera.height / 60;
			_blobMaxHeight = _camera.height / 4; 
			_blobMinWidth = _camera.width / 60;
			_blobMaxWidth = _camera.width / 4; 
			
			_blobController = new Blob_Controller(_blobMinWidth, _blobMaxWidth, _blobMinHeight, _blobMaxHeight);
			
			_findRect = new Rectangle(150, 100, 100, 40);	
			_searchRect = new Rectangle(0, 0, _camera.width, _camera.height);
		}

		
		/**
		 * The analyse loop has two states. the eyes are found and active or not. when the eyes
		 * aren't active, all returnvalues are set to zero. the user has to reiinitialise them by moving
		 * his marker in a predefined box.
		 */
		 
		public function analyse() : void
		{
			_videoFrame.draw(_camera.video);
			_videoFrame = BitmapManipulator.reduceColors(_videoFrame, _rect, 2);
			_blobFrame.draw(_videoFrame);
			
			
			if(_eyesFound)
			{
				// nur blobs in bestimmem analysieren
				var _tmp : BitmapData = new BitmapData(_camera.width, _camera.height, true, 0xffff0000);
				_tmp.copyPixels(_videoFrame, new Rectangle(_searchRect.x, _searchRect.y, _searchRect.width, _searchRect.height), new Point(_searchRect.x, _searchRect.y));
				_blobFrame = _tmp;
				_videoFrame.draw(_tmp);
			}

			_blobController.createBlobs(_blobFrame, 0xff000000);
							
	
			if(_eyesFound == false)
			{
				// reset the selected blobs array
				_selectedBlobs = new Array();
				var tmpArr : Array = new Array();

				_reiinitializeEyes = false;
				tmpArr = findInitalEyes(_blobController.blobArr, _findRect, _yTol);
				
				if(_eyesFound)
				{
					// set the referenceEyes and the current eyes
					_initialEye1 = tmpArr[0];
					_initialEye2 = tmpArr[1];
					
					_currentEye1 = tmpArr[0];
					_currentEye2 = tmpArr[1];

					_selectedBlobs = tmpArr;			
					_searchRect = calculateSearchArea(_currentEye1, _currentEye2);
					
					setReferenceValues(_selectedBlobs);						
				}
			}
			
			else
			{
				// delete borderblobs
				_selectedBlobs = _blobController.blobArr;
				if(_selectedBlobs.length == 2)
				{		
					_selectedBlobs.push(_blobController.blobArr[0]);
					_selectedBlobs.push(_blobController.blobArr[1]);	
					_currentEye1 = _selectedBlobs[0];
					_currentEye2 = _selectedBlobs[1];
					_searchRect = calculateSearchArea(_selectedBlobs[0], _selectedBlobs[1]);		
				
				}
				else if(_selectedBlobs.length > 2)
				{
					_selectedBlobs = deleteBorderBlobs(_selectedBlobs);

					if(_selectedBlobs.length == 2)
					{
						_searchRect = calculateSearchArea(_selectedBlobs[0], _selectedBlobs[1]);	
						_currentEye1 = _selectedBlobs[0];
						_currentEye2 = _selectedBlobs[1];
					
					}
					else if(_selectedBlobs.length < 2)
					{					
						_reset = true;	
					}
					else
					{
						_reset = true;				
					}
				}
				else
				{
					_reset = true;
				}
				
				if(_reset == false)
				{
					// create the blobs
					//
					var tmpWidth : int = Math.round((_currentEye1.width + _currentEye2.width)/2);
					var tmpHeight : int = Math.round((_currentEye1.height + _currentEye2.height) / 2);
						
					_blobController.updateRangeParams(tmpWidth / 1.5, tmpWidth * 1.5, tmpHeight / 1.5, tmpHeight * 1.5);
					setReturnValues(_selectedBlobs);	
				
				}
	
			}

			if(_reset)
			{
				reset();
			}

			if(_debugMode)
			{
				drawAllBlobs(_selectedBlobs);
			}
					
		}
		

		/**
		 * resets the trackin after the marker was lost.
		 */		
		private function reset() : void
		{
			_searchRect = new Rectangle(0, 0, _camera.width, _camera.height);
			_x = 0;
			_y = 0;
			_rotation = 0;
			_zoom = 0; 
			_eyesFound = false;
			_blobController.updateRangeParams(_blobMinWidth, _blobMaxWidth, _blobMinHeight, _blobMaxHeight);
			_reset = false;
		}
		

		/**
		 * Blobs on the searchareaborder are ignored
		 */
		private function deleteBorderBlobs(blobs : Array) : Array
		{
			var i : int = 0;
			var max : int = blobs.length;
			var ret : Array = new Array();
			
			while(i < max)
			{
				// liegt nicht links an
				if(blobs[i].x > _searchRect.x + 2)
				{
					// liegt nicht oben an
					if(blobs[i].y > _searchRect.y + 2)
					{
						// liegt nicht rechts an
						if(blobs[i].x + blobs[i].width < _searchRect.x + _searchRect.width - 2)
						{
							//liegt nicht unten an
							if(blobs[i].y + blobs[i].height < _searchRect.y + _searchRect.height - 2)
							{
								ret.push(blobs[i]);
							}	
						}	
					}
				}
				i++;	
			}
			
			return ret;
		}


		/**
		 * Calculates the area in which the blobdetection is done. Reduces failures when just a 
		 * part of the image is used to detect blobs 
		 */		
		private function calculateSearchArea(_currentEye1 : Rectangle, _currentEye2 : Rectangle) : Rectangle
		{
			var ret : Rectangle = new Rectangle();
			var shiftX : int;
			var shiftY : int;
						
			var tmpLeftX : Number = Math.min(_currentEye1.x, _currentEye2.x);
			var tmpLeftY : Number = Math.min(_currentEye1.y, _currentEye2.y);			
			
			var width : Number = Math.abs(_currentEye1.x - _currentEye2.x);
			width += (_currentEye1.width + _currentEye2.width) / 2;
			width = Math.round(width);
			
			var height : Number = Math.abs((_currentEye1.y - _currentEye2.y)/2);
			height += (_currentEye1.height + _currentEye2.height) / 2;
			height = Math.round(height);
			
			
			shiftX = Math.round(width / 3);
			shiftY = Math.round(height / 1.5);
			
			
			ret.x = Math.round(tmpLeftX - shiftX);
			ret.y = Math.round(tmpLeftY - shiftY);
			
			
			ret.width = width + (shiftX * 2);
			ret.height = height + (shiftY * 2);
			
			return ret;
		}

		

		/**
		 * Searches for the two blobs in a given range and size
		 */
		private function findInitalEyes(blobArr : Array, findRect : Rectangle, yTol : int) : Array
		{
			var max : int = blobArr.length;
			var i : int = 0;
			var ret : Array = new Array();
			
			while(i < max)
			{
				// is in rect
				if((blobArr[i].x) > findRect.x && blobArr[i].x < (findRect.x + findRect.width - blobArr[i].width))
				{
					// is in rect
					if(blobArr[i].y > findRect.y && (blobArr[i].y < (findRect.y + findRect.height - blobArr[i].height)))
					{
						ret.push(blobArr[i]);
					}
				}
				i++;
			}

			// check if there's just one pair
			if(ret.length == 2)
			{
				// check if the y coords are similar
				//
				if((Math.abs(ret[0].y - ret[1].y)) < yTol)
				{
					// the initial eyes were found
					_eyesFound = true;
				}		
			}
			
			return ret;
		}


		/**
		 * Sets the reference values when the blobs are initially found
		 */
		private function setReferenceValues(_activeBlobs : Array) : void
		{
			var tmpX : Number = (_activeBlobs[0].x + _activeBlobs[0].x + _activeBlobs[0].width + _activeBlobs[1].x + _activeBlobs[1].x + _activeBlobs[1].width) / 4;
			var tmpY : Number = (_activeBlobs[0].y + _activeBlobs[0].y + _activeBlobs[0].height + _activeBlobs[1].y + _activeBlobs[1].y + _activeBlobs[1].height) / 4;
			//
			// set x,y
			_referencePoint.x = tmpX;
			_referencePoint.y = tmpY;
			
			//
			// set rotation in degrees
			_referenceRotation = Math.atan2(_activeBlobs[1].y - _activeBlobs[0].y, _activeBlobs[1].x - _activeBlobs[0].x) * 180 / Math.PI;
			if(_referenceRotation > 90)
			{
				_referenceRotation = 180 - _referenceRotation;
				_referenceRotation *= -1;
			}
			
			//
			// set the zoom
			_referenceZoom = Math.abs(_activeBlobs[0].x - _activeBlobs[1].x); 
			_referencePointSet = true;
		}

		
		/**
		 * Calculates all return values
		 */
		private function setReturnValues(_activeBlobs : Array) : void
		{
			var tmpX : Number = (_activeBlobs[0].x + _activeBlobs[0].x + _activeBlobs[0].width + _activeBlobs[1].x + _activeBlobs[1].x + _activeBlobs[1].width) / 4;
			var tmpY : Number = (_activeBlobs[0].y + _activeBlobs[0].y + _activeBlobs[0].height + _activeBlobs[1].y + _activeBlobs[1].y + _activeBlobs[1].height) / 4;
			//
			// set x,y
			_x = _referencePoint.x - tmpX;
			_y = _referencePoint.y - tmpY;
			
			//
			// set rotation in degrees
			_rotation = Math.atan2(_activeBlobs[1].y - _activeBlobs[0].y, _activeBlobs[1].x - _activeBlobs[0].x) * 180 / Math.PI;
			if(_rotation > 90)
			{
				_rotation = 180 - _rotation;
				_rotation *= -1;
			}
			_rotation -= _referenceRotation;
			
			//
			// set the zoom
			_zoom = Math.abs(_activeBlobs[0].x - _activeBlobs[1].x) - _referenceZoom; 
		}

		
		/**
		 * Testdraws all blobs
		 */
		private function drawAllBlobs(blobArr : Array) : void
		{

			var arr : Array = new Array();
			arr.push(0xff336699);
			arr.push(0xffff00ff);
			arr.push(0xff0000ff);
			arr.push(0xffff0000);
			arr.push(0xff00ffff);
			
			var tmp : int = 0;
			
			var i : int = 0;
			
			while(i < blobArr.length) 
			{
				tmp = 0;
				var rand : int = Math.round((Math.random() * blobArr.length) - 1);
				if(rand < 0)
				rand = 0;
				
				var j : int = blobArr[i].x;
				while( j < blobArr[i].x + blobArr[i].width) 
				{
					var k : int = blobArr[i].y;
					while(k < blobArr[i].y + blobArr[i].height) 
					{					
						_videoFrame.setPixel32(j, k, arr[rand]);	
						k++;
					}	
					j++;
				}
				
				i++;		
			}
		}
		
		
		//
		// CONFIG AND RETURN VALUES
		// ________________________________________________________________________________________________
		
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

		
		public function getVideoframe() : BitmapData
		{
			var tmp_bmd : BitmapData = new BitmapData(_camera.width, _camera.height, true, 0xffff0000);
			tmp_bmd.draw(_videoFrame);
			return tmp_bmd;			
		}

		
		public function get eyesFound() : Boolean
		{
			return _eyesFound;
		}

		
		public function get referencePointSet() : Boolean
		{
			return _referencePointSet;
		}

		
		public function get x() : Number
		{
			return _x;
		}

		
		public function get y() : Number
		{
			return _y;
		}

		
		public function get rotation() : Number
		{
			return _rotation;
		}

		
		public function get zoom() : Number
		{
			return _zoom;
		}
		
		
		public function set findRect(findRect : Rectangle) : void
		{
			_findRect = findRect;
		}
		
		
		public function get debugMode() : Boolean
		{
			return _debugMode;
		}
		
		
		public function set debugMode(debugMode : Boolean) : void
		{
			_debugMode = debugMode;
		}
		
		
		public function get findRect() : Rectangle
		{
			return _findRect;
		}
	}
}
	