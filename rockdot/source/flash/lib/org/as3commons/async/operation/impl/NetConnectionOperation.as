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
package org.as3commons.async.operation.impl {
	import org.as3commons.lang.Assert;

	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.setTimeout;

	/**
	 * An <code>IOperation</code> that invokes a method on a <code>NetConnection</code>.
	 * @see flash.net.NetConnection
	 * @author Christophe Herreman
	 */
	public class NetConnectionOperation extends AbstractOperation {

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>NetConnectionOperation</code> instance.
		 *
		 * @param netConnection the netconnection on which the method is invoked
		 * @param methodName the name of the method to be invoked
		 * @param parameters the parameters passed to the invoked method
		 */
		public function NetConnectionOperation(netConnection:NetConnection, methodName:String, parameters:Array=null) {
			super();
			initNetConnectionOperation(netConnection, methodName, parameters);
		}

		protected function initNetConnectionOperation(netConnection:NetConnection, methodName:String, parameters:Array):void {
			Assert.notNull(netConnection, "The netconnection should not be null");
			Assert.hasText(methodName, "The method name must not be null or an empty string");

			this.netConnection = netConnection;
			_methodName = methodName;
			_parameters = parameters;

			setTimeout(invokeRemoteMethod, 0);
		}


		// --------------------------------------------------------------------
		//
		// Public Properties
		//
		// --------------------------------------------------------------------

		// ----------------------------
		// methodName
		// ----------------------------

		private var _methodName:String;

		public function get methodName():String {
			return _methodName;
		}

		// ----------------------------
		// parameters
		// ----------------------------

		private var _parameters:Array;

		public function get parameters():Array {
			return _parameters;
		}

		// --------------------------------------------------------------------
		//
		// Protected Properties
		//
		// --------------------------------------------------------------------

		// ----------------------------
		// netConnection
		// ----------------------------

		private var _netConnection:NetConnection;

		/**
		 * The <code>NetConnection</code> used by the current <code>NetConnectionOperation</code>.
		 * @return the netconnection
		 */
		protected function get netConnection():NetConnection {
			return _netConnection;
		}

		/**
		 * @private
		 */
		protected function set netConnection(value:NetConnection):void {
			_netConnection = value;
		}

		// --------------------------------------------------------------------
		//
		// Protected Methods
		//
		// --------------------------------------------------------------------

		/**
		 *
		 *
		 */
		protected function invokeRemoteMethod():void {
			var responder:Responder = new Responder(resultHandler, faultHandler);
			var parameters:Array = [_methodName, responder];
			parameters = parameters.concat(_parameters);
			netConnection.call.apply(netConnection, parameters);
		}

		/**
		 *
		 * @param result
		 */
		protected function resultHandler(result:Object):void {
			this.result = result;
			dispatchCompleteEvent();
		}

		/**
		 *
		 * @param fault
		 */
		protected function faultHandler(fault:Object):void {
			error = fault;
			dispatchErrorEvent();
		}
	}
}
