package com.rockdot.project {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.project.command.AfterLoginDispatchCommand;
	import com.rockdot.project.command.InitCommand;
	import com.rockdot.project.command.LoginCommand;
	import com.rockdot.project.command.PermissionDispatchCommand;
	import com.rockdot.project.command.ProcessImageCommand;
	import com.rockdot.project.command.UploadImageCommand;
	import com.rockdot.project.command.event.ProjectEvents;
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
			/* App */
			commandMap[ ProjectEvents.APP_INIT ] = InitCommand; 
			commandMap[ ProjectEvents.APP_LOGIN ] = LoginCommand; 
			commandMap[ ProjectEvents.APP_LOGIN_DISPATCH ] = PermissionDispatchCommand; 
			commandMap[ ProjectEvents.APP_AFTERLOGIN_DISPATCH ] = AfterLoginDispatchCommand; 
			commandMap[ ProjectEvents.IMAGE_UPLOAD ] = UploadImageCommand; 
			commandMap[ ProjectEvents.IMAGE_PROCESS ] = ProcessImageCommand; 
			
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			RockdotHelper.registerClass(objectFactory, MODEL , Model, true);
			
			/* Object Postprocessor */
			objectFactory.addObjectPostProcessor(new ModelInjector(objectFactory));
			
			RockdotConstants.getBootstrap().push( ProjectEvents.APP_INIT );
			
			
			 return null;
		}
	}
}