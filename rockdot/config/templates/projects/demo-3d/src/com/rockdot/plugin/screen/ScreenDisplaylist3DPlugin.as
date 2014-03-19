package com.rockdot.plugin.screen {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.plugin.screen.common.ScreenPluginBase;
	import com.rockdot.plugin.screen.displaylist3d.inject.Stage3DProxyInjector;
	import com.rockdot.plugin.screen.displaylist3d.service.ScreenDisplaylist3DService;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;



	/**
	 * @flowerModelElementId _0kyygC9LEeG0Qay4mHgS6g
	 */
	public class ScreenDisplaylist3DPlugin extends ScreenDisplaylistPlugin {

		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			super.postProcessObjectFactory(objectFactory);
			
			/* Object Postprocessors */
			objectFactory.addObjectPostProcessor(new Stage3DProxyInjector(objectFactory));
			return null;
		}
		
		override protected function _registerService(objectFactory : IObjectFactory) : void {
			RockdotHelper.registerClass(objectFactory, ScreenPluginBase.SERVICE_UI, ScreenDisplaylist3DService, true);
		}
		
	}
}