package jp.shichiseki.exif {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	public class ExifUtils {
		public static const PORTRAIT : int = 6;
		public static const PORTRAIT_REVERSE : int = 8;
		public static const LANDSCAPE : int = 1;
		public static const LANDSCAPE_REVERSE : int = 3;

		/**
		 * function figures out the rotation needed so the image
		 * appears in the right view for the user
		 * 
		 * 
		 * @param ifd attribute in exif belonging to image
		 * @return the angle to rotate an image based on ifd information 
		 * @see http://bit.ly/j70E7T
		 */
		public static function getEyeOrientedAngle(set : IFDSet) : int {
			var angle : int = 0;

			if ( set.primary[ "Orientation" ] ) {
				switch( set.primary[ "Orientation" ] ) {
					case LANDSCAPE:
						angle = 0;
						break;
					case LANDSCAPE_REVERSE:
						angle = 180;
						break;
					case PORTRAIT:
						angle = 90;
						break;
					case PORTRAIT_REVERSE:
						angle = -90;
						break;
				}
			}

			return angle;
		}
		
		public static function getEyeOrientedBitmap(sourceBitmap : Bitmap, exifProvider : IDataInput, scale : Number = 1) : Bitmap {
			var eb : ByteArray = new ByteArray();

			//read EXIF
			var readSize : int = exifProvider.bytesAvailable < 65536 ? exifProvider.bytesAvailable : 65536;
			exifProvider.readBytes(eb, 0, readSize);

			//get transformed Bitmap
			var exifInfo : ExifInfo = new ExifInfo(eb);
			var bmp : Bitmap; 
			if (exifInfo.ifds) {
				bmp = _getEyeOrientedBitmapInternal(sourceBitmap, exifInfo.ifds, scale);
				sourceBitmap.bitmapData.dispose();
			}
			else if (scale != 1) {
				var m : Matrix = new Matrix();
				m.scale(scale, scale);
				
				var bitmapData : BitmapData = new BitmapData(sourceBitmap.width * scale, sourceBitmap.height * scale, true);
				bitmapData.draw(sourceBitmap, m);
				
				bmp = new Bitmap(bitmapData, PixelSnapping.ALWAYS, true);
				sourceBitmap.bitmapData.dispose();
			}
			else{
				bmp = sourceBitmap;
			}
			
			eb.clear();
			return bmp;
		
		}

		/**
		 * creates a bitmap appealing to the eye, so that based on provided original bitmap and its IFDSet
		 * it's possible to track the orientation and create a transformed bitmap copied from the original.
		 * 
		 * @see http://www.psyked.co.uk/actionscript/rotating-bitmapdata.htm">rotating-bitmapdata.htm
		 * @see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/geom/Matrix.html
		 * 
		 * @param bitmap retrieved after selecting an image from CameraRoll
		 * @param set retrieved after loading the Exif data from selected image
		 * @return a new bitmap in the right angle and same dimensions as the original.
		 * 
		 */
		private static function _getEyeOrientedBitmapInternal(bitmap : Bitmap, set : IFDSet, scale : Number = 1) : Bitmap {
			var m : Matrix = new Matrix();
			var orientation : int = set.primary[ "Orientation" ];
			var bitmapData : BitmapData;

			if ( orientation == LANDSCAPE || orientation == LANDSCAPE_REVERSE ) {
				bitmapData = new BitmapData(bitmap.width*scale, bitmap.height*scale, true);
			} else {
				bitmapData = new BitmapData(bitmap.height*scale, bitmap.width*scale, true);
			}
			
			m.scale(scale, scale);
			m.rotate(getEyeOrientedAngle(set) * ( Math.PI / 180 ));

			if ( orientation == PORTRAIT_REVERSE ) {
				m.translate(0, bitmap.width);
			} else if ( orientation == PORTRAIT ) {
				m.translate(bitmap.height, 0);
			} else if ( orientation == LANDSCAPE_REVERSE ) {
				m.translate(bitmap.width, bitmap.height);
			}

			bitmapData.draw(bitmap, m);

			return new Bitmap(bitmapData);
		}
	}
}