package com.rockdot.project {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.project.command.InitCommand;
	import com.rockdot.project.command.event.ProjectBaseEvents;
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