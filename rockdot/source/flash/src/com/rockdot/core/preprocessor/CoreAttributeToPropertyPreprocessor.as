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
package com.rockdot.core.preprocessor {
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_objects;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.IXMLObjectDefinitionsPreprocessor;

	use namespace spring_actionscript_objects;
	/**
	 * Preprocesses attributes to elements. Only whitelisted attributes are converted.
	 * 
	 * @example
	 * <p>Input: &lt;object class="com.myclasses.MyClass"/&gt;</p>
	 * <p>Result:<br/>
	 * <pre>
	 * &lt;object&gt;<br/>
	 *   &lt;class&gt;com.myclasses.MyClass&lt;/class&gt;<br/>
	 * &lt;/object&gt;
	 * </pre>
	 * @flowerModelElementId _0LkaMC9LEeG0Qay4mHgS6g
	 */
	public class CoreAttributeToPropertyPreprocessor implements IXMLObjectDefinitionsPreprocessor {
		
		private var _ATTRIBUTE_WHITELIST : Array 
						= [   "x", "y" 							//Sprite
							, "tree_order", "tree_parent" 		//Menu: Tree and Label
							, "url"						 		//Address
							, "view_id", "property_key", "substate"			//.properties ID
							, "transition", "duration", "type" 	//Transition
  						  ];
						
		/**
		 * @inheritDoc
		 * Process ALL Context nodes.
		 */
		public function preprocess(xml : XML) : XML {
			var objectNodes : XMLList = xml.descendants();

			for each (var node:XML in objectNodes) {
				_preprocessNode(node);
			}
			return xml;
		}

		private function _preprocessNode(node : XML) : void {
			
			/* Iterate over attributes of node */
			for each (var attribute:XML in node.attributes()) {
				var name : String = attribute.localName() as String;

				/* If attribute name is whitelisted, convert it to a property node */
				if (_ATTRIBUTE_WHITELIST.indexOf(name) != -1) {
					if (attribute[0] != undefined) {
						/* Create/append new property node */
						node.appendChild(<property name={name} value={attribute[0].toString()}/>);
						/* delete attribute */
						delete attribute[0];
					}
				}
			}
		}
	}
}
