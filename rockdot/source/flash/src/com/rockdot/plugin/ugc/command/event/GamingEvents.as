package com.rockdot.plugin.ugc.command.event {

	/**
	 * @author nilsdoehring
	 */
	public class GamingEvents {
		
		//expects GameDAO, returns Object {score:int, rank:int} (for all levels combined)
		public static const SET_SCORE_AT_LEVEL : String		= "GamingEvents.SET_SCORE_AT_LEVEL";
		
		//expects nothing, returns Object {topFiveFriends:Array, topTen:Array, rank:int}
		public static const GET_HIGHSCORE : String 			= "GamingEvents.GET_HIGHSCORE";

		//expects nothing, returns OperationEvent with result = {games:array of GameDAOs}
		public static const GET_GAMES : String 				= "GamingEvents.GET_GAMES";

		//expects score, returns OperationEvent with same result as GET_GAMES
		public static const SAVE_GAME : String 				= "GamingEvents.SAVE_GAME";

		//expects uid, returns Boolean
		public static const CHECK_PERMISSION_TO_PLAY : String = "GamingEvents.CHECK_PERMISSION_TO_PLAY";

		//expects {uid, locale}, returns Boolean
		public static const CHECK_PERMISSION_TO_PLAY_LOCALE : String = "GamingEvents.CHECK_PERMISSION_TO_PLAY_LOCALE";

		
	}
}
