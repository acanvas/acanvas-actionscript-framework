/*
 * Copyright 2007-2008 (c) Benjamin Bojko, bbojko.de
 *
 * This Code may be used under the conditions of the Creative
 * Commons Public License "Attribution-NonCommercial 3.0 Unported"
 * and thereby may be used, modified and extended for non
 * commercial purposes.
 * 
 * More information at:
 * http://creativecommons.org/licenses/by-nc/3.0/legalcode
 * 
 */

package com.rockdot.library.util.tracker.histogramm {
	import flash.display.BitmapData;
	
	
	public class AbstractHistogramm {
		
		//==================================================================
		protected var _bmd:BitmapData;
		protected var _values:Array;
		
		protected var _maxValue:int=0;
		protected var _maxIndex:int=0;
		protected var _median:int=127;
		
		protected var _ommitMax:Boolean=false;
		
		protected var maxChanged:Boolean=false;
		protected var medianChanged:Boolean=false;
		
		//==================================================================
		/**
		 * 
		 * @param	ommitMax	returns 2nd max instead of 1st
		 */
		public function AbstractHistogramm( bmd:BitmapData, resolution:int=256, ommitMax:Boolean=false ) {
			_bmd = bmd;
			_ommitMax = ommitMax;
			_values = new Array(resolution);
			reset();
		}
		//==================================================================
		public function update():void {
			reset();
			
			updateValues();
			
			maxChanged = true;
			medianChanged = true;
		}
		//==================================================================
		public function reset():void {
			for(var i:int=0; i<_values.length; i++) {
				_values[i] = 0;
			}
		}
		//==================================================================
		public function getValue( index:int ):int {
			if(index>0 && index<_values.length) return _values[index];
			else return -1;
		}
		
		//==================================================================
		//==================================================================
		public function get bmd():BitmapData {	return _bmd;		}
		public function get values():Array 	{	return _values;		}
		public function get resolution():int {	return _values.length;	}
		public function get ommitMax():Boolean	{	return _ommitMax;	}
		
		public function get maxValue():int {
			if(maxChanged) updateMax();
			return _maxValue;
		}
		public function get maxIndex():int {
			if(maxChanged) updateMax();
			return _maxIndex;
		}
		public function get median():int {
			if(medianChanged) updateMedian();
			return _median;
		}
		
		public function set bmd( b:BitmapData ):void {	_bmd=b;		}
		public function set ommitMax( b:Boolean ):void	{	_ommitMax = b;  }
		
		//==================================================================
		public function toString():String {
			return "[ AbstractHistogramm ]";
		}
		
		//==================================================================
		/**
		 * 
		 */
		protected function updateValues():void {
			trace(this+" updateValues() must be overridden");
		}
		
		/**
		 * 
		 */
		protected function updateMax():void {
			maxChanged = false;
			
			_maxValue = 0;
			_maxIndex = 0;
			
			for(var i:int=0; i<_values.length; i++) {
				if(_values[i] > _maxValue) {
					_maxValue = _values[i];
					_maxIndex = i;
				}
			}
			
			if(!ommitMax) return;
			
			// find 2nd max value
			var _maxValue2:int = 0;
			var _maxIndex2:int = 0;
			
			for(var j:int=0; j<_values.length; j++) {
				if(_values[j]>_maxValue2 && j!=_maxIndex) {
					_maxValue2 = _values[j];
					_maxIndex2 = j;
				}
			}
			
			_maxValue = _maxValue2;
			_maxIndex = _maxIndex2;
		}
		
		/**
		 * 
		 */
		protected function updateMedian():void {
			medianChanged = false;
			
			var sum:int=0;
			var halfLength:int = _bmd.width*bmd.height >> 1; // .../2
			
			for(var i:int=0; i<_values.length; i++) {
				sum += _values[i];
				if(sum >= halfLength) {
					_median = i;
					return;
				}
			}
			_median = -1;
		}
	}
}