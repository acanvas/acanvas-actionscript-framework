package com.rockdot.plugin.screen.displaylist.service {
	import com.rockdot.plugin.screen.common.service.AbstractScreenService;
	import com.rockdot.plugin.screen.common.service.IScreenService;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;



	/**
	 * @author nilsdoehring
	 */
	public class ScreenDisplaylistService extends AbstractScreenService{
		
		protected static var log : ILogger = getLogger(IScreenService);			
		

		public function ScreenDisplaylistService() {
			super();
				
		}
		
		
		override public function init(callback : Function = null) : void {
			
			super.init(callback);
		}

	}
}
