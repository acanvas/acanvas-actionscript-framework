package com.jvm.audio.soundmanager {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	[Event(name="soundComplete", type="flash.events.Event")]

	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class ChannelMetaData extends EventDispatcher {
		private var _channelName : String;
		private var _soundChannel : SoundChannel;
		public var endlessLoopSndTransform : SoundTransform;
		public var sound : Sound;
		public var position : Number = 0;
		public var isEndlessLoop : Boolean;

		public function ChannelMetaData(channelName : String, soundChannel : SoundChannel = null, sndTransform : SoundTransform = null, sound : Sound = null, startTime : uint = 0, position : Number = 0, solo : Boolean = true) {
			_channelName = channelName;
			_sndTransform = sndTransform;
			this.sound = sound;
			this.startTime = startTime;
			this.solo = solo;
		}

		
		public function get channelName() : String {
			return _channelName;
		}

		
		public function get soundChannel() : SoundChannel {
			return _soundChannel;
		}

		
		public function set soundChannel(value : SoundChannel) : void {
			if (_soundChannel)
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			_soundChannel = value;
		}

		
		private function _onSoundComplete(event : Event) : void {
			dispatchEvent(event);
		}

		
		public function get sndTransform() : SoundTransform {
			return _sndTransform;
		}
		
		
		public function set sndTransform(sndTransform : SoundTransform) : void {
			if (sndTransform)
				_sndTransform = sndTransform;
			_soundChannel.soundTransform = _sndTransform;
		}
	}
}