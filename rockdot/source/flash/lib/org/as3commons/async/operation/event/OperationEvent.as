/*
 * Copyright 2007-2011 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.as3commons.async.operation.event {
	import org.as3commons.async.operation.IOperation;

	import flash.events.Event;

	/**
	 * An <code>OperationEvent</code> is an <code>Event</code> generated by an <code>IOperation</code> instance.
	 * @author Christophe Herreman
	 */
	public class OperationEvent extends Event {

		// --------------------------------------------------------------------
		//
		// Public Static Constants
		//
		// --------------------------------------------------------------------

		/** The type of the <code>OperationEvent</code> dispatched when an <code>IOperation</code> is done/complete. */
		public static const COMPLETE:String = "operationComplete";

		/** The type of the <code>OperationEvent</code> dispatched when an error occurs during the execution of an <code>IOperation</code> */
		public static const ERROR:String = "operationError";

		/** The type of the <code>OperationEvent</code> dispatched upon progress of the <code>IProgressOperation</code> */
		public static const PROGRESS:String = "operationProgress";

		/** The type of the <code>OperationEvent</code> dispatched when an <code>IOperation</code> times out. */
		public static const TIMEOUT:String = "operationTimeout";

		// --------------------------------------------------------------------
		//
		// Public Static Methods
		//
		// --------------------------------------------------------------------

		public static function createCompleteEvent(operation:IOperation, bubbles:Boolean=false, cancelable:Boolean=false):OperationEvent {
			return new OperationEvent(OperationEvent.COMPLETE, operation, bubbles, cancelable);
		}

		public static function createErrorEvent(operation:IOperation, bubbles:Boolean=false, cancelable:Boolean=false):OperationEvent {
			return new OperationEvent(OperationEvent.ERROR, operation, bubbles, cancelable);
		}

		public static function createProgressEvent(operation:IOperation, bubbles:Boolean=false, cancelable:Boolean=false):OperationEvent {
			return new OperationEvent(OperationEvent.PROGRESS, operation, bubbles, cancelable);
		}

		public static function createTimeoutEvent(operation:IOperation, bubbles:Boolean=false, cancelable:Boolean=false):OperationEvent {
			return new OperationEvent(OperationEvent.TIMEOUT, operation, bubbles, cancelable);
		}

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>OperationEvent</code> instance.
		 * @param type The type of the current <code>OperationEvent</code>, can be either <code>OperationEvent.COMPLETE</code>, <code>OperationEvent.ERROR</code> or <code>OperationEvent.PROGRESS</code>.
		 * @param operation The <code>IOperation</code> that generated the current <code>OperationEvent</code>.
		 */
		public function OperationEvent(type:String, operation:IOperation, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.operation = operation;
		}

		// --------------------------------------------------------------------
		//
		// Properties
		//
		// --------------------------------------------------------------------

		// ----------------------------
		// operation
		// ----------------------------

		private var _operation:IOperation;

		/**
		 * @return The <code>IOperation</code> that generated the current <code>OperationEvent</code>.
		 */
		public function get operation():IOperation {
			return _operation;
		}

		/**
		 * @private
		 */
		public function set operation(value:IOperation):void {
			if (value !== _operation) {
				_operation = value;
			}
		}

		// ----------------------------
		// result
		// ----------------------------

		/**
		 * @return The result of the <code>IOperation</code> that generated the current <code>OperationEvent</code>.
		 */
		public function get result():* {
			return (operation ? operation.result : null);
		}

		// ----------------------------
		// error
		// ----------------------------

		/**
		 * @return The error of the <code>IOperation</code> that generated the current <code>OperationEvent</code>.
		 */
		public function get error():* {
			return (operation ? operation.error : null);
		}

		// --------------------------------------------------------------------
		//
		// Overridden Methods
		//
		// --------------------------------------------------------------------

		/**
		 * @return An exact copy of the current <code>OperationEvent</code>
		 */
		override public function clone():Event {
			return new OperationEvent(type, operation, bubbles, cancelable);
		}
	}
}
