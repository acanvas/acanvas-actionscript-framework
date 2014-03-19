package com.rockdot.plugin.facebook.command {
	import com.rockdot.core.mvc.CompositeCommandWithEvent;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.facebook.command.event.FBEvents;
	import com.rockdot.plugin.facebook.model.vo.FBAlbumVO;
	import com.rockdot.plugin.facebook.model.vo.FBUserVO;

	import org.as3commons.async.command.CompositeCommandKind;
	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.lang.Assert;


	public class FBTestCommand extends AbstractFBCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			var compositeCommand : CompositeCommandWithEvent = new CompositeCommandWithEvent(CompositeCommandKind.SEQUENCE);
			
			
			
			/* ******************** LOGIN USER ******************* */
			var perms : String = getProperty("project.facebook.permissions");
			compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.USER_LOGIN, perms, _onUserLogin), _context);
			
			/* ******************** GET INFO FOR USER ******************* */
			compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.USER_GETINFO, null, _onUserGetInfo), _context);
			
			/* ******************** GET FRIENDS OF USER ******************* */
			compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.FRIENDS_GET, null, _onFriendsGet), _context);
			
			/* ******************** GET FRIENDS INFO OF USER ******************* */
			compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.FRIENDS_GETINFO, null, _onFriendsGetInfo), _context);

			/* ******************** GET ALBUMS OF USER ******************* */
			compositeCommand.addCommandEvent(new RockdotEvent(FBEvents.ALBUMS_GET, null, _onAlbumsGet), _context);
			
			/* ******************** INVITE USERS ******************* */
			//new BaseEvent(FBEvents.PROMPT_INVITE, new VOFBInvite(getProperty("fanbook.invite.title", true), getProperty("fanbook.invite.message", true), "item_container_id=" + _bitburgerModel.ownAlbum.id), _onInviteFinished);
			
			
			compositeCommand.failOnFault = true;
			compositeCommand.addCompleteListener(dispatchCompleteEvent);
			compositeCommand.addErrorListener(_handleError);
			compositeCommand.execute();
		}

	
		private function _onUserLogin(event : OperationEvent = null) : void {
			Assert.isTrue(_fbModel.userIsAuthenticated == true, "_fbModel.userIsAuthenticated is false");
			Assert.notNull(_fbModel.session, "_fbModel.session is null");
		}

		private function _onUserGetInfo(dao : FBUserVO) : void {
			Assert.notNull(dao, "FBUserDAO is null");
			log.debug("FB User email: " + dao.email);
			log.debug("FB User is_app_user: " + dao.is_app_user);
			log.debug("FB User birthday_date: " + dao.birthday_date);
			log.debug("FB User hometown_location: " + dao.hometown_location);
			log.debug("FB User locale: " + dao.locale);
		}
		
		private function _onFriendsGet(friends : Array) : void {
			Assert.notNull(friends, "friends is null");
			Assert.notNull(_fbModel.friends, "_fbModel.friends is null");
			log.debug("_onFriendsGet, Number of Friends: " + _fbModel.friends.length);
		}

		private function _onFriendsGetInfo(friendsWithAdditionalInfo : Array) : void {
			Assert.notNull(friendsWithAdditionalInfo, "friendsWithAdditionalInfo is null");
			Assert.notNull(_fbModel.friendsWithAdditionalInfo, "_fbModel.friendsWithAdditionalInfo is null");
			log.debug("_onFriendsGetInfo, Number of Friends with additional info: " + _fbModel.friendsWithAdditionalInfo.length);
			log.debug("_onFriendsGetInfo, Number of Friends who are App Users: " + _fbModel.friendsWhoAreAppUsers.length);
		}

		private function _onAlbumsGet(userAlbums : Array) : void {
			Assert.notNull(userAlbums, "userAlbums is null");
			Assert.notNull(_fbModel.userAlbums, "_fbModel.userAlbums is null");
			log.debug("_onAlbumsGet, Number of Albums: " + _fbModel.userAlbums.length);
			
			/* ******************** GET PHOTOS OF FIRST USER ALBUM ******************* */
			new RockdotEvent(FBEvents.PHOTOS_GET, new FBAlbumVO(_fbModel.userAlbums[0]).id, _onAlbumPhotosGet).dispatch();
		}

		private function _onAlbumPhotosGet(userAlbumPhotos : Array) : void {
			Assert.notNull(userAlbumPhotos, "userAlbumPhotos is null");
			Assert.notNull(_fbModel.userAlbumPhotos, "_fbModel.userAlbumPhotos is null");
			log.debug("_onAlbumPhotosGet, Number of userAlbumPhotos: " + _fbModel.userAlbumPhotos.length);
		}
	}
}