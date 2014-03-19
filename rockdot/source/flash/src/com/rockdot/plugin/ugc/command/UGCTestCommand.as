package com.rockdot.plugin.ugc.command {
	import com.jvm.utils.DateUtils;
	import com.rockdot.core.mvc.CompositeCommandWithEvent;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.ugc.command.event.GamingEvents;
	import com.rockdot.plugin.ugc.command.event.UGCEvents;
	import com.rockdot.plugin.ugc.command.event.vo.UGCRatingVO;
	import com.rockdot.plugin.ugc.model.vo.UGCGameVO;
	import com.rockdot.plugin.ugc.model.vo.UGCImageItemVO;
	import com.rockdot.plugin.ugc.model.vo.UGCItemContainerVO;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;
	import com.rockdot.plugin.ugc.model.vo.UGCUserExtendedVO;
	import com.rockdot.plugin.ugc.model.vo.UGCUserVO;

	import org.as3commons.async.command.CompositeCommandKind;
	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.lang.Assert;


	public class UGCTestCommand extends AbstractUGCCommand {
		private var _itemContainerID : int;
		private var _itemID : int;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			var compositeCommand : CompositeCommandWithEvent = new CompositeCommandWithEvent(CompositeCommandKind.SEQUENCE);
			
			
			/* ******************** REGISTER USER ******************* */
			
			var user : UGCUserVO = new UGCUserVO();
			user.network = UGCUserVO.NETWORK_INPUTFORM;
			user.name = "Test User";
			user.pic = "http://profile.ak.fbcdn.net/static-ak/rsrc.php/v1/yo/r/UlIqmHJn-SK.gif";
			user.uid = "1234567890";
			user.locale = "de_DE";
			
			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.USER_REGISTER, null, _onUserRegister), _context);


			/* ******************** REGISTER USER (EXTENDED) ******************* */
			
			var userExt : UGCUserExtendedVO = new UGCUserExtendedVO();
			userExt.hometown_location = "Musterstadt, Germany";
			userExt.email = "anna-maria.fincke@jvm-neckar.de";
			userExt.email_confirmed = 0;
			userExt.birthday_date = "1981-12-24";
			userExt.firstname = "Anna-Maria";
			userExt.lastname = "Fincke";
			userExt.street = "Neckarstraße 155";
			userExt.city = "70190 Stuttgart";
			
			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.USER_REGISTER_EXTENDED, userExt, _onUserRegisterExtended), _context);


			/* ******************** SEND CONFIRMATION MAIL ******************* */

			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.USER_MAIL_SEND, null, _onMailSent), _context);
			
			
			/* ******************** CREATE ITEM CONTAINER ******************* */

			var albumVO : UGCItemContainerVO = new UGCItemContainerVO();
			albumVO.creator_uid = _ugcModel.userDAO.uid;
			albumVO.title = "Album von " + _ugcModel.userDAO.name;

			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.CREATE_ITEM_CONTAINER, albumVO, _onCreateItemContainer), _context);


			/* ******************** CREATE IMAGE ITEM ******************* */
			
			//Database Item VO
			var itemDAO : UGCItemVO = new UGCItemVO();
			itemDAO.title = "Test Image Title";
			itemDAO.description = "Test Image Description";
			
			var filenamePrefix : String = String(Math.random() * DateUtils.getTimeInMilliseconds(new Date()));
			var filenameBig : String = filenamePrefix + ".jpg";
			var filenameThumb : String = filenamePrefix + "_thumb.jpg";
		
			
			var imageDAO : UGCImageItemVO = event.data[0];
			imageDAO.url_big = getProperty("project.host.download") + "/" + filenameBig;
			imageDAO.url_thumb = getProperty("project.host.download") + "/" + filenameThumb;
			imageDAO.w = 100;
			imageDAO.h = 100;
			
			itemDAO.type = UGCItemVO.TYPE_IMAGE;
			itemDAO.type_dao = imageDAO;
			
			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.CREATE_ITEM, itemDAO, _onCreateItem), _context);
			
			
			/* ******************** READ ITEM CONTAINER ******************* */

			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.READ_ITEM_CONTAINER, _itemContainerID, _onReadItemContainer), _context);
			
			
			/* ******************** READ ITEM ******************* */

			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.READ_ITEM, _itemID, _onReadItem), _context);


			/* ******************** READ ITEM CONTAINER(S) BY UID ******************* */

			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.READ_ITEM_CONTAINERS_UID, null, _onReadItemByUID), _context);
			
			
			/* ******************** LIKE ITEM ******************* */

			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.ITEM_LIKE, _itemID, _onLikeOrComplainOrRateItem), _context);
			
			
			/* ******************** COMPLAIN ITEM ******************* */
			
			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.ITEM_COMPLAIN, _itemID, _onLikeOrComplainOrRateItem), _context);
			
			
			/* ******************** RATE ITEM ******************* */
			
			var rateItem : UGCRatingVO = new UGCRatingVO(_itemID, 3);
			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.ITEM_RATE, rateItem, _onLikeOrComplainOrRateItem), _context);


			/* ******************** SET GAME SCORE ******************* */
			
			var game : UGCGameVO = new UGCGameVO();
			game.level = 1;
			game.score = 1000;
			compositeCommand.addCommandEvent(new RockdotEvent(GamingEvents.SET_SCORE_AT_LEVEL, game, _onSetScore), _context);
			

			/* ******************** GET GAME HIGHSCORE ******************* */
			
			compositeCommand.addCommandEvent(new RockdotEvent(GamingEvents.GET_HIGHSCORE, null, _onGetHighscore), _context);
			
			
			
			compositeCommand.failOnFault = true;
			compositeCommand.addCompleteListener(dispatchCompleteEvent);
			compositeCommand.addErrorListener(_handleError);
			compositeCommand.execute();
		}


	
		private function _onUserRegister(event : OperationEvent = null) : void {
			log.debug("_onUserRegister, Insert ID: " + event.result + "(0 if user already present)");
			Assert.notNull(event.result, "event.result is null");
		}

		private function _onUserRegisterExtended(event : OperationEvent = null) : void {
			log.debug("_onUserRegisterExtended, Insert ID: " + event.result + "(0 if extended user already present)");
			Assert.notNull(event.result, "event.result is null");
		}

		private function _onCreateItemContainer(event : OperationEvent = null) : void {
			log.debug("_onCreateItemContainer, Insert ID: " + event.result + "(0 if container already present)");
			Assert.notNull(event.result, "event.result is null");
			_itemContainerID = event.result;
		}

		private function _onCreateItem(event : OperationEvent = null) : void {
			log.debug("_onCreateItemContainer, Insert ID: " + event.result + "(0 if item already present)");
			Assert.notNull(event.result, "event.result is null");
			_itemID = event.result;
		}

		private function _onReadItemContainer(container : UGCItemContainerVO) : void {
			Assert.notNull(container, "_onReadItemContainer, container is null");
			Assert.notNull(_ugcModel.currentItemContainerDAO, "_onReadItemContainer, _ugcModel.currentItemContainerDAO is null");
		}

		private function _onReadItemByUID() : void {
			log.debug("_ugcModel.ownContainers: " + _ugcModel.ownContainers);
			log.debug("_ugcModel.followContainers: " + _ugcModel.followContainers);
			log.debug("_ugcModel.participantContainers: " + _ugcModel.participantContainers);
		}
		
		private function _onReadItem(item : UGCItemVO) : void {
			Assert.notNull(item, "_onReadItem, item is null");
			Assert.notNull(_ugcModel.currentItemDAO, "_onReadItem, _ugcModel.currentItemDAO is null");
		}

		private function _onLikeOrComplainOrRateItem(str : String) : void {
			Assert.isTrue(str == "ok", "Something went wrong in the backend.");
		}

		private function _onSetScore(dao : Object) : void {
			log.debug("User Rank: " + dao.rank);
			log.debug("User Score: " + dao.score);
		}

		private function _onGetHighscore() : void {
			log.debug("_ugcModel.gaming.highscoreFriends: " + _ugcModel.gaming.highscoreFriends);
			log.debug("_ugcModel.gaming.highscoreAll: " + _ugcModel.gaming.highscoreAll);
			log.debug("_ugcModel.gaming.rank: " + _ugcModel.gaming.rank);
		}

		private function _onMailSent(str : String) : void {
			Assert.isTrue(str == "Message successfully sent!", "Something went wrong in the backend.");
		}
		
	}
}