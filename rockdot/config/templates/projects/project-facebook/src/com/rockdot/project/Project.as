package com.rockdot.project {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.project.command.AfterLoginDispatchCommand;
	import com.rockdot.project.command.InitCommand;
	import com.rockdot.project.command.LoginCommand;
	import com.rockdot.project.command.PermissionDispatchCommand;
	import com.rockdot.project.command.event.ProjectBaseEvents;
	import com.rockdot.project.command.event.ProjectExtendedEvents;
	import com.rockdot.project.inject.ModelInjector;
	import com.rockdot.project.model.Model;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.AbstractOrderedFactoryPostProcessor;

	import flash.utils.Dictionary;



	public class Project extends AbstractOrderedFactoryPostProcessor {

		public static const MODEL : String = "MODEL";

		public function Project() {
			super(100);
		}


		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			
			var commandMap : Dictionary = new Dictionary();
			
			/* Initial Project Setup */
			commandMap[ ProjectBaseEvents.APP_INIT ] = InitCommand; 
			
			/* App */
			commandMap[ ProjectExtendedEvents.APP_LOGIN ] = LoginCommand; 
			commandMap[ ProjectExtendedEvents.APP_LOGIN_DISPATCH ] = PermissionDispatchCommand; 
			commandMap[ ProjectExtendedEvents.APP_AFTERLOGIN_DISPATCH ] = AfterLoginDispatchCommand; 
			
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			/* Register Model */
			RockdotHelper.registerClass(objectFactory, MODEL , Model, true);
			
			/* Object Postprocessor */
			objectFactory.addObjectPostProcessor(new ModelInjector(objectFactory));
			
			/* Add Initial Project Setup to Initialization Bootstrap*/
			RockdotConstants.getBootstrap().push( ProjectBaseEvents.APP_INIT );
			
			
			 return null;
		}
	}
}