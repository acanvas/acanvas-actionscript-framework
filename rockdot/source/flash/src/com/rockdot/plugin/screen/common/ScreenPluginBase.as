package com.rockdot.plugin.screen.common {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.plugin.screen.common.command.ScreenPluginInitCommand;
	import com.rockdot.plugin.screen.common.command.ScreenResizeCommand;
	import com.rockdot.plugin.screen.common.command.event.ScreenEvents;
	import com.rockdot.plugin.screen.common.inject.ScreenPluginInjector;
	import com.rockdot.plugin.screen.common.model.ScreenModel;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.AbstractOrderedFactoryPostProcessor;

	import flash.utils.Dictionary;



	/**
	 * @flowerModelElementId _0kyygC9LEeG0Qay4mHgS6g
	 */
	public class ScreenPluginBase extends AbstractOrderedFactoryPostProcessor {
		public static const MODEL_UI : String = "MODEL_UI";
		public static const SERVICE_UI : String = "SERVICE_UI";

		public function ScreenPluginBase() {
			super(20);
		}


		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			
			/* Objects */
			RockdotHelper.registerClass(objectFactory, MODEL_UI, ScreenModel, true);
			
			/* Object Postprocessors */
			objectFactory.addObjectPostProcessor(new ScreenPluginInjector(objectFactory));
			
			/* Commands */
			var commandMap : Dictionary = new Dictionary();
			commandMap[ ScreenEvents.INIT ] = ScreenPluginInitCommand; 
			commandMap[ScreenEvents.RESIZE] = ScreenResizeCommand;
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			/* Bootstrap Command */
			RockdotConstants.getBootstrap().push( ScreenEvents.INIT );
			
			return null;
		}

	}
}