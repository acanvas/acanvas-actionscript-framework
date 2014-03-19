package com.rockdot.plugin.tracking.omniture.command {
	import com.greensock.TweenLite;
	import com.omniture.AppMeasurement;
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.inject.ScreenServiceAware;
	import com.rockdot.plugin.screen.common.service.IScreenService;
	import com.rockdot.plugin.tracking.omniture.inject.IOmnitureModelAware;
	import com.rockdot.plugin.tracking.omniture.model.OmnitureModel;



	public class OmnitureInitCommand extends CoreCommand implements IOmnitureModelAware, ScreenServiceAware{
		protected var _omnitureModel : OmnitureModel;
		public function set omnitureModel(omnitureModel : OmnitureModel) : void {
			_omnitureModel = omnitureModel;
		}
		
		protected var _uiService : IScreenService;
		public function set uiService(uiService : IScreenService) : void {
			_uiService = uiService;
		}
		
		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			_omnitureModel.tracker = new AppMeasurement();
			_uiService.stage.addChild(_omnitureModel.tracker);
			
			TweenLite.delayedCall(.1, dispatchCompleteEvent);
			return null;
		}

	}
}