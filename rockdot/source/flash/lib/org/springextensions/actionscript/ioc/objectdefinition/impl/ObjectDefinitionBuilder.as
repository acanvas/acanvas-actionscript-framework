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
package org.springextensions.actionscript.ioc.objectdefinition.impl {
	import org.as3commons.lang.ClassUtils;
	import org.springextensions.actionscript.ioc.config.impl.RuntimeObjectReference;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;

	/**
	 * Builder for object definitions.
	 *
	 * @author Christophe Herreman
	 * @see org.springextensions.actionscript.ioc.factory.xml.parser.support.XMLObjectDefinitionsParser XMLObjectDefinitionsParser
	 * @docref extensible_xml_authoring.html#coding_an_iobjectdefinitionparser_implementation
	 */
	public class ObjectDefinitionBuilder {

		private var _objectDefinition:IObjectDefinition;

		/**
		 * Creates a new ObjectDefinitionBuilder to construct an ObjectDefinition.
		 */
		public static function objectDefinitionBuilder():ObjectDefinitionBuilder {
			var result:ObjectDefinitionBuilder = new ObjectDefinitionBuilder();
			return result;
		}

		/**
		 * Creates an ObjectDefinitionBuilder for the specified <code>Class</code> instance.
		 */
		public static function objectDefinitionForClass(clazz:Class):ObjectDefinitionBuilder {
			var result:ObjectDefinitionBuilder = new ObjectDefinitionBuilder();
			result._objectDefinition.className = ClassUtils.getFullyQualifiedName(clazz, true);
			return result;
		}

		/**
		 * Creates an ObjectDefinitionBuilder for the specified class name.
		 */
		public static function objectDefinitionForClassName(className:String):ObjectDefinitionBuilder {
			var result:ObjectDefinitionBuilder = new ObjectDefinitionBuilder();
			result._objectDefinition.className = className;
			return result;
		}

		/**
		 * Creates a new ObjectDefinitionBuilder
		 */
		public function ObjectDefinitionBuilder() {
			super();
			_objectDefinition = new ObjectDefinition("");
		}

		/**
		 * Returns the object definition created by this builder.
		 */
		public function get objectDefinition():IObjectDefinition {
			return _objectDefinition;
		}


		/**
		 * Adds a constructor argument with a value.
		 */
		public function addConstructorArgValue(value:Object):ObjectDefinitionBuilder {
			_objectDefinition.constructorArguments ||= [];
			_objectDefinition.constructorArguments[_objectDefinition.constructorArguments.length] = value;
			return this;
		}

		/**
		 * Adds a constructor argument with a named object reference.
		 */
		public function addConstructorArgReference(objectName:String):ObjectDefinitionBuilder {
			return addConstructorArgValue(new RuntimeObjectReference(objectName));
		}

		/**
		 * Adds a property with a value.
		 */
		public function addPropertyValue(name:String, value:*, namespace:String=null, isStatic:Boolean=false):ObjectDefinitionBuilder {
			_objectDefinition.addPropertyDefinition(new PropertyDefinition(name, value, namespace, isStatic));
			return this;
		}

		/**
		 * Adds a property with a named object reference.
		 */
		public function addPropertyReference(name:String, objectName:String, namespace:String=null, isStatic:Boolean=false):ObjectDefinitionBuilder {
			return addPropertyValue(name, new RuntimeObjectReference(objectName), namespace, isStatic);
		}

		public function addMethodInvocation(name:String, arguments:Array=null, namespace:String=null):ObjectDefinitionBuilder {
			var methodInvocation:MethodInvocation = new MethodInvocation(name, arguments, namespace);
			_objectDefinition.addMethodInvocation(methodInvocation);
			return this;
		}


	}
}
