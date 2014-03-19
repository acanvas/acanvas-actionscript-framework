package com.rockdot.plugin.ugc.model {
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;


	public class UGCGamingModel {	
			
		protected var log : ILogger = getLogger(UGCGamingModel);		

		private var _games : Array;
		private var _highscore : Array;
		private var _highscoreFriends : Array;
		private var _rank : int;
		private var _gamescore : int;
		private var _allowedToPlay : Boolean;


		public function get highscoreAll() : Array {
			return _highscore;
		}

		public function set highscoreAll(highscore : Array) : void {
			_highscore = highscore;
		}

		public function get rank() : int {
			return _rank;
		}

		public function set rank(rank : int) : void {
			_rank = rank;
		}

		public function set allowedToPlay(allowedToPlay : Boolean) : void {
			_allowedToPlay = allowedToPlay;
		}

		public function get gamescore() : int {
			return _gamescore;
		}

		public function set gamescore(gamescore : int) : void {
			_gamescore = gamescore;
		}

		public function get games() : Array {
			return _games;
		}

		public function set games(games : Array) : void {
			_games = games;
		}

		public function get highscoreFriends() : Array {
			return _highscoreFriends;
		}

		public function set highscoreFriends(highscoreFriends : Array) : void {
			_highscoreFriends = highscoreFriends;
		}

		public function get allowedToPlay() : Boolean {
			return _allowedToPlay;
		}
		
	}
}
