package com.rockdot.plugin.facebook.model {
	import com.facebook.graph.data.FacebookSession;
	import com.rockdot.plugin.facebook.model.vo.FBUserVO;

	/**
	 * @author nilsdoehring
	 */
	public class FBModel {
		
		private var _session : FacebookSession;
		public function get session() : FacebookSession {
			return _session;
		}
		public function set session(session : FacebookSession) : void {
			_session = session;
		}
		
		
		private var _user : FBUserVO;
		public function get user() : FBUserVO {
			return _user;
		}
		public function set user (user : FBUserVO) : void {
			_user = user;
		}


		private var _userAlbums : Array;
		public function get userAlbums() : Array {
			return _userAlbums;
		}
		public function set userAlbums(userAlbums : Array) : void {
//			for (var i : int = 0; i < userAlbums.length; i++) {
//				userAlbums[i].access_token = session.accessToken;
//			}
			_userAlbums = userAlbums;
		}
		
		
		private var _userAlbumPhotos : Array;
		public function get userAlbumPhotos() : Array {
			return _userAlbumPhotos;
		}
		public function set userAlbumPhotos(userAlbumPhotos : Array) : void {
			_userAlbumPhotos = userAlbumPhotos;
		}
		
		
		private var _userIsAuthenticated : Boolean;
		public function get userIsAuthenticated () : Boolean {
			return _userIsAuthenticated;
		}

		
		private var _invitedUsers : Array;
		public function set invitedUsers(newInvitedUsers : Array) : void {
			_invitedUsers = newInvitedUsers;
		}
		public function get invitedUsers() : Array {
			return _invitedUsers;
		}
		
		public function set userIsAuthenticated(userIsAuthenticated : Boolean) : void {
			_userIsAuthenticated = userIsAuthenticated;
		}

		
		
		private var _friends : Array;
		public function get friends () : Array {
			return _friends;
		}
		public function set friends (friends : Array) : void {
			_friends = friends;
		}
		
		
		private var _friendsWithAdditionalInfo : Array;
		public function get friendsWithAdditionalInfo() : Array {
			return _friendsWithAdditionalInfo;
		}
		public function set friendsWithAdditionalInfo(fbUIDInfo : Array) : void {
			_friendsWithAdditionalInfo = fbUIDInfo;
			_createAppUserFriendArray(_friendsWithAdditionalInfo);
		}

		private function _createAppUserFriendArray(collection : Array) : void {
			_friendsWhoAreAppUsers = [];
			_friendsWhoAreAppUsersIndexed = [];
			for (var i:Number =0; i<collection.length;i++) {
				var user : FBUserVO = new FBUserVO(collection[i]);
				user.id = collection[i].uid;
	    		if (user.is_app_user) {
					_friendsWhoAreAppUsers[user.id] = user;
					_friendsWhoAreAppUsersIndexed.push(user.id);
				} 
	    	}
	    	
		}


		private var _friendsWhoAreAppUsers : Array;
		public function get friendsWhoAreAppUsers() : Array {
			return _friendsWhoAreAppUsers;
		}

		private var _friendsWhoAreAppUsersIndexed : Array;
		public function get friendsWhoAreAppUsersIndexed() : Array {
			return _friendsWhoAreAppUsersIndexed;
		}
		
		
		private var _permsToRequest : String;
		public function get permsToRequest() : String {
			return _permsToRequest;
		}
		public function set permsToRequest(permsToRequest : String) : void {
			_permsToRequest = permsToRequest;
		}

		private var _userPermissions : Array = [];
		public function get userPermissions() : Array {
			return _userPermissions;
		}

		public function set userPermissions(userPermissions : Array) : void {
			_userPermissions = userPermissions;
		}

	}
}
