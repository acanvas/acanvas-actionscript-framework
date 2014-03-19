package com.rockdot.plugin.@plugin.package@ {
	import com.rockdot.core.spring.CoreContextHelper;
	import flash.utils.Dictionary;
	import com.rockdot.plugin.@plugin.package@.command.@plugin.class.prefix@InitCommand;
	import com.rockdot.plugin.@plugin.package@.command.event.@plugin.class.prefix@Events;
	import com.rockdot.plugin.@plugin.package@.model.@plugin.class.prefix@Model;
	
	import org.springextensions.actionscript.ioc.factory.config.IConfigurableListableObjectFactory;
	import org.springextensions.actionscript.ioc.factory.config.IObjectFactoryPostProcessor;

	public class @plugin.class.prefix@Plugin  implements IObjectFactoryPostProcessor{

		public function postProcessObjectFactory(objectFactory : IConfigurableListableObjectFactory) : void {
			
			var commandMap : Dictionary = new Dictionary();
			
			commandMap[ @plugin.class.prefix@Events.INIT ] = @plugin.class.prefix@InitCommand; 
			
			CoreContextHelper.registerCommands(objectFactory, commandMap);
			
			/* Models */
			CoreContextHelper.registerClass(objectFactory, "@plugin.class.prefix@Model", @plugin.class.prefix@Model, true);
		}


	}
}