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
package com.rockdot.core.context {
	import com.rockdot.core.context.ns.RockdotCoreNamespaceHandler;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.CompositeCommandWithEvent;
	import com.rockdot.core.mvc.CoreMVCControllerObjectFactoryPostProcessor;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.core.preprocessor.CorePropertyImportPreprocessor;

	import org.as3commons.async.command.CompositeCommandKind;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.impl.SpringApplicationContext;
	import org.springextensions.actionscript.ioc.config.impl.xml.XMLObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultInstanceCache;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ObjectReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.RegisterObjectFactoryPostProcessorsFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.object.ApplicationContextAwareObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.DefaultObjectDefinitionRegistry;

	import flash.display.DisplayObject;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class RockdotApplicationContext extends SpringApplicationContext {

		/**
		 * Creates a new <code>ApplicationContext</code> instance.
		 * @param parent
		 * @param objFactory
		 */
		public function RockdotApplicationContext(source : * = null, parent : IApplicationContext = null, rootViews:Vector.<DisplayObject>=null, objFactory:IObjectFactory=null) {
			objFactory ||= createDefaultObjectFactory(parent);
			super(rootViews, objFactory);


//			addObjectFactoryPostProcessor(new RegisterObjectPostProcessorsFactoryPostProcessor(-100));
			addObjectFactoryPostProcessor(new RegisterObjectFactoryPostProcessorsFactoryPostProcessor(-99));
//			addObjectFactoryPostProcessor(new ObjectDefinitionFactoryPostProcessor(-98));
//			addObjectFactoryPostProcessor(new StageProcessorFactoryPostprocessor());
//			addObjectFactoryPostProcessor(new MetadataProcessorObjectFactoryPostProcessor());
//			addObjectFactoryPostProcessor(new FactoryObjectFactoryPostProcessor());

//			if (objectFactory.objectDefinitionRegistry != null) {
//				var definition:IObjectDefinition = new ObjectDefinition(ClassUtils.getFullyQualifiedName(PostConstructMetadataProcessor, true));
//				objectFactory.objectDefinitionRegistry.registerObjectDefinition("springactionscript_postConstructProcessor", definition);
//				definition = new ObjectDefinition(ClassUtils.getFullyQualifiedName(PreDestroyMetadataProcessor, true));
//				objectFactory.objectDefinitionRegistry.registerObjectDefinition("springactionscript_preDestroyProcessor", definition);
//			}

			objectFactory.addObjectPostProcessor(new ApplicationContextAwareObjectPostProcessor(this));
//			objectFactory.addObjectPostProcessor(new ApplicationDomainAwarePostProcessor(this));
//			objectFactory.addObjectPostProcessor(new ObjectFactoryAwarePostProcessor(this));
//			objectFactory.addObjectPostProcessor(new EventBusAwareObjectPostProcessor(this));
//			objectFactory.addObjectPostProcessor(new ObjectDefinitionRegistryAwareObjectPostProcessor(this.objectDefinitionRegistry));

//			objectFactory.addReferenceResolver(new ThisReferenceResolver(this));
			objectFactory.addReferenceResolver(new ObjectReferenceResolver(this));
//			objectFactory.addReferenceResolver(new ArrayReferenceResolver(this));
//			objectFactory.addReferenceResolver(new DictionaryReferenceResolver(this));
//			objectFactory.addReferenceResolver(new VectorReferenceResolver(this));
//			if (ArrayCollectionReferenceResolver.canCreate(applicationDomain)) {
//				objectFactory.addReferenceResolver(new ArrayCollectionReferenceResolver(this));
//			}

			
			applicationContextInitializer =  new RockdotApplicationContextInitializer();
			
			var provider:XMLObjectDefinitionsProvider = new XMLObjectDefinitionsProvider((source != null) ? [source] : null);
			addDefinitionProvider(provider);
			
			/* XML Preprocessor, replacing language placeholders */
			provider.addPreprocessor(new CorePropertyImportPreprocessor(RockdotConstants.LANGUAGE));

			/* XML Namespace Handlers for rockdot:page and rockdot:transition */
			provider.addNamespaceHandler(new RockdotCoreNamespaceHandler());
			
			/* MVC Postprocessor (BaseEvent + CoreCommand) */
			addObjectFactoryPostProcessor( 		new CoreMVCControllerObjectFactoryPostProcessor(-98) );
			
			
		}
		
		public function initApplication(completeCallback : Function, errorCallback : Function) : void {
			/* initializing the UI is mandatory, but feel free to add other commands */
			var compositeCommand : CompositeCommandWithEvent = new CompositeCommandWithEvent(CompositeCommandKind.SEQUENCE);


			var array : Array = RockdotConstants.getBootstrap();
			for (var i : int = 0; i < array.length; i++) {
				
				compositeCommand.addCommandEvent(new RockdotEvent(array[i]), this);
			}

		
			/* add sequence listeners */
			compositeCommand.addCompleteListener(completeCallback);
			compositeCommand.addErrorListener(errorCallback);
			compositeCommand.execute();
		}

		private function createDefaultObjectFactory(parent:IApplicationContext):IObjectFactory {
			var defaultObjectFactory:DefaultObjectFactory = new DefaultObjectFactory(parent);
			defaultObjectFactory.objectDefinitionRegistry = new DefaultObjectDefinitionRegistry();
			defaultObjectFactory.cache = new DefaultInstanceCache();
			return defaultObjectFactory;
		}

	}
}
