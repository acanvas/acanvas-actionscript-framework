package com.rockdot.project.command {
	import com.facebook.graph.data.FacebookSession;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.CompositeCommandWithEvent;
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.command.event.FBEvents;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.ugc.command.event.UGCEvents;
	import com.rockdot.plugin.ugc.inject.IUGCModelAware;
	import com.rockdot.plugin.ugc.model.UGCModel;

	import org.as3commons.async.command.CompositeCommandKind;
	import org.as3commons.async.operation.event.OperationEvent;

	public class LoginCommand extends CoreCommand implements IFBModelAware, IUGCModelAware {
		protected var _fbModel : FBModel;

		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}

		protected var _ugcModel : UGCModel;

		public function set ugcModel(ugcModel : UGCModel) : void {
			_ugcModel = ugcModel;
		}

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			

			var strWantPerms : String = getProperty("layer.prelogin." + event.data.prompt);
			var arrWantPerms : Array = strWantPerms.split(",");
			var count : int = 0;
			if (_fbModel.userIsAuthenticated) {
				for (var i : int = 0; i < arrWantPerms.length; i++) {
					if (_fbModel.userPermissions[0][arrWantPerms[i]]) {
						count++;
					}
				}
			}
			
			var compositeCommand : CompositeCommandWithEvent = new CompositeCommandWithEvent(CompositeCommandKind.SEQUENCE);
			compositeCommand.addCommandEvent(new RockdotEvent(StateEvents.ADDRESS_SET, "/layer/loading"), _context);

			if (!RockdotConstants.LOCAL) {
				if (!_fbModel.userIsAuthenticated || count != arrWantPerms.length) {
					compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.USER_LOGIN, arrWantPerms), _context);
				}
				if (!_fbModel.user) {
					compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.USER_GETINFO), _context);
				}
				if (!_fbModel.friends) {
					// not needed in this project
					compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.FRIENDS_GET), _context);
					compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.FRIENDS_GETINFO), _context);
				}
				
				if(strWantPerms.indexOf("user_photos")!=-1){
					compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.ALBUMS_GET), _context);
				}

				compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.USER_GETINFO_PERMISSIONS), _context);
			}

			if (_ugcModel && !_ugcModel.userDAO) {
				compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.USER_REGISTER), _context);
				compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.USER_REGISTER_EXTENDED), _context);
			}

			//we don't need to go back from loading layer, as there will be a redirect after login, anyways
//			compositeCommand.addCommandEvent(new RockdotEvent(StateEvents.STATE_VO_BACK), _context);

			compositeCommand.failOnFault = true;
			compositeCommand.addCompleteListener(_handleComplete);
			compositeCommand.addErrorListener(_handleError);
			compositeCommand.execute();
			return null;
		}

		private function _handleComplete(event : OperationEvent = null) : void {
			if (RockdotConstants.LOCAL == true) {
				_fbModel.session = new FacebookSession();
				_fbModel.session.accessToken = "FAKE";
				_fbModel.session.uid = _ugcModel.userDAO.uid;
			}
			
			dispatchCompleteEvent(_ugcModel.userDAO);
		}
	}
}