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
	import com.rockdot.plugin.screen.common.view.IScreen;
	import com.rockdot.plugin.state.model.StateConstants;
	import com.rockdot.plugin.state.model.vo.StateVO;

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
	public class RockdotScreenNodeParser extends AbstractObjectDefinitionParser {

		private static const logger:ILogger = getClassLogger(RockdotScreenNodeParser);

		/** The object-selector attribute */
		public static const TREE_ORDER_ATTR:String = "tree_order";
		public static const TREE_PARENT_ATTR:String = "tree_parent";
		public static const TRANSITION_ATTR:String = "transition";
		public static const TYPE_ATTR : String = "type";
		private static const URL_ATTR : String = "";

		/**
		 * Creates a new <code>StageProcessorNodeParser</code> instance.
		 */
		public function RockdotScreenNodeParser() {
			super();
		}

		/**
		 * @inheritDoc
		 */
		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			
			
			//create page object def
			var cls:Class = ClassUtils.forName(String(node.attribute("class")[0]));
			if (ClassUtils.isImplementationOf(cls, IScreen) == false) {
				throw new IllegalOperationError("The class defined in the <screen/> element is not an implementation of IScreen");
			}
			var result:ObjectDefinitionBuilder = ObjectDefinitionBuilder.objectDefinitionForClass(cls);

			context.parseAttributes(result.objectDefinition, node);
			context.parseConstructorArguments(result.objectDefinition, node);
			context.parseMethodInvocations(result.objectDefinition, node);
			context.parseProperties(result.objectDefinition, node);
			
			result.objectDefinition.constructorArguments = ["should not happen"];
			result.objectDefinition.isLazyInit = true;
			result.objectDefinition.autoWireMode = AutowireMode.NO;
			result.objectDefinition.scope = ObjectDefinitionScope.PROTOTYPE;

			var objectName:String = resolveID(node, result.objectDefinition, context);
			context.registerObjectDefinition(objectName, result.objectDefinition);


			//create StateVO object def
			var stateVO:ObjectDefinitionBuilder = ObjectDefinitionBuilder.objectDefinitionForClass(StateVO);
			stateVO.objectDefinition.autoWireMode = AutowireMode.NO;
			stateVO.objectDefinition.isLazyInit = false;
			stateVO.objectDefinition.scope = ObjectDefinitionScope.SINGLETON;
			
			var tree_order : uint = (node.attribute(TREE_ORDER_ATTR).length() > 0) ? uint(node.attribute(TREE_ORDER_ATTR)) : 0;
			var tree_parent : uint = (node.attribute(TREE_PARENT_ATTR).length() > 0) ? uint(node.attribute(TREE_PARENT_ATTR)) : 0;
			var transition : String = (node.attribute(TRANSITION_ATTR).length() > 0) ? String(node.attribute(TRANSITION_ATTR)) : "";
			var url : String = (node.attribute(URL_ATTR).length() > 0) ? String(node.attribute(URL_ATTR)) : null;
			var substate : String = (node.attribute(TYPE_ATTR).length() > 0) ? String(node.attribute(TYPE_ATTR)) : StateConstants.SUB_NORMAL;
			
			stateVO.addPropertyValue(TREE_ORDER_ATTR, tree_order );
			stateVO.addPropertyValue(TREE_PARENT_ATTR, tree_parent );
			stateVO.addPropertyValue(TRANSITION_ATTR, transition );
			stateVO.addPropertyValue("url", url );
			stateVO.addPropertyValue("substate", substate );
			stateVO.addPropertyValue("property_key", objectName );
			stateVO.addPropertyValue("view_id", objectName );
			var list : XMLList = node.madcomponents_rockdot::madscreen;
			stateVO.addPropertyValue("madUI", new XML(list.children().toXMLString()) );
			
			context.registerObjectDefinition("vo." + objectName, stateVO.objectDefinition);

			logger.debug("Parsed object definition: {0}, for id '{1}'", [result.objectDefinition, objectName]);


			return result.objectDefinition;
		}
	}
}
