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
package org.springextensions.actionscript.ioc.impl {
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getClassLogger;
	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.MethodInvoker;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.ioc.IDependencyChecker;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessorAware;
	import org.springextensions.actionscript.ioc.config.impl.RuntimeObjectReference;
	import org.springextensions.actionscript.ioc.error.ResolveReferenceError;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionScope;
	import org.springextensions.actionscript.ioc.objectdefinition.event.ObjectDefinitionEvent;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;
	import org.springextensions.actionscript.object.ITypeConverter;
	import org.springextensions.actionscript.object.SimpleTypeConverter;
	import org.springextensions.actionscript.util.ContextUtils;

	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultDependencyInjector extends EventDispatcher implements IDependencyInjector, IApplicationDomainAware {

		private static const DEFAULT_OBJECTNAME:String = "(no name)";
		private static const ID_FIELD_NAME:String = "id";
		private static const PROTOTYPE_FIELD_NAME:String = 'prototype';

		private static var logger:ILogger = getClassLogger(DefaultDependencyInjector);

		/**
		 * Creates a new <code>DefaultDependencyInjector</code> instance.
		 */
		public function DefaultDependencyInjector() {
			super();
		}

		private var _applicationDomain:ApplicationDomain;
		private var _definitionListeners:Object;
		private var _dependencyChecker:IDependencyChecker;
		private var _typeConverter:ITypeConverter;

		/**
		 * @inheritDoc
		 */
		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
			if (_typeConverter != null) {
				_typeConverter = new SimpleTypeConverter(_applicationDomain);
			}
		}

		public function get dependencyChecker():IDependencyChecker {
			return _dependencyChecker;
		}

		public function set dependencyChecker(value:IDependencyChecker):void {
			_dependencyChecker = value;
		}

		/**
		 *
		 */
		public function get typeConverter():ITypeConverter {
			if (_typeConverter == null) {
				_typeConverter = new SimpleTypeConverter(_applicationDomain);
			}
			return _typeConverter;
		}

		/**
		 * @private
		 */
		public function set typeConverter(value:ITypeConverter):void {
			_typeConverter = value;
		}

		/**
		 *
		 * @param objectDefinition
		 * @param instance
		 * @param objectFactory
		 */
		public function executeMethodInvocations(objectDefinition:IObjectDefinition, instance:*, objectFactory:IObjectFactory):void {
			if (objectDefinition.methodInvocations) {
				for each (var methodInvocation:MethodInvocation in objectDefinition.methodInvocations) {
					var methodInvoker:MethodInvoker = new MethodInvoker();
					methodInvoker.target = instance;
					methodInvoker.method = methodInvocation.methodName;
					methodInvoker.namespaceURI = methodInvocation.namespaceURI;
					methodInvoker.arguments = resolveReferences(methodInvocation.arguments, objectFactory);
					logger.debug("Invoking method '{0}()' on instance {1} with arguments {2}", [methodInvocation.methodName, instance, ContextUtils.arrayToString(arguments)]);
					methodInvoker.invoke();
				}
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectDefinition
		 */
		public function initializeInstance(instance:*, objectDefinition:IObjectDefinition=null):void {
			if (instance is IInitializingObject) {
				IInitializingObject(instance).afterPropertiesSet();
			}

			if ((objectDefinition != null) && (StringUtils.hasText(objectDefinition.initMethod))) {
				logger.debug("Invoking init method '{0}()' on instance {1}", [objectDefinition.initMethod, instance]);
				instance[objectDefinition.initMethod]();
			}
		}

		/**
		 * Set the properties on the newly created object as defined by the specified <code>IObjectDefinition</code>.
		 * @param instance The newly created object
		 * @param objectDefinition The specified <code>IObjectDefinition</code>
		 * @param objectName The name of the newly created object as known by the object factory
		 * @param referenceResolvers A collection of <code>IReferenceResolver</code> used to resolve the property values as defined by the specified <code>IObjectDefinition</code>.
		 */
		public function injectProperties(instance:*, objectDefinition:IObjectDefinition, objectName:String, objectFactory:IObjectFactory):void {
			var newValue:*;
			var clazz:Class;
			var target:Object;
			for each (var property:PropertyDefinition in objectDefinition.properties) {
				clazz ||= ClassUtils.forInstance(instance, _applicationDomain);
				// Note: Using two try blocks in order to improve error reporting
				// resolve the reference to the property
				try {
					if (!property.isLazy) {
						newValue = objectFactory.resolveReference(property.value);
					} else {
						var ror:RuntimeObjectReference = property.value as RuntimeObjectReference;
						if (objectFactory.objectDefinitionRegistry.containsObjectDefinition(ror.objectName)) {
							newValue = objectFactory.resolveReference(property.value);
						} else {
							newValue = null;
						}
					}
				} catch (e:Error) {
					throw new ResolveReferenceError(StringUtils.substitute("The property '{0}' on the definition of '{1}' could not be resolved. Original error: {2}\n{3}", property, objectName, e.message, e.getStackTrace()));
				}

				try {
					var type:Type = Type.forClass(clazz, _applicationDomain);
					var field:Field = type.getField(property.name, property.namespaceURI);

					if (newValue && field && field.type.clazz) {
						newValue = typeConverter.convertIfNecessary(newValue, field.type.clazz);
					}

					if (!property.isStatic) {
						target = instance;
					} else {
						target = clazz;
					}
					logger.debug("Injecting property {0}.{1} with value {2}", [instance, property.qName, newValue]);
					target[property.qName] = newValue;
				} catch (e:Error) {
					throw e;
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		public function wire(instance:*, objectFactory:IObjectFactory, objectDefinition:IObjectDefinition=null, objectName:String=null):Object {
			if (objectDefinition == null) {
				logger.debug("Wiring instance {0} (name: {1}) without definition", [instance, objectName]);
				return wireWithoutObjectDefinition(instance, objectName, objectFactory);
			} else {
				if (_dependencyChecker == null) {
					_dependencyChecker = new DefaultDependencyChecker(objectFactory);
				}
				logger.debug("Wiring instance {0} (name: {1}) with definition", [instance, objectName]);
				return wireWithObjectDefinition(instance, objectFactory, objectName, objectDefinition);
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectName
		 * @param objectFactory
		 * @param objectDefinition
		 */
		private function autowireInstance(instance:*, objectName:String, objectFactory:IObjectFactory, objectDefinition:IObjectDefinition=null):void {
			var autoWireAware:IAutowireProcessorAware = objectFactory as IAutowireProcessorAware;
			if ((autoWireAware != null) && (autoWireAware.autowireProcessor != null)) {
				logger.debug("Autowiring instance {0} (name: {1})", [instance, objectName]);
				autoWireAware.autowireProcessor.autoWire(instance, objectDefinition, objectName);
			}
		}

		/**
		 * Caches the object if its definition is a singleton<br/>
		 * Note: if the object is an <code>IFactoryObject</code>, the <code>IFactoryObject</code> instance is cached and not the
		 * object it creates
		 * @param objectDefinition
		 * @param cache
		 * @param objectName
		 * @param instance
		 */
		private function cacheSingleton(objectDefinition:IObjectDefinition, cache:IInstanceCache, objectName:String, instance:*):void {
			if (objectDefinition.scope === ObjectDefinitionScope.SINGLETON) {
				cache.putInstance(objectName, instance);
			}
		}

		/**
		 *
		 * @param objectDefinition
		 * @param instance
		 * @param objectName
		 */
		private function checkDependencies(objectDefinition:IObjectDefinition, instance:*, objectName:String):LazyDependencyCheckResult {
			return dependencyChecker.checkDependenciesSatisfied(objectDefinition, instance, objectName, _applicationDomain, (objectDefinition.dependencyCheck !== DependencyCheckMode.NONE));
		}

		/**
		 *
		 * @param instance
		 * @param objectDefinition
		 */
		private function checkForCustomConfiguration(instance:*, objectDefinition:IObjectDefinition, objectFactory:IObjectFactory):* {
			var result:*;
			if (objectDefinition.customConfiguration is ICustomConfigurator) {
				result = executeCustomConfiguration(objectDefinition, objectDefinition.customConfiguration, instance, objectFactory);
				if (result != null) {
					instance = result;
				}
			} else if (objectDefinition.customConfiguration is Vector.<Object>) {
				var configurators:Vector.<Object> = objectDefinition.customConfiguration;
				var configurator:ICustomConfigurator;
				for each (var item:Object in configurators) {
					configurator = null;
					if (item is ICustomConfigurator) {
						configurator = item as ICustomConfigurator;
					} else if (item is RuntimeObjectReference) {
						configurator = objectFactory.getObject((item as RuntimeObjectReference).objectName);
					}
					if (configurator != null) {
						result = executeCustomConfiguration(objectDefinition, configurator, instance, objectFactory);
						if (result != null) {
							instance = result;
						}
					}
				}
			}
			return instance;
		}

		private function executeCustomConfiguration(objectDefinition:IObjectDefinition, customConfiguration:ICustomConfigurator, instance:*, objectFactory:IObjectFactory):* {
			logger.debug("Executing custom configuration {0} on instance {1}", [customConfiguration, instance]);
			wire(customConfiguration, objectFactory);
			return ICustomConfigurator(customConfiguration).execute(instance, objectDefinition);
		}

		/**
		 *
		 * @param instance
		 * @param objectName
		 * @param objectPostProcessors
		 */
		private function postProcessingAfterInitialization(instance:*, objectName:String, objectPostProcessors:Vector.<IObjectPostProcessor>):Object {
			var result:*;
			for each (var processor:IObjectPostProcessor in objectPostProcessors) {
				logger.debug("Executing object postprocessor {0} after initialization on instance {1}", [processor, instance]);
				result = processor.postProcessAfterInitialization(instance, objectName);
				if (result != null) {
					instance = result;
				}
			}
			return instance;
		}

		/**
		 *
		 * @param instance
		 * @param objectName
		 * @param objectPostProcessors
		 */
		private function postProcessingBeforeInitialization(instance:*, objectName:String, objectPostProcessors:Vector.<IObjectPostProcessor>):Object {
			var result:*;
			for each (var processor:IObjectPostProcessor in objectPostProcessors) {
				logger.debug("Executing object postprocessor {0} before initialization on instance {1}", [processor, instance]);
				result = processor.postProcessBeforeInitialization(instance, objectName);
				if (result != null) {
					instance = result;
				}
			}
			return instance;
		}

		/**
		 *
		 * @param objectDefinition
		 * @param cache
		 * @param instance
		 * @param objectName
		 */
		private function prepareSingleton(objectDefinition:IObjectDefinition, cache:IInstanceCache, instance:*, objectName:String):void {
			if (objectDefinition.isSingleton) {
				cache.prepareInstance(objectName, instance);
			}
		}

		/**
		 *
		 * @param objectName
		 * @param instance
		 * @return
		 */
		private function resolveObjectName(objectName:String, instance:*):String {
			if (!StringUtils.hasText(objectName)) {
				if (instance.hasOwnProperty(ID_FIELD_NAME)) {
					objectName = instance[ID_FIELD_NAME];
				} else {
					objectName = DEFAULT_OBJECTNAME;
				}
			}
			logger.debug("Resolved object name for instance {0} is '{1}'", [instance, objectName]);
			return objectName;
		}

		/**
		 *
		 * @param properties
		 * @param objectFactory
		 * @return
		 */
		private function resolveReferences(references:Array, objectFactory:IObjectFactory):Array {
			var result:Array = [];
			for each (var r:* in references) {
				result[result.length] = objectFactory.resolveReference(r);
			}
			return result;
		}

		/**
		 *
		 * @param instance
		 * @param objectFactory
		 * @param objectName
		 * @param objectDefinition
		 */
		private function wireWithObjectDefinition(instance:*, objectFactory:IObjectFactory, objectName:String, objectDefinition:IObjectDefinition):Object {
			objectName ||= objectDefinition.className;

			prepareSingleton(objectDefinition, objectFactory.cache, instance, objectName);

			// Autowire happens before setting all explicitly configured properties
			// so that autowired properties can be overridden.
			autowireInstance(instance, objectName, objectFactory, objectDefinition);

			injectProperties(instance, objectDefinition, objectName, objectFactory);

			if (!objectDefinition.skipPostProcessors) {
				instance = postProcessingBeforeInitialization(instance, objectName, objectFactory.objectPostProcessors);
			}

			var result:LazyDependencyCheckResult = checkDependencies(objectDefinition, instance, objectName);

			if (result === LazyDependencyCheckResult.SATISFIED) {
				initializeInstance(instance, objectDefinition);
				executeMethodInvocations(objectDefinition, instance, objectFactory);
			} else if (result === LazyDependencyCheckResult.UNSATISFIED_LAZY) {
				_definitionListeners ||= {};
				if (_definitionListeners[objectName] == null) {
					_definitionListeners[objectName] = true;
					var onInstancesDependenciesUpdated:Function = function(event:ObjectDefinitionEvent):void {
						objectDefinition.removeEventListener(ObjectDefinitionEvent.INSTANCES_DEPENDENCIES_UPDATED, onInstancesDependenciesUpdated);
						for each (var instance:* in event.instances) {
							if (_dependencyChecker.checkLazyDependencies(event.objectDefinition, instance, _applicationDomain)) {
								initializeInstance(instance, objectDefinition);
								executeMethodInvocations(objectDefinition, instance, objectFactory);
							}
						}
					}
					objectDefinition.addEventListener(ObjectDefinitionEvent.INSTANCES_DEPENDENCIES_UPDATED, onInstancesDependenciesUpdated, false, 0, true);
				}
			}

			if (!objectDefinition.skipPostProcessors) {
				instance = postProcessingAfterInitialization(instance, objectName, objectFactory.objectPostProcessors);
			}

			instance = checkForCustomConfiguration(instance, objectDefinition, objectFactory);

			cacheSingleton(objectDefinition, objectFactory.cache, objectName, instance);

			return instance;
		}

		/**
		 *
		 * @param instance
		 * @param objectName
		 * @param objectFactory
		 */
		private function wireWithoutObjectDefinition(instance:*, objectName:String, objectFactory:IObjectFactory):Object {
			objectName = resolveObjectName(objectName, instance);

			autowireInstance(instance, objectName, objectFactory);

			var processors:Vector.<IObjectPostProcessor> = objectFactory.objectPostProcessors;

			instance = postProcessingBeforeInitialization(instance, objectName, processors);

			initializeInstance(instance);

			instance = postProcessingAfterInitialization(instance, objectName, processors);

			return instance;
		}
	}
}
