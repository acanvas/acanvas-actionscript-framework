package com.rockdot.plugin.screen {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.plugin.screen.common.ScreenPluginBase;
	import com.rockdot.plugin.screen.displaylist.command.ScreenAppearCommand;
	import com.rockdot.plugin.screen.displaylist.command.ScreenApplyEffectInCommand;
	import com.rockdot.plugin.screen.displaylist.command.ScreenApplyEffectOutCommand;
	import com.rockdot.plugin.screen.displaylist.command.ScreenDisappearCommand;
	import com.rockdot.plugin.screen.displaylist.command.ScreenInitCommand;
	import com.rockdot.plugin.screen.displaylist.command.ScreenSetCommand;
	import com.rockdot.plugin.screen.displaylist.command.ScreenTransitionPrepareCommand;
	import com.rockdot.plugin.screen.displaylist.command.ScreenTransitionRunCommand;
	import com.rockdot.plugin.screen.displaylist.command.event.ScreenDisplaylistEvents;
	import com.rockdot.plugin.screen.displaylist.service.ScreenDisplaylistService;
	import com.rockdot.plugin.state.command.event.StateEvents;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;

	import flash.utils.Dictionary;


	/**
	 * @flowerModelElementId _0kyygC9LEeG0Qay4mHgS6g
	 */
	public class ScreenDisplaylistPlugin extends ScreenPluginBase {

		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			super.postProcessObjectFactory(objectFactory);
			
			/* Objects */
			_registerService(objectFactory);

			
			/* Commands */
			var commandMap : Dictionary = new Dictionary();
			commandMap[ ScreenDisplaylistEvents.SCREEN_INIT ] = ScreenInitCommand; 
			commandMap[ ScreenDisplaylistEvents.TRANSITION_PREPARE ] = ScreenTransitionRunCommand; 
			commandMap[ ScreenDisplaylistEvents.APPEAR ] = ScreenAppearCommand; 
			commandMap[ ScreenDisplaylistEvents.DISAPPEAR ] = ScreenDisappearCommand; 
			commandMap[ ScreenDisplaylistEvents.TRANSITION_RUN ] = ScreenTransitionPrepareCommand; 
			commandMap[ ScreenDisplaylistEvents.APPLY_EFFECT_IN ] = ScreenApplyEffectInCommand; 
			commandMap[ ScreenDisplaylistEvents.APPLY_EFFECT_OUT ] = ScreenApplyEffectOutCommand; 
			
			commandMap[ StateEvents.STATE_CHANGE ] = ScreenSetCommand;
			
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			return null;
		}

		protected function _registerService(objectFactory : IObjectFactory) : void {
			RockdotHelper.registerClass(objectFactory, ScreenPluginBase.SERVICE_UI, ScreenDisplaylistService, true);
		}
	}
}