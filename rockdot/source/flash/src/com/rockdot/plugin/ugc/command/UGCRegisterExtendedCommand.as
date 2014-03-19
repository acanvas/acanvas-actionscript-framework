package com.rockdot.plugin.ugc.command {
	import com.jvm.utils.DateUtils;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.ugc.model.vo.UGCUserExtendedVO;

	public class UGCRegisterExtendedCommand extends AbstractUGCCommand implements IFBModelAware{
		private var _modelFB : FBModel;
		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
//			dispatchMessage("loading.backend.login");
			
			var amfObject : *;
			
			if (event.data is UGCUserExtendedVO) {
				amfObject = event.data;
				_ugcModel.userExtendedDAO = new UGCUserExtendedVO(amfObject);
			} else if (RockdotConstants.LOCAL && RockdotConstants.DEBUG) {
				_ugcModel.userExtendedDAO = _createDummyData();
				amfObject = _ugcModel.userExtendedDAO;
			} else if (!_ugcModel.userExtendedDAO){
				var user : UGCUserExtendedVO = new UGCUserExtendedVO();
				user.hometown_location = _modelFB.user.hometown_location;
				user.email = _modelFB.user.email;
				user.email_confirmed = 1;
				user.birthday_date = _modelFB.user.birthday_date;
				user.firstname = "";
				user.lastname = "";
				user.street = "";
				user.city = "";
				_ugcModel.userExtendedDAO = user;
				amfObject = _ugcModel.userExtendedDAO;
			}

			_ugcModel.userExtendedDAO.uid = _ugcModel.userDAO.uid;
			amfObject.uid = _ugcModel.userExtendedDAO.uid;
			_ugcModel.userExtendedDAO.hash = String(Math.random() * DateUtils.getTimeInMilliseconds(new Date()));
			amfObject.hash = _ugcModel.userExtendedDAO.hash;
			
			_ugcModel.hasUserExtendedDAO = true;
			amfOperation("UGCEndpoint.createUserExtended", amfObject);
		}
		
		private function _createDummyData() : UGCUserExtendedVO {
			var user : UGCUserExtendedVO = new UGCUserExtendedVO();
			user.hometown_location = "Stuttgart, Germany";
			user.email = "anna-maria.fincke@jvm-neckar.de";
			user.email_confirmed = 1;
			user.birthday_date = "1981-12-24";
			user.title = "Ms";
			user.firstname = "Anna-Maria";
			user.lastname = "Fincke";
			user.street = "Neckarstraße 155";
			user.city = "70190 Stuttgart";
			user.country = "DE";
			return user;
		}
		
		public function set fbModel(model : FBModel) : void {
			_modelFB = model;
		}
	}
}