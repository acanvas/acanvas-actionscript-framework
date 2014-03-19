package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;






	public class GamingGetHighscoreCommand extends AbstractUGCCommand implements IFBModelAware{
		private var _modelFB : FBModel;
		public function set fbModel(model : FBModel) : void {
			_modelFB = model;
		}

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			amfOperation("GamingEndpoint.getHighscore", {uid:_ugcModel.userDAO.uid, friends:_modelFB.friendsWhoAreAppUsersIndexed});
		}
		
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			_ugcModel.gaming.highscoreFriends = result.result.topFiveFriends;
			_ugcModel.gaming.highscoreAll = result.result.topTen;
			_ugcModel.gaming.rank = result.result.rank;
			return super.dispatchCompleteEvent(result.result);
		}
	}
}