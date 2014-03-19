/*Copyright (c) 2008 Alexander Milde (alexmilde@web.de)Permission is hereby granted, free of charge, to any person obtaining a copyof this software and associated documentation files (the "Software"), to dealin the Software without restriction, including without limitation the rightsto use, copy, modify, merge, publish, distribute, sublicense, and/or sellcopies of the Software, and to permit persons to whom the Software isfurnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included inall copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS ORIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THEAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHERLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS INTHE SOFTWARE.*/package de.jvm.next.hid.camera.observer.utils {	import flash.display.BitmapData;	import flash.geom.Point;	import flash.geom.Rectangle;	/**	 * Manipulate Bitmaps without using the flash filters	 * 	 * @author Alexander Milde	 */	public class BitmapManipulator 	{			/**		 * Reduce Color Algotithm.<br>		 * Idea: Mario Klingemann<br>		 * 		 * @param levels The level how much the bitmapcolor shall be reduced		 */			public static function reduceColors(bmd : BitmapData, rect : Rectangle, levels : int) : BitmapData		{				var vStepF : Number = 255 / levels;			var vStep : int = 0.5 + vStepF;			var v : int = 0;			var r: Array = new Array();			var g: Array = new Array();			var b: Array = new Array();						for (var i : int = 0; i < 256; i++) 			{				v = (i - i % vStep)*(255 / (256 - vStepF));				if(v>255)v=255;				r[i] = v << 16;				g[i] = v << 8;				b[i] = v;				}			bmd.paletteMap(bmd,rect, new Point(),r,g,b,null);								return bmd;			}	}}