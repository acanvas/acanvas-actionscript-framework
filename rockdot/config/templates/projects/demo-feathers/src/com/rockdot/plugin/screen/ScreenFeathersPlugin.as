package com.rockdot.plugin.screen {
	import feathers.controls.ScreenNavigator;

	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.plugin.screen.common.ScreenPluginBase;
	import com.rockdot.plugin.screen.displaylist3d.inject.Stage3DProxyInjector;
	import com.rockdot.plugin.screen.feathers.command.ScreenFeathersSetCommand;
	import com.rockdot.plugin.screen.feathers.command.event.ScreenFeathersEvents;
	import com.rockdot.plugin.screen.feathers.service.ScreenFeathersService;
	import com.rockdot.plugin.state.command.event.StateEvents;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;

	import flash.utils.Dictionary;





	/**
	 * @flowerModelElementId _0kyygC9LEeG0Qay4mHgS6g
	 */
	public class ScreenFeathersPlugin extends ScreenPluginBase {
		public static const FEATHERS_SCREEN_NAVIGATOR : String 	= "FEATHERS_SCREEN_NAVIGATOR";

		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			super.postProcessObjectFactory(objectFactory);
			
			/* Objects */
			RockdotHelper.registerClass(objectFactory, FEATHERS_SCREEN_NAVIGATOR, ScreenNavigator, true);
			RockdotHelper.registerClass(objectFactory, ScreenPluginBase.SERVICE_UI, ScreenFeathersService, true);
			
			/* Object Postprocessors */
			objectFactory.addObjectPostProcessor(new Stage3DProxyInjector(objectFactory));
			
			/* Commands */
			var commandMap : Dictionary = new Dictionary();
			commandMap[ ScreenFeathersEvents.TRANSITION ] = ScreenFeathersEvents; 
			commandMap[ StateEvents.STATE_CHANGE ] = ScreenFeathersSetCommand; 
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			return null;
		}
		
	}
}