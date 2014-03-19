package com.rockdot.plugin.tracking.etracker {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.tracking.etracker.command.ETrackerTrackingCommand;
	import com.rockdot.plugin.tracking.etracker.command.EtrackerInitCommand;
	import com.rockdot.plugin.tracking.etracker.command.event.EtrackerEvents;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;

	import flash.utils.Dictionary;


	

	public class EtrackerPlugin  implements IObjectFactoryPostProcessor{

		public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			
			var commandMap : Dictionary = new Dictionary();
			
			commandMap[ EtrackerEvents.INIT ] 			= EtrackerInitCommand; 
			commandMap[ EtrackerEvents.TRACK_PAGE ] 	= ETrackerTrackingCommand; 
			
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			return null;
		}

		
		public static function getInitCommandEvent(data:*=null):RockdotEvent{
			return new RockdotEvent(EtrackerEvents.INIT, data);
		}
		
	}
}