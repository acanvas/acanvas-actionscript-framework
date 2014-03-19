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

/**
 *abstract tracker class with basic tracking members
 * 
 * @author Benjamin Bojko
 * @version 0.1
 */

package com.rockdot.library.util.tracker {
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	
	public class AbstractTracker extends EventDispatcher {
		
		//==================================================================
		public static const DEBUG:Boolean = true;
		
		public static const STATUS_OK:int = 10001;
		public static const STATUS_NOTHING_FOUND:int = 10002;
		
		//==================================================================
		protected var _bmd:BitmapData;
		protected var _status:int;
		
		protected var _pos:Point;
		
		protected var _width:int = 32;
		protected var _height:int = 32;
		
		protected var _tolerance:int = 2;
		
		//==================================================================
		public function AbstractTracker( bmd:BitmapData ) {
			super();
			_bmd = bmd;
			_status = STATUS_OK;
		}
		
		//==================================================================
		/**
		 * stores position
		 * @param	pos
		 */
		public function track( pos:Point ):void {
			this._pos = pos;
		}
		/**
		 * stores position
		 * @param	pos
		 * @param	radius
		 */
		public function trackArea( pos:Point, radius:uint=0 ):void {
			track(pos);
		}
		
		//==================================================================
		/**
		 * empty method, must be overriden by implementation
		 */
		public function update():void {
		}
		
		//==================================================================
		public function get pos():Point {	return _pos;		}
		public function get width():int {	return _width;		}
		public function get height():int {	return _height;		}
		public function get tolerance():int {	return _tolerance;		}
		public function get status():int {	return _status;		}
		public function get bmd():BitmapData {	return _bmd;		}
		
		public function set bmd( b:BitmapData ):void	{	_bmd = b;		}
		public function set width( w:int ):void			{	_width = w;		}
		public function set height( h:int ):void		{	_height = h;	}
		public function set tolerance( t:int ):void		{	_tolerance = t;	}
		
		//==================================================================
		public override function toString():String {
			return "[ AbstractTracker ]";
		}
		
		protected function log( msg:Object ):void {
			if(DEBUG) trace(this+"\t"+msg);
		}
	}
	
}