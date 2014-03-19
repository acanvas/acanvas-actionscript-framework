package com.jvm.processing {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;

	/**
	 * A PseudoThread lets you perform expensive functions and tasks while keeping the UI snappy.
	 * 
	 * @example How to use the PseudoThread class: 
	 * <listing version="3.0">
	 * package {
	 * 	import com.sschmid.processing.PseudoThread;
	 * 
	 * 	import flash.display.Sprite;
	 * 	import flash.events.Event;
	 * 
	 * 	public class PseudoThreadTest extends Sprite {
	 * 		public function PseudoThreadTest() {
	 * 			var iterations : uint = 20000;	 * 			var subIterations : uint = 100;
	 * 			var delay : uint = 1;
	 * 			
	 * 			var pt : PseudoThread = new PseudoThread( expensiveFunction, iterations, subIterations, delay );
	 * 			pt.addEventListener( Event.COMPLETE, onThreadComplete );
	 * 			pt.execute( );
	 * 		}
	 * 
	 * 		
	 * 		private function onThreadComplete(event : Event) : void {
	 * 			trace( "Thread complete" );
	 * 		}
	 * 
	 * 		
	 * 		private function expensiveFunction(i : uint) : void {
	 * 			 //Do one step of a expensive calulations here. This function will be called "iterations" times.
	 * 			 (structure like a fori loop)
	 * 		}
	 * 	}
	 * }
	 * </listing> 	 
	 * 
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class PseudoThread extends EventDispatcher {
		private var _f : Function;
		private var _n : uint;		private var _d : uint;		private var _i : uint;
		private var _subIts : uint;

		/**
		 * @param callback(i : uint) The function that will be executed.
		 * @param iterations The number how often the target function will be called.
		 * @param subIterationsPerIteration Declare how many times the target function will be called per iteration. Play with this value to optimize the duration of the thread.
		 * @param delay Defines milliseconds to pause after each iteration, so the CPU can rest.
		 */
		public function PseudoThread(callback : Function, iterations : uint, subIterationsPerIteration : uint = 100, delay : uint = 1) {
			_f = callback;
			_n = iterations;
			_subIts = subIterationsPerIteration;
			_d = delay;
		}

		
		/**
		 * Starts the PseudoThread.
		 */
		public function execute() : void {
			for(var i : int = 0; i < _subIts; i++) {
				if(_i == _n) {
					_executionFinished();
					return;
				}
				_f(_i);
				_i++;	
			}
			setTimeout(execute, _d);
		}

		
		private function _executionFinished() : void {
			_i = 0;
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
