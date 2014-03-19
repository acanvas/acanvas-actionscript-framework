package com.jvm.view {
	import com.jvm.geom.Dimension;

	import flash.display.BitmapData;
	import flash.geom.Matrix;

	/**
	 * Copyright (c) 2009, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author	Thomas Eckhardt
	 * @since	29.09.2009 14:22:31
	 * 
	 * ACHTUNG!!! Ich würde sagen die Klasse funktuioniert, ist aber noch nicht ausgiebig genug getestet worden.
	 */

	public class BitmapCrop 
	{
		static public const FULL_FILLED : String = "full_filled";		static public const FULL_IMAGE : String = "full_image";
		
		/**
		 * Skaliert und beschneidet ein Bild auf die gewünschte Größe.
		 * 
		 * @param bmp			BitmapData welches angepasst werden soll
		 * @param targetWidth	Die gewünschte bzw. maximale Breite
		 * @param targetHeight	Die gewünschte bzw. maximale Höhe
		 * @param allowScaleUp	Soll das Bild auch hochskaliert werden (falls es zu klein wäre)
		 * @param fillType		Die Art der Skalierung/des Beschnitts
		 * 
		 * @return BitmapData
		 */
		static public function crop ( bmp : BitmapData, targetWidth : Number, targetHeight : Number, allowScaleUp : Boolean = false, fillType : String = null ) : BitmapData
		{
			var dx : Number = targetWidth / bmp.width;
			var dy : Number = targetHeight / bmp.height;
			var scale : Number = 1;
			
			// Calculate scaling
			switch ( fillType )
			{
				case FULL_IMAGE:
					// Skaliert ein Bild so, dass es zur Gänze in der geforderten Größe dargestellt wird. Die angegeben Dimensionen
					// targetWidth und targetHeight definieren dabei die maximalen Ausmaße des späteren Bildes. 
					scale = Math.min( dx, dy );
					break;
				
				default:
					// FULL_FILLED
					// Skaliert ein Bild so, dass die angegeben Dimensionen targetWidth und targetHeight vollständig ausgefüllt sind.
					// Unter Umständen werden Teile des Bildes nach dem Skalieren abgeschnitten.
					scale = Math.max( dx, dy );
			}
			
			if ( !allowScaleUp && scale > 1 )
				scale = 1;
				
			// Calculate image dimensions
			var imageDimension : Dimension = new Dimension( Math.min( bmp.width * scale, targetWidth ), Math.min( bmp.height * scale, targetHeight ) );
			
			// Drawing
			var m : Matrix = new Matrix( scale, 0, 0, scale, ( imageDimension.width - bmp.width * scale ) * .5, ( imageDimension.height - bmp.height * scale ) * .5 );			var r : BitmapData = new BitmapData( imageDimension.width, imageDimension.height );
			r.draw( bmp, m, null, null, null, true );
			return r;
		}
		
		
	}
}
