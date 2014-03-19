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
package com.rockdot.plugin.facebook.command.operation {
	import com.rockdot.plugin.facebook.airhack.FacebookAIR;

	import org.as3commons.async.operation.impl.AbstractOperation;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class FacebookOperationMobile extends AbstractOperation {
		protected var log : ILogger = getLogger(FacebookOperationMobile);

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------
		public function FacebookOperationMobile(apiMethod : String, values : Object = null, method : String = "GET") {
			super();
			if(apiMethod == "fql.query") {
			 		FacebookAIR.callRestAPI(apiMethod, faceBookResultHandler, values, method);
			} else {
					FacebookAIR.api(apiMethod, faceBookResultHandler, values, method);
			}
		}

		// --------------------------------------------------------------------
		//
		// Protected Methods
		//
		// --------------------------------------------------------------------

		protected function faceBookResultHandler(response : Object, fail : Object) : void {
			if (!response) {
				dispatchErrorEvent("(" + fail.error_code + ") : " + fail.error_msg);
				return;
			}
			dispatchCompleteEvent(response);
		}
	}
}