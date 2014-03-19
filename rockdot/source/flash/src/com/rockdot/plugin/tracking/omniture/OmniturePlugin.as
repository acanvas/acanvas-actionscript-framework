package com.rockdot.plugin.tracking.omniture {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.tracking.omniture.command.OmnitureInitCommand;
	import com.rockdot.plugin.tracking.omniture.command.OmnitureLinkTrackingCommand;
	import com.rockdot.plugin.tracking.omniture.command.OmniturePageTrackingCommand;
	import com.rockdot.plugin.tracking.omniture.command.event.OmnitureEvents;
	import com.rockdot.plugin.tracking.omniture.inject.OmnitureModelInjector;
	import com.rockdot.plugin.tracking.omniture.model.OmnitureModel;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;

	import flash.utils.Dictionary;


	

	public class OmniturePlugin  implements IObjectFactoryPostProcessor {
		public static const MODEL_OMNITURE : String = "MODEL_OMNITURE";

		public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			
			var commandMap : Dictionary = new Dictionary();
			
			commandMap[ OmnitureEvents.INIT ] = OmnitureInitCommand; 
			commandMap[ OmnitureEvents.TRACK_LINK ] = OmniturePageTrackingCommand; 
			commandMap[ OmnitureEvents.TRACK_PAGE ] = OmnitureLinkTrackingCommand; 
			
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			/* Models */
			RockdotHelper.registerClass(objectFactory, MODEL_OMNITURE, OmnitureModel, true);
			
			/* Object Postprocessor */
			objectFactory.addObjectPostProcessor(new OmnitureModelInjector(objectFactory));
			
			return null;
		}
		
		
		public static function getInitCommandEvent(data:*=null):RockdotEvent{
			return new RockdotEvent(OmnitureEvents.INIT, data);
		}

	}
}