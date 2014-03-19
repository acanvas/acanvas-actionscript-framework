package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.plugin.ugc.command.event.vo.UGCFilterVO;


	public class UGCFilterItemCommand extends AbstractUGCCommand implements IStateModelAware {
		protected var _stateModel : StateModel;
		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			
			var vo : UGCFilterVO = event.data;
			
			switch(vo.condition) {
				case UGCFilterVO.CONDITION_FRIENDS:
					vo.creator_uids = _ugcModel.friendsWithUGCItems;
					break;
				case UGCFilterVO.CONDITION_ME:
					vo.creator_uid = _ugcModel.userDAO.uid;
					break;
				case UGCFilterVO.CONDITION_UGC_ID:
					var id : int = parseInt(_stateModel.currentStateVO.params["id"]);
					vo.item_id = id;
					break;
				case UGCFilterVO.CONDITION_ALL:
					break; 	 
				case UGCFilterVO.CONDITION_UID:
					break;
			}
			
			//TODO ??? delete?
//			if(event && event.data is String) {
//				vo.condition = event.data;
//			}
			
			amfOperation("UGCEndpoint.filterItems", vo);

			return null;
		}

		
	}
}