package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;

	public class UGCReadItemCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);			
			//event.data == id INT
			amfOperation("UGCEndpoint.readItem", event.data);
		}
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			var ret : UGCItemVO;
			if(result.result.length > 0){
				ret = new UGCItemVO(result.result[0]);
				_ugcModel.currentItemDAO = ret;
			}
			return super.dispatchCompleteEvent( ret );
		}
	}
}