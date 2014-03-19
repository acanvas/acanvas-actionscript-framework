package com.rockdot.plugin.io {
	import com.jvm.utils.DeviceDetector;
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.plugin.io.command.IOImageSaveAsFromAIRCommand;
	import com.rockdot.plugin.io.command.IOImageSaveAsFromBrowserCommand;
	import com.rockdot.plugin.io.command.IOImageSaveToCameraRollCommand;
	import com.rockdot.plugin.io.command.IOImageUploadCommand;
	import com.rockdot.plugin.io.command.IOLoadFileFromBrowserCommand;
	import com.rockdot.plugin.io.command.IOLoadFileFromCameraRollCommand;
	import com.rockdot.plugin.io.command.IOLoadFileFromDiskCommand;
	import com.rockdot.plugin.io.command.IOLoadImageCommand;
	import com.rockdot.plugin.io.command.IOLoadJSONCommand;
	import com.rockdot.plugin.io.command.IOLoadMediaPromiseCommand;
	import com.rockdot.plugin.io.command.IOMemoryClearCommand;
	import com.rockdot.plugin.io.command.IOOpenURLCommand;
	import com.rockdot.plugin.io.command.event.IOEvents;
	import com.rockdot.plugin.io.inject.IOModelInjector;
	import com.rockdot.plugin.io.model.IOModel;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.AbstractOrderedFactoryPostProcessor;

	import flash.utils.Dictionary;





	/**
	 * @flowerModelElementId _0kyygC9LEeG0Qay4mHgS6g
	 */
	public class IOPlugin extends AbstractOrderedFactoryPostProcessor {
		public static const MODEL_IO : String = "MODEL_IO";

		public function IOPlugin() {
			super(50);
		}


		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			
			/* Objects */
			RockdotHelper.registerClass(objectFactory, MODEL_IO, IOModel, true);
			
			/* Object Postprocessors */
			objectFactory.addObjectPostProcessor(new IOModelInjector(objectFactory));
			
			/* Commands */
			var commandMap : Dictionary = new Dictionary();
			
			commandMap[ IOEvents.MEMORY_CLEAR ] = IOMemoryClearCommand;
			commandMap[ IOEvents.URL_OPEN ] = IOOpenURLCommand;
			commandMap[ IOEvents.IMAGE_LOAD_WEB ] = IOLoadImageCommand; 
			commandMap[ IOEvents.IMAGE_UPLOAD ] = IOImageUploadCommand; 
			commandMap[ IOEvents.LOAD_JSON ] = IOLoadJSONCommand; 
			
			if(DeviceDetector.IS_MOBILE){
				commandMap[ IOEvents.IMAGE_LOAD_DISK ] = IOLoadFileFromCameraRollCommand; 
				commandMap[ IOEvents.LOAD_MEDIAPROMISE ] = IOLoadMediaPromiseCommand;
				commandMap[ IOEvents.IMAGE_SAVE_LOCAL ] = IOImageSaveToCameraRollCommand;
			}
			else if(DeviceDetector.IS_DESKTOP){
				commandMap[ IOEvents.IMAGE_LOAD_DISK ] = IOLoadFileFromDiskCommand; 
				commandMap[ IOEvents.IMAGE_SAVE_LOCAL ] = IOImageSaveAsFromAIRCommand;
			}
			else{
				commandMap[ IOEvents.IMAGE_LOAD_DISK ] = IOLoadFileFromBrowserCommand; 
				commandMap[ IOEvents.IMAGE_SAVE_LOCAL ] = IOImageSaveAsFromBrowserCommand;
			}

			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			/* Bootstrap Command */
			RockdotConstants.getBootstrap().push( IOEvents.MEMORY_CLEAR );
			
			
			return null;
		}
		
	}
}