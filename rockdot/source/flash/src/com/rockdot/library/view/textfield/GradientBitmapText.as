package com.rockdot.library.view.textfield {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;

	/**
	 * Copyright (c) 2010, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author	Thomas Eckhardt
	 * @since	05.01.2010 10:19:43
	 */

	public class GradientBitmapText extends Bitmap 
	{

		public function GradientBitmapText ( textField : TextField, colors : Array )
		{
			textField.cacheAsBitmap = true;
			var temp : Sprite = new Sprite( );
			var fill : Shape = new Shape( );
			var gBox : Matrix = new Matrix( );
			gBox.createGradientBox( textField.textWidth + 4, textField.height + 15, Math.PI * .1 );
			var fillGraphics : Graphics = fill.graphics;
			fillGraphics.beginGradientFill( GradientType.LINEAR, colors, [ 1, 1 ], [ 0, 255 ], gBox );
			fillGraphics.drawRect( 0, 0, textField.textWidth + 4, textField.height + 15 );
			fillGraphics.endFill( );
			fill.cacheAsBitmap = true;
			fill.mask = textField;
			
			temp.addChild( fill );
			temp.addChild( textField );
			
			this.bitmapData = new BitmapData( textField.textWidth + 4, temp.height, false, 0x0 );
			this.bitmapData.draw( temp );
		}

	}
}
