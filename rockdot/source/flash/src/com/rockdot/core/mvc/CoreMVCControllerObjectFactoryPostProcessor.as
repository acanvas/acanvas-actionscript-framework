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
package com.rockdot.core.mvc {
	import org.as3commons.async.operation.IOperation;
	import org.as3commons.lang.Assert;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.AbstractOrderedFactoryPostProcessor;
	import org.springextensions.actionscript.mvc.IController;


	/**
	 * <code>IObjectFactoryPostProcessor</code> that checks the specified <code>IConfigurableListableObjectFactory</code>
	 * if it contains an <code>MVCRouteEventsMetaDataPostProcessor</code>. If not, it creates one and adds it to
	 * the <code>IConfigurableListableObjectFactory</code> using its <code>addObjectPostProcessor()</code> method.
	 * <p>After that it loops through all the object definitions and examines each class for the presence of [Command]
	 * metadata annotations.</p>
	 * <p>Any class can be annotated with [Command] metadata, as long as some metadata keys are provided as well.</p>
	 * <p>What follows are some examples of typical usage:</p>
	 * <p>If an object acts as a command that needs to be executed after a specific event type was dispatched add
	 * this metadata to the class:</p>
	 * <pre>
	 * [Command(eventType="someEventType")]
	 * public class SomeCommandClass {
	 * //implementation ommitted...
	 * }
	 * </pre>
	 * <p>If the command needs to be excecuted after a specific event <code>Class</code> was dispatched then add this
	 * metadata:</p>
	 * <pre>
	 * [Command(eventClass="com.events.MyEvent")]
	 * public class SomeCommandClass {
	 * //implementation ommitted...
	 * }
	 * </pre>
	 * <p>By default the method that will be invoked on the command object will be 'execute', but it is also possible
	 * to specify the method like this:</p>
	 * <pre>
	 * [Command(eventType="someEventType",executeMethod="process")]
	 * public class SomeCommandClass {
	 * //implementation ommitted...
	 * }
	 * </pre>
	 * <p>If more than one command is to be executed after a specific event and it is needed to control the order in
	 * which these command will be executed, use the priority key:</p>
	 * <pre>
	 * [Command(eventType="someEventType",priority=10)]
	 * public class SomeCommandClass {
	 * //implementation ommitted...
	 * }
	 * </pre>
	 * <p>Properties on the <code>Event</code> instance can be mapped to the arguments of the specified execution
	 * method or to properties on the command instance.</p>
	 * <p>First there will be a check if the first argument for the specified execute method is of the same type
	 * as the associated event, in this case the event is simply passed into the execute method.</p>
	 * <p>If this is not the case the properties of the event or the properties defined by the <code>properties</code>
	 * metadata key will be mapped by type to the arguments of the execute method.</p>
	 * <p>Finally, if this is not possible, the properties on the event will be mapped by type to the properties on
	 * the command instance.</p>
	 * <p>[Command] annotations can be stacked, so one command class can be triggered by multiple <code>Events</code>.</p>
	 * @author Roland Zwaga
	 */
	public class CoreMVCControllerObjectFactoryPostProcessor extends AbstractOrderedFactoryPostProcessor{

		/**
		 * The object name that will be given to the controller instance in the object factory
		 */
		public static const CONTROLLER_OBJECT_NAME:String = "CoreMVCControllerObjectFactoryPostProcessor";

		public static const METADATAPROCESSOR_OBJECT_NAME:String = "SpringActionScriptMVCRouteEventsMetaDataProcessor";

		public static const COMMAND_METADATA:String = "Command";

		public static const EXECUTE_METHOD_METADATA_KEY:String = "executeMethod";

		public static const EVENT_TYPE_METADATA_KEY:String = "eventType";

		public static const EVENT_CLASS_METADATA_KEY:String = "eventClass";

		public static const PRIORITY_METADATA_KEY:String = "priority";

		public static const PROPERTIES_METADATA_KEY:String = "properties";

		public static const DEFAULT_EXECUTE_METHOD_NAME:String = "execute";

		/**
		 * Creates a new <code>MVCControllerObjectFactoryPostProcessor</code> instance.
		 */
		public function CoreMVCControllerObjectFactoryPostProcessor(order:int) {
			super(order);
		}

		/**
		 *
		 * @param objectFactory The specified <code>IConfigurableListableObjectFactory</code> instance.
		 */
		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation {
			Assert.notNull(objectFactory, "the objectFactory argument must not be null");
			addMVControllerInstance(objectFactory);
			return null;
		}

		/**
		 * Checks if the specified <code>IConfigurableListableObjectFactory</code> instance contains an object that
		 * implements the <code>IController</code> interface. When none is found a <code>Controller</code> instance
		 * is created and registered as a singleton in the <code>IConfigurableListableObjectFactory</code> instance.
		 * @param objectFactory The specified <code>IConfigurableListableObjectFactory</code> instance.
		 * @return The created or retrieved <code>IController</code> instance.
		 */
		public function addMVControllerInstance(objectFactory:IObjectFactory):void {
			Assert.notNull(objectFactory, "the objectFactory argument must not be null");
			var names:Vector.<String> = objectFactory.objectDefinitionRegistry.getObjectDefinitionNamesForType(IController);
			if (names == null) {
				var controller:IController = objectFactory.createInstance(CoreController);
				objectFactory.cache.putInstance(CONTROLLER_OBJECT_NAME, controller);
			} else {
			}
		}

	}
}
