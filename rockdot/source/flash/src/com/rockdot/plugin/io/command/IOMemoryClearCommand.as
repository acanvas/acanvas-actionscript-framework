package com.rockdot.plugin.io.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.command.AbstractScreenCommand;

	import org.as3commons.lang.ClassUtils;
	import org.as3commons.reflect.MetadataUtils;
	import org.as3commons.reflect.Type;

	import flash.system.System;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class IOMemoryClearCommand extends AbstractScreenCommand {
		
		override public function execute(event : RockdotEvent = null) : * {
			log.debug("System memory before CLEAR: " + System.totalMemory);
			log.debug("Free memory before CLEAR: " + System.freeMemory);
			
			
			ClassUtils.clearDescribeTypeCache();
			Type.getTypeProvider().clearCache();
			MetadataUtils.clearCache();
			System.gc();

			log.debug("System memory after CLEAR: " + System.totalMemory);
			log.debug("Free memory after CLEAR: " + System.freeMemory);

			dispatchCompleteEvent();
		}
	}
}
