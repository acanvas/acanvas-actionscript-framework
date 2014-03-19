package com.jvm.audio.soundmanager {
	import com.greensock.TweenMax;

	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class SoundManager {
		protected static var _channels : Array = [];
		// <ChannelMetaData>
		protected static var _sequences : Array = [];
		// <SoundSequence>
		private static var _c : ChannelMetaData;

		// current ChannelMetaData
		public static function initialize() : void {
		}


		public static function addChannel(channelName : String, vol : Number = 1, panning : Number = 0) : void {
			_channels[channelName] = new ChannelMetaData(channelName, new SoundChannel(), new SoundTransform(vol, panning));
		}


		public static function removeChannel(channelName : String) : void {
			if (_isChannelNameValid(channelName))
				_channels[channelName] = undefined;
		}


		public static function removeAllChannels() : void {
			_channels = [];
		}


		/*
		 * ################################################################################
		 * SINGLE SOUNDS
		 * ################################################################################
		 */
		public static function playSoundOnChannel(sound : Sound, channelName : String, solo : Boolean = false, startTime : uint = 0, loops : uint = 0, sndTransform : SoundTransform = null) : SoundChannel {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				if (sound) {
					_c.sound = sound;
					_c.solo = solo;

					if (solo) {
						_c.soundChannel.stop();
						_c.isEndlessLoopPlaying = false;
					}

					_c.soundChannel = sound.play(startTime, loops, sndTransform == null ? _c.sndTransform : sndTransform);
					_c.isPlaying = true;

					if (!_c.hasEventListener(Event.SOUND_COMPLETE))
						_c.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete, false, 0, true);

					return _c.soundChannel;
				} else {
					trace("ERROR [SoundManager]: Sound is null!");
					return null;
				}
			}
			return null;
		}


		private static function _onSoundComplete(event : Event) : void {
			_c = event.target as ChannelMetaData;
			_c.isPlaying = false;
		}


		public static function playEndlessLoopOnChannel(sound : Sound, channelName : String, solo : Boolean = false, startTime : uint = 0, sndTransform : SoundTransform = null) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				_c.sound = sound;
				_c.solo = solo;
				_c.startTime = startTime;
				_c.endlessLoopSndTransform = sndTransform == null ? _c.sndTransform : sndTransform;
				_c.isEndlessLoop = true;
				if (solo)
					_c.soundChannel.stop();

				_c.soundChannel = sound.play(startTime, 0, _c.endlessLoopSndTransform);
				_c.isPlaying = true;
				_c.isEndlessLoopPlaying = true;

				if (!_c.hasEventListener(Event.SOUND_COMPLETE))
					_c.addEventListener(Event.SOUND_COMPLETE, _onEndlessLoopSoundComplete, false, 0, true);
			}
		}


		public static function isChannelPlaying(channelName : String) : Boolean {
			if (_isChannelNameValid(channelName))
				return _channels[channelName].isPlaying;

			return false;
		}


		public static function isEndlessLoopPlayingOnChannel(channelName : String) : Boolean {
			if (_isChannelNameValid(channelName))
				return _channels[channelName].isEndlessLoopPlaying;

			return false;
		}


		private static function _onEndlessLoopSoundComplete(event : Event) : void {
			_c = event.target as ChannelMetaData;
			playSoundOnChannel(_c.sound, _c.channelName, false, _c.startTime, 0, _c.endlessLoopSndTransform);
		}


		public static function resumeEndlessLoopChannel(channelName : String) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				if (!_c.isEndlessLoopPlaying) {
					playSoundOnChannel(_c.sound, channelName, _c.solo, _c.position, 0, _c.endlessLoopSndTransform);
					_c.isEndlessLoopPlaying = true;
				}
			}
		}


		public static function stopEndlessLoopOnChannel(channelName : String, killLoop : Boolean = false) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				if (killLoop)
					_c.removeEventListener(Event.SOUND_COMPLETE, _onEndlessLoopSoundComplete);
				_c.soundChannel.stop();
				_c.isPlaying = false;
				_c.isEndlessLoopPlaying = false;
			}
		}


		public static function pauseChannel(channelName : String) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				_c.position = _c.soundChannel.position;
				_c.soundChannel.stop();
				_c.isPlaying = false;
				_c.isEndlessLoopPlaying = false;
			}
		}


		public static function resumeChannel(channelName : String) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				if (!_c.isPlaying)
					playSoundOnChannel(_c.sound, channelName, _c.solo, _c.position, 0, _c.sndTransform);
			}
		}


		public static function stopChannel(channelName : String) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				_c.soundChannel.stop();
				_c.isPlaying = false;
				_c.isEndlessLoopPlaying = false;
			}
		}


		public static function fadeChannel(channelName : String, targetVolume : Number, fadeLength : Number = 1, autoStop : Boolean = false) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				if (autoStop)
					TweenMax.to(_c.soundChannel, fadeLength, {volume:targetVolume, onComplete:stopChannel, onCompleteParams:[_c]});
				else
					TweenMax.to(_c.soundChannel, fadeLength, {volume:targetVolume});
			}
		}


		/*
		 * ################################################################################
		 * SEQUENCES
		 * ################################################################################
		 */
		public static function addSequence(sequenceName : String, soundSequence : Array) : void {
			_sequences[sequenceName] = new SoundSequence(soundSequence);
		}


		public static function removeSequence(sequenceName : String) : void {
			if (_isSequenceNameValid(sequenceName))
				_sequences[sequenceName] = undefined;
		}


		public static function removeAllSequences() : void {
			_sequences = [];
		}


		public static function playSequenceOnChannel(sequenceName : String, channelName : String, solo : Boolean = true, loops : uint = 0, sndTransform : SoundTransform = null) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];

				if (solo) {
					_c.soundChannel.stop();
					_c.isEndlessLoopPlaying = false;
				}

				_sequences[sequenceName].play(channelName, loops, sndTransform);
				_c.isPlaying = true;
			}
		}


		public static function pauseSequence(sequenceName : String) : void {
			if (_isSequenceNameValid(sequenceName)) {
				_sequences[sequenceName].pause();
			}
		}


		public static function resumeSequence(sequenceName : String) : void {
			if (_isSequenceNameValid(sequenceName)) {
				_sequences[sequenceName].resume();
			}
		}


		public static function resetSequence(sequenceName : String) : void {
			if (_isSequenceNameValid(sequenceName)) {
				_sequences[sequenceName].reset();
			}
		}


		public static function stopSequence(sequenceName : String, reset : Boolean = true) : void {
			if (_isSequenceNameValid(sequenceName)) {
				if (reset)
					_sequences[sequenceName].reset();
				_sequences[sequenceName].stop();
			}
		}


		public static function isSequencePlaying(sequenceName : String) : Boolean {
			if (_isSequenceNameValid(sequenceName)) {
				return _sequences[sequenceName].isPlaying;
			}
			return false;
		}


		/*
		 * ################################################################################
		 * GENERAL
		 * ################################################################################
		 */
		public static function changeSoundTransformOfChannel(channelName : String, sndTransform : SoundTransform) : void {
			if (_isChannelNameValid(channelName)) {
				_c = _channels[channelName];
				_c.sndTransform = sndTransform;
			}
		}


		public static function pauseAll() : void {
			for (var channelName : String in _channels) {
				pauseChannel(channelName);
			}
		}


		public static function resumeAll() : void {
			for (var channelName : String in _channels) {
				if (_channels[channelName].isEndlessLoop) resumeEndlessLoopChannel(channelName);
				else resumeChannel(channelName);
			}
		}


		public static function stopAllSounds() : void {
			SoundMixer.stopAll();
		}


		private static function _isSequenceNameValid(sequenceName : String) : Boolean {
			if (_sequences[sequenceName] == undefined) {
				trace("ERROR [SoundManager]: There is no sequence called: " + sequenceName + ".");
				return false;
			} else {
				return true;
			}
		}


		private static function _isChannelNameValid(channelName : String) : Boolean {
			if (_channels[channelName] == undefined) {
				trace("ERROR [SoundManager]: There is no channel called: " + channelName + ".");
				return false;
			} else {
				return true;
			}
		}


		/*
		 * ################################################################################
		 * SETTER AND GETTER
		 * ################################################################################
		 */
		public static function set volume(value : Number) : void {
			if (value > 1) value = 1;
			else if (value < 0) value = 0;
			var st : SoundTransform = SoundMixer.soundTransform;
			st.volume = value;
			SoundMixer.soundTransform = st;
		}


		public static function get volume() : Number {
			return SoundMixer.soundTransform.volume;
		}


		public static function set pan(value : Number) : void {
			if (value > 1) value = 1;
			else if (value < -1) value = -1;
			var st : SoundTransform = SoundMixer.soundTransform;
			st.pan = value;
			SoundMixer.soundTransform = st;
		}


		public static function get pan() : Number {
			return SoundMixer.soundTransform.pan;
		}
	}
}
