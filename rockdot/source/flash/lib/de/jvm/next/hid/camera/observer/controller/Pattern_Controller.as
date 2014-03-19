/*Copyright (c) 2008 Alexander Milde (alexmilde@web.de)Permission is hereby granted, free of charge, to any person obtaining a copyof this software and associated documentation files (the "Software"), to dealin the Software without restriction, including without limitation the rightsto use, copy, modify, merge, publish, distribute, sublicense, and/or sellcopies of the Software, and to permit persons to whom the Software isfurnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included inall copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS ORIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THEAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHERLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS INTHE SOFTWARE.*/package de.jvm.next.hid.camera.observer.controller {	import de.jvm.next.hid.camera.observer.utils.BitmapDataAnalyser;	import de.jvm.next.hid.camera.observer.utils.Pattern;	import de.jvm.next.hid.camera.observer.utils.SpecialMath;	import flash.display.BitmapData;	/**	 * Pattern_Controller holds an array with bitmapdata patterns	 * these patterns are snapshots from the videoframe which are compared to a	 * reference pattern. the controller returns the most similar pattern to the	 * referencepattern	 * 	 * @author Alexander Milde	 * 	 */	 	 	public class Pattern_Controller	{		private var _patternArray					: Array = new Array();		private var _patWidth				: Number;		private var _patHeight				: Number;		private var ptn 					: Pattern;// ______________________________________________________________________________________________________// 																								Construct//			public function Pattern_Controller(patternWidth : Number, patternHeight : Number)		{			_patWidth 	= patternWidth;			_patHeight 	= patternHeight;		}// ______________________________________________________________________________________________________// 																			Most Similar Pattern in Array//			/**		 * @return Pattern a bitmapdata with position and size		 */		 		public function mostSimilarPatternCoords(_refPattern : Pattern) : Pattern		{			// get the sum of active pixel for each pattern			//			var histogram : Array = new Array();						for (var i : int = 0;i < int(_patternArray.length); i++) 			{				histogram.push(BitmapDataAnalyser.getActivePixelCount(BitmapData(_patternArray[i].bmd), BitmapData(_refPattern.bmd)));			}								var tmpArr : Array = new Array();			tmpArr = SpecialMath.findMinimum(histogram);						return Pattern(_patternArray[tmpArr[0]]);			}// ______________________________________________________________________________________________________// 																 Add Analyse Patterns Around A Startpoint//			/**		 * Pushing snapshots of the videoframe in an array. the snapshots are taken around the last 		 * position of the tracked object.		 * <br><br>		 * WARNING: These patterns have to be analysed in a loop. So be careful, otherwise the performance		 * will be pretty bad.		 */		 		public function addAnalysePatterns(a :Number, s :Number, _vid :BitmapData, _rPa :Pattern) : void		{			_patternArray = new Array();			// startpoint			//			ptn = new Pattern(_rPa.x, _rPa.y, _patWidth, _patHeight, _vid);			_patternArray.push(ptn);						for (var k : int = 0; k < a; k++) 			{				for (var r : int = 0; r < a; r++) 				{					ptn = new Pattern(_rPa.x - (1+k)*s, _rPa.y - (1+r)*s, _patWidth, _patHeight, _vid);					_patternArray.push(ptn);					ptn = new Pattern(_rPa.x + (0+k)*s, _rPa.y - (1+r)*s, _patWidth, _patHeight, _vid);					_patternArray.push(ptn);					ptn = new Pattern(_rPa.x + (1+k)*s, _rPa.y - (1+r)*s, _patWidth, _patHeight, _vid);					_patternArray.push(ptn);					ptn = new Pattern(_rPa.x + (1+k)*s, _rPa.y + (0+r)*s, _patWidth, _patHeight, _vid);					_patternArray.push(ptn);					ptn = new Pattern(_rPa.x + (1+k)*s, _rPa.y + (1+r)*s, _patWidth, _patHeight, _vid);					_patternArray.push(ptn);					ptn = new Pattern(_rPa.x + (0+k)*s, _rPa.y + (1+r)*s, _patWidth, _patHeight, _vid);					_patternArray.push(ptn);					ptn = new Pattern(_rPa.x - (1+k)*s, _rPa.y + (1+r)*s, _patWidth, _patHeight, _vid);					_patternArray.push(ptn);					ptn = new Pattern(_rPa.x - (1+k)*s, _rPa.y + (0+r)*s, _patWidth, _patHeight, _vid);					_patternArray.push(ptn);				}						}		}				// ______________________________________________________________________________________________________// 																					   	  Getter / Setter//					public function pushPattern(ptn : Pattern) : void		{			_patternArray.push(ptn);		}				public function get patternArr() : Array		{			return _patternArray;		}		//////			}}