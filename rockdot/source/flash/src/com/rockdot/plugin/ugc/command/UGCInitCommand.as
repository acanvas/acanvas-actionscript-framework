package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;

	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;


	public class UGCInitCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

            log.info("Connecting to AMF Host: " + _context.propertiesProvider.getProperty("project.host.amf"));
			
			var nc : NetConnection = new NetConnection();
            nc.addEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
			var url : String = _context.propertiesProvider.getProperty("project.host.amf");
			nc.connect(url);
			_ugcModel.service = nc;
			
			dispatchCompleteEvent();
		}

		private function _securityErrorHandler(event : SecurityErrorEvent) : void {
			log.error(event.text);
		}

		private function _netStatusHandler(event : NetStatusEvent) : void {
			//possible values see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/NetStatusEvent.html#NET_STATUS
            log.info("NetStatusEvent.NET_STATUS: " + event.info.code);
		}
	}
}