package com.rockdot.plugin.facebook.command.event {

	/**
	 * @author nilsdoehring
	 */
	public class FBEvents{

		public static const INIT : String 						= "CommandFB.INIT";
		public static const TEST : String 						= "CommandFB.TEST";
		
		//expects VOFBShare, returns nothing
		public static const PROMPT_SHARE : String 				= "CommandFB.PROMPT_SHARE";

		//expects VOFBInvite, returns nothing
		public static const PROMPT_INVITE : String 				= "CommandFB.PROMPT_INVITE";
		
		//expects perms (optional), sets _fbModel.session
		public static const USER_LOGIN : String 				= "CommandFB.USER_LOGIN";
		public static const USER_LOGOUT : String 				= "CommandFB.USER_LOGOUT";

		/* The following Events require a valid _fbModel.session */
		
		//expects nothing, sets _fbModel.user
		public static const USER_GETINFO : String 				= "CommandFB.USER_GETINFO";
		public static const USER_GETINFO_PERMISSIONS : String 	= "CommandFB.USER_GETINFO_PERMISSIONS";
		
		//expects nothing, sets/returns _fbModel.friends (Array<FBUserDataVO>)
		public static const FRIENDS_GET : String 				= "CommandFB.FRIENDS_GET";

		//expects nothing, sets/returns _fbModel.friendsWithAdditionalInfo  (Array<FBUserDataVO>)
		public static const FRIENDS_GETINFO : String 			= "CommandFB.FRIENDS_GETINFO";
		
		//expects nothing, it's just a test
		public static const EVENT_CREATE : String 				= "CommandFB.EVENT_CREATE";

		//expects nothing, sets/returns _fbModel.userAlbums  (Array<FBAlbumDataVO>)
		public static const ALBUMS_GET : String 				= "CommandFB.ALBUMS_GET";

		//expects String (album id), sets/returns _fbModel.userAlbumPhotos (Array<FBPhotoDataVO>)
		public static const PHOTOS_GET : String 				= "CommandFB.PHOTOS_GET";
		
		//expects VOFBPhotoUpload, returns nothing
		public static const PHOTO_UPLOAD : String = "CommandFB.PHOTO_UPLOAD";
	}
}
