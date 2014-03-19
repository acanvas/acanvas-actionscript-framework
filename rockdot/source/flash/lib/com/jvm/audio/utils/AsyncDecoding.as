package com.jvm.audio.utils {
	import flash.media.Sound;
	import flash.utils.ByteArray;

	/**
	 * @author Andre Michelle
	 */
	public final class AsyncDecoding {
		// One second audio each call
		private const NUM_SAMPLES_EACH_CALL : int = 44100;
		private var _sound : Sound;
		private var _onComplete : Function;
		private var _audioData : ByteArray;
		private var _isDecoding : Boolean;

		public function AsyncDecoding(sound : Sound, onComplete : Function) {
			_sound = sound;
			_onComplete = onComplete;

			_audioData = new ByteArray();
			_isDecoding = true;
		}


		public function enterFrame() : void {
			if ( !_isDecoding ) {
				// TODO Stop calling enterFrame
				return;
			}

			const read : Number = _sound.extract(_audioData, NUM_SAMPLES_EACH_CALL);

			if ( 0.0 == read ) {
				_isDecoding = false;

				_onComplete(this);
				_onComplete = null;
			}
		}


		public function get audioData() : ByteArray {
			return _audioData;
		}


		public function dispose() : void {
			_sound = null;
			_audioData = null;
			_isDecoding = false;
			_onComplete = null;
		}
	}
}
