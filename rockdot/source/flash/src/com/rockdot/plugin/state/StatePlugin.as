package com.rockdot.plugin.state {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.plugin.state.command.StateAddressSetCommand;
	import com.rockdot.plugin.state.command.StateBackCommand;
	import com.rockdot.plugin.state.command.StateForwardCommand;
	import com.rockdot.plugin.state.command.StatePluginInitCommand;
	import com.rockdot.plugin.state.command.StateRequestCommand;
	import com.rockdot.plugin.state.command.StateSetCommand;
	import com.rockdot.plugin.state.command.StateSetParamsCommand;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.inject.StateModelInjector;
	import com.rockdot.plugin.state.model.StateConstants;
	import com.rockdot.plugin.state.model.StateModel;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.AbstractOrderedFactoryPostProcessor;

	import flash.utils.Dictionary;


	/**
	 * @flowerModelElementId _0bg6sC9LEeG0Qay4mHgS6g
	 */
	public class StatePlugin extends AbstractOrderedFactoryPostProcessor {

		public function StatePlugin() {
			super(10);
		}


		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			
			/* Objects */
			RockdotHelper.registerClass(objectFactory, StateConstants.CTX_MODEL_STATE, StateModel, true);

			/* Object Postprocessors */
			objectFactory.addObjectPostProcessor(new StateModelInjector(objectFactory));
			
			/* Commands */
			var commandMap : Dictionary = new Dictionary();
			commandMap[ StateEvents.INIT ] = StatePluginInitCommand; 
			
			// 1. dispatched by button, sent to proxy
			commandMap[StateEvents.ADDRESS_SET] = StateAddressSetCommand;

			// 2. select page vo by url, received from proxy
			commandMap[StateEvents.STATE_REQUEST] = StateRequestCommand;
			
			// 3. set page vo
			commandMap[StateEvents.STATE_VO_SET] = StateSetCommand;
			commandMap[StateEvents.STATE_VO_FORWARD] = StateForwardCommand;
			commandMap[StateEvents.STATE_VO_BACK] = StateBackCommand;

			// 4b. if it's the same state, only change params 
			commandMap[StateEvents.STATE_PARAMS_CHANGE] = StateSetParamsCommand;
			
			RockdotHelper.registerCommands(objectFactory, commandMap);

			
			/* Bootstrap Command */
			RockdotConstants.getBootstrap().push( StateEvents.INIT );
			
			
			return null;
		}
		


	}
}