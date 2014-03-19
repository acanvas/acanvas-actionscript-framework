package com.rockdot.project.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.ugc.inject.IUGCModelAware;
	import com.rockdot.plugin.ugc.model.UGCModel;
	import com.rockdot.plugin.ugc.model.vo.UGCUserVO;
	import com.rockdot.project.command.event.ProjectEvents;

	/** 
	 * Called by the initialization Command Sequence inside of @see Application
	 */
	public class PermissionDispatchCommand extends AbstractCommand implements IFBModelAware, IUGCModelAware {
		private var _ugcModel : UGCModel;
		private var _event : RockdotEvent;

		public function set ugcModel(ugcModel : UGCModel) : void {
			_ugcModel = ugcModel;
		}

		private var _fbModel : FBModel;

		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}

		override public function execute(event : RockdotEvent = null) : * {
			_event = event;
			super.execute(event);

			// comparison check: which permissions do we have, and which do we want?
			var wantPerms : Array = getProperty("layer.prelogin." + _event.data.prompt).split(",");
			var count : int = 0;
			if (_fbModel.userIsAuthenticated) {
				for (var i : int = 0; i < wantPerms.length; i++) {
					if (_fbModel.userPermissions[0][wantPerms[i]]) {
						count++;
					}
				}
				if (count == wantPerms.length) {
					switch(_event.data.prompt) {
						case "facebook.friends":
							if(_fbModel.friends){
								// user is already logged in and has given all permissions required
								_onLogin(_ugcModel.userDAO);
							}
							else{
								new RockdotEvent(ProjectEvents.APP_LOGIN, _event.data.prompt, _onLogin).dispatch();
							}
							break;
						case "facebook.albums":
							if(_fbModel.userAlbums){
								// user is already logged in and has given all permissions required
								_onLogin(_ugcModel.userDAO);
							} else {
								new RockdotEvent(ProjectEvents.APP_LOGIN, _event.data.prompt, _onLogin).dispatch();
							}
							break;
						default:
							if(_ugcModel.userDAO){
								new RockdotEvent(StateEvents.ADDRESS_SET, _event.data.next).dispatch();
							}
							else{
								new RockdotEvent(ProjectEvents.APP_LOGIN, _event.data.prompt, _onLogin).dispatch();
							}
							break;
					}
				}
			} else {
				new RockdotEvent(StateEvents.ADDRESS_SET, "/layer/prelogin?prompt=" + event.data.prompt + "&next=" + event.data.next).dispatch();
			}

			return null;
		}

		private function _onLogin(dao : UGCUserVO) : void {
			// some permission prompts have special operations. most of them want to go to the _data.next address
			new RockdotEvent(ProjectEvents.APP_AFTERLOGIN_DISPATCH, _event.data, dispatchCompleteEvent).dispatch();

		}
	}
}