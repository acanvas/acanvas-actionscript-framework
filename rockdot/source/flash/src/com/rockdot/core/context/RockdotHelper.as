package com.rockdot.core.context {
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.CoreMVCControllerObjectFactoryPostProcessor;
	import com.jvm.utils.DeviceDetector;

	import org.as3commons.lang.ClassUtils;
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionScope;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;
	import org.springextensions.actionscript.mvc.IController;

	import flash.utils.Dictionary;

	public class RockdotHelper{
		
		public static function wire(uie : *) : void {
			RockdotConstants.getContext().wire(uie);
		}

		public static function registerCommands(objectFactory : IObjectFactory, map : Dictionary) : void {
			var controller:IController = objectFactory.getObject(CoreMVCControllerObjectFactoryPostProcessor.CONTROLLER_OBJECT_NAME);
			for (var commandName : String in map) {
				registerCommand(objectFactory, commandName, map[commandName], ObjectDefinitionScope.PROTOTYPE, controller);

			}
		}

		public static function registerCommand(objectFactory : IObjectFactory, commandName : String, clazz : Class, scope : ObjectDefinitionScope, controller : IController = null) : void {
			if(controller == null){
				controller = objectFactory.getObject(CoreMVCControllerObjectFactoryPostProcessor.CONTROLLER_OBJECT_NAME);
			}
			var objectDefinition : ObjectDefinition = new ObjectDefinition(ClassUtils.getFullyQualifiedName(clazz, true));
			objectDefinition.isLazyInit = true;
			objectDefinition.scope = scope;
			objectDefinition.autoWireMode = AutowireMode.NO;
			objectFactory.objectDefinitionRegistry.registerObjectDefinition(commandName, objectDefinition);
			controller.registerCommandForEventType(commandName, commandName, CoreMVCControllerObjectFactoryPostProcessor.DEFAULT_EXECUTE_METHOD_NAME);
		}

		public static function registerClass(objectFactory : IObjectFactory, id : String, clazz : Class, singleton : Boolean = false, isLazyInit : Boolean = true) : void {
			var objectDefinition:ObjectDefinition = new ObjectDefinition(ClassUtils.getFullyQualifiedName(clazz, true));
			objectDefinition.isLazyInit = isLazyInit;
			objectDefinition.scope = singleton ? ObjectDefinitionScope.SINGLETON : ObjectDefinitionScope.PROTOTYPE;
			objectDefinition.autoWireMode = AutowireMode.NO;
			objectFactory.objectDefinitionRegistry.registerObjectDefinition(id, objectDefinition);
		}
		
		public static function getConfigLocation() : String {
			/* Define URL to load from */
			var prefix : String = RockdotConstants.HOST_FRONTEND + RockdotConstants.VERSION + "/" ;

			/* Define Caching */
			var postfix : String = RockdotConstants.DEBUG && !DeviceDetector.IS_MOBILE ? "?" + Math.round(Math.random() * 1000000) : "";

			/* Define Context XML */
			return prefix + "app-context.xml" + postfix;
		}

	}
}