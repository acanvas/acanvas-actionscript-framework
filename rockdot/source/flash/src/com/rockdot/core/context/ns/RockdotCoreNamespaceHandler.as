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
package com.rockdot.core.context.ns {
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractNamespaceHandler;

	/**
	 * Namespace handler for all elements pertaining to the stage interception schema
	 * @author Roland Zwaga
	 */
	public class RockdotCoreNamespaceHandler extends AbstractNamespaceHandler {

		public static const SCREEN_ELEMENT:String = "screen";
		public static const TRANSITION_ELEMENT:String = "transition";

		public function RockdotCoreNamespaceHandler() {
			super(spring_actionscript_rockdot);
			registerObjectDefinitionParser(SCREEN_ELEMENT, new RockdotScreenNodeParser());
			registerObjectDefinitionParser(TRANSITION_ELEMENT, new RockdotTransitionNodeParser());
		}

	}
}
