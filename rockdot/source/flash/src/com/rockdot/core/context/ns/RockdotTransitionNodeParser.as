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
	import com.rockdot.library.view.effect.IEffect;
	import com.rockdot.plugin.screen.common.model.ScreenConstants;

	import org.as3commons.lang.ClassUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getClassLogger;
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionScope;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinitionBuilder;

	import flash.errors.IllegalOperationError;



	use namespace spring_actionscript_rockdot;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class RockdotTransitionNodeParser extends AbstractObjectDefinitionParser {

		private static const logger:ILogger = getClassLogger(RockdotTransitionNodeParser);

		/** The object-selector attribute */
		public static const DURATION_ATTR:String = "duration";
		public static const TYPE_ATTR : String = "type";
		public static const ALPHA_ATTR : String = "initialAlpha";

		/**
		 * Creates a new <code>StageProcessorNodeParser</code> instance.
		 */
		public function RockdotTransitionNodeParser() {
			super();
		}

		/**
		 * @inheritDoc
		 */
		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			
			
			//create page object def
			var cls:Class = ClassUtils.forName(String(node.attribute("class")[0]));
			if (ClassUtils.isImplementationOf(cls, IEffect) == false) {
				throw new IllegalOperationError("The class defined in the <page/> element is not an implementation of IUIElement");
			}
			var result:ObjectDefinitionBuilder = ObjectDefinitionBuilder.objectDefinitionForClass(cls);

			//create StateVO object def
			var duration : Number = (node.attribute(DURATION_ATTR).length() > 0) ? Number(node.attribute(DURATION_ATTR)) : 0;
			var type : String = (node.attribute(TYPE_ATTR).length() > 0) ? String(node.attribute(TYPE_ATTR)) : ScreenConstants.TRANSITION_SEQUENTIAL;
			var initialAlpha : Number = (node.attribute(ALPHA_ATTR).length() > 0) ? Number(node.attribute(ALPHA_ATTR)) : 0;

			result.addPropertyValue(DURATION_ATTR, duration );
			result.addPropertyValue(TYPE_ATTR, type );
			result.addPropertyValue(ALPHA_ATTR, initialAlpha );

			context.parseAttributes(result.objectDefinition, node);
			context.parseConstructorArguments(result.objectDefinition, node);
			context.parseMethodInvocations(result.objectDefinition, node);
			context.parseProperties(result.objectDefinition, node);

			result.objectDefinition.autoWireMode = AutowireMode.NO;
			result.objectDefinition.isLazyInit = true;
			result.objectDefinition.scope = ObjectDefinitionScope.PROTOTYPE;
			
			var objectName:String = resolveID(node, result.objectDefinition, context);
			context.registerObjectDefinition(objectName, result.objectDefinition);
			

			logger.debug("Parsed object definition: {0}, for id '{1}'", [result.objectDefinition, objectName]);

			return result.objectDefinition;
		}
	}
}
