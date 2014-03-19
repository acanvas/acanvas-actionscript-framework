/*
 * Copyright 2007-2010 the original author or authors.
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
package com.rockdot.plugin.ugc.command.operation {
	import org.as3commons.async.operation.impl.AbstractOperation;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	import flash.net.Responder;

	public class PersistenceOperation extends AbstractOperation {
		protected var log : ILogger = getLogger(PersistenceOperation);			

		public function PersistenceOperation(service : *, methodName : String, ...args) {
			var rez : flash.net.Responder;
			rez = new flash.net.Responder(dispatchCompleteEvent, dispatchErrorEvent);
			if(args.length == 0) service.call(methodName, rez);
			else if(args.length == 1) service.call(methodName, rez, args[0]);
			else if(args.length == 2) service.call(methodName, rez, args[0], args[1]);
			else if(args.length == 3) service.call(methodName, rez, args[0], args[1], args[2]);
			else if(args.length == 4) service.call(methodName, rez, args[0], args[1], args[2], args[3]);
			else if(args.length == 5) service.call(methodName, rez, args[0], args[1], args[2], args[3], args[4]);
		}
	}
}