package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.model.vo.UGCItemContainerVO;
	import com.rockdot.plugin.ugc.model.vo.UGCTaskVO;

	public class UGCReadItemContainerCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);			
			//event.data == id INT
			amfOperation("UGCEndpoint.readItemContainer", event.data);
		}
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			var ret : UGCItemContainerVO;
			if(result.result.length > 0){
				ret = new UGCItemContainerVO(result.result[0]);
				ret.items = result.result[0].items;
				ret.roles = result.result[0].roles;
				ret.task = new UGCTaskVO(result.result[0].task);
				_ugcModel.currentItemContainerDAO = ret;
			}
			return super.dispatchCompleteEvent( ret );
		}
	}
}