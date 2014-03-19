package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.model.vo.UGCItemContainerVO;

	public class UGCReadItemContainersByUIDCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);			
			if(event.data) {
				amfOperation("UGCEndpoint.readItemContainersByUID", event.data);
			}
			else{
				dispatchErrorEvent("No UID");
			}
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.ownContainers = _createContainers(result.result.ownContainers);
			_ugcModel.followContainers = _createContainers(result.result.followContainers);
			_ugcModel.participantContainers = _createContainers(result.result.participantContainers);
			return super.dispatchCompleteEvent( );
		}

		private function _createContainers(result : Array) : Array {
			var a_ret : Array = [];
			
			if(result.length > 0){
				var ret : UGCItemContainerVO;
				
				for(var i:int=0;i<result.length;i++){
					ret = new UGCItemContainerVO(result[i]);
					a_ret.push(ret);
				}
			}
			
			return a_ret;
		}
	}
}