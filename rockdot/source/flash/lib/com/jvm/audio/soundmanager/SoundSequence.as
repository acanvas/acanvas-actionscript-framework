package com.jvm.audio.soundmanager {
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class SoundSequence {
		private var _seq : Array;
		private var _currentSound : uint;
		private var _channel : String = "";
		private var _loop : uint;		private var _loops : uint;
		private var _sndTransform : SoundTransform;
		private var _currentSoundChannel : SoundChannel;
		private var _isPlaying : Boolean;
		private var _pos : Number = 0;

		public function SoundSequence(soundSequence : Array) {
			_seq = soundSequence;
		}

		
		public function play(channelName : String, loops : uint = 0, sndTransform : SoundTransform = null) : void {			_channel = channelName;
			_loops = loops;
			_sndTransform = sndTransform;
			_pos = 0;
			_playSound();
		}

		
		public function pause() : void {			_pos = _currentSoundChannel.position;
			_currentSoundChannel.stop();
			_isPlaying = false;
		}

		
		public function resume() : void {
			_playSound();
			_pos = 0;
		}

		
		public function stop() : void {
			if (_currentSoundChannel)
				_currentSoundChannel.stop();
			_isPlaying = false;
		}

		
		public function reset() : void {
			if (_currentSoundChannel)
				_currentSoundChannel.stop();
			_isPlaying = false;
			_currentSound = 0;
			_loop = 0;
		}

		
		private function _playSound() : void {
			_currentSoundChannel = SoundManager.playSoundOnChannel(_seq[_currentSound], _channel, false, _pos, 0, _sndTransform);
			if (_currentSoundChannel) {
				_isPlaying = true;
				_currentSoundChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete, false, 0, true);
			}
			else
				trace("ERROR [SoundSequence]: SoundChannel is null!");
		}

		
		private function _onSoundComplete(event : Event) : void {
			_currentSound++;
			if (_currentSound == _seq.length) {
				_currentSound = 0;
				_loop++;
			}
			if (_loop > _loops) {
				//end of seq and all loops
				_loop = 0;
				_isPlaying = false;
			} else {
				_playSound();
			}
		}

		
		public function get isPlaying() : Boolean {
			return _isPlaying;
		}
	}
}
