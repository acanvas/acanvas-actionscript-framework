package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.facebook.model.vo.FBUserVO;

	import org.as3commons.async.operation.event.OperationEvent;



	public class UGCFriendsReadCommand extends AbstractUGCCommand implements IFBModelAware{
		private var _modelFB : FBModel;
		public function set fbModel(model : FBModel) : void {
			_modelFB = model;
		}

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			if(!_modelFB.friendsWhoAreAppUsers) {
				dispatchCompleteEvent(new Array());
				return null;
			}
			
			var arr : Array = [];
			for ( var k : String in _modelFB.friendsWhoAreAppUsers ) {
				arr.push(_modelFB.friendsWhoAreAppUsers[ k ].id);
			}
			
			amfOperation("UGCEndpoint.getFriendsWithItems", arr);
			
			return null;
		}

		private function _handleComplete(event : OperationEvent) : void {
			var arr : Array = [];
			
			for (var i : Number = 0;i < event.result.length;i++) {
				var user : FBUserVO = _modelFB.friendsWhoAreAppUsers[event.result[i]];
				arr.push(user);
			}
			
			_ugcModel.friendsWithUGCItems = arr;
			dispatchCompleteEvent(arr);
		}

		
	}
}