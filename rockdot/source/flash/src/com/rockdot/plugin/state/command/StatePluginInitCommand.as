package com.rockdot.plugin.state.command {
	import com.google.analytics.GATracker;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.model.vo.StateVO;
	import com.rockdot.plugin.state.service.SWFAddressService;

	import org.as3commons.lang.Assert;


	public class StatePluginInitCommand extends AbstractStateCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			
			if(!_stateModel.tracker && getProperty("project.api.google.analytics.key")) {
				_stateModel.tracker = new GATracker(RockdotConstants.getStage(), getProperty("project.api.google.analytics.key"), "AS3", false);
			}
			
			Assert.notNull(_context, "the objectFactory argument must not be null");
			var names:Vector.<String> = _context.objectDefinitionRegistry.getObjectDefinitionNamesForType(StateVO);
			if (names != null) {
				for each (var name:String in names){
					var stateVO:StateVO = _context.getObject(name);
					_stateModel.addStateVO(stateVO);
				}
			} else {
			}

			_stateModel.addressService = new SWFAddressService();
			
			dispatchCompleteEvent();
			return null;
		}
	}
}