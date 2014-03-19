package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.ugc.model.vo.UGCUserVO;

	import flash.system.Capabilities;


	public class UGCRegisterCommand extends AbstractUGCCommand implements IFBModelAware {
		protected var _fbModel : FBModel;
		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}
		
		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
//			dispatchMessage("loading.backend.login");

			if (event.data is UGCUserVO) {
				_ugcModel.userDAO = event.data;
			} else if (RockdotConstants.LOCAL && RockdotConstants.DEBUG) {
				_ugcModel.userDAO = _createDummyData();
			} else if (!_ugcModel.userDAO){
				var user : UGCUserVO = new UGCUserVO();
				user.network = UGCUserVO.NETWORK_FACEBOOK;
				user.name = _fbModel.user.name;
				user.pic = _fbModel.user.pic_square;
				user.uid = _fbModel.user.uid;
				user.locale = _fbModel.user.locale;
				_ugcModel.userDAO = user;
			}
			_ugcModel.userDAO.device = Capabilities.os;
			amfOperation("UGCEndpoint.login", _ugcModel.userDAO);
		}
		
		
		
		private function _createDummyData() : UGCUserVO {
			var user : UGCUserVO = new UGCUserVO();
			user.network = UGCUserVO.NETWORK_INPUTFORM;
			user.name = "Fake User";
			user.pic = "http://profile.ak.fbcdn.net/static-ak/rsrc.php/v1/yo/r/UlIqmHJn-SK.gif";
			user.uid = "1234-fake";
			user.locale = "de_DE";

			return user;
		}

		
	}
}