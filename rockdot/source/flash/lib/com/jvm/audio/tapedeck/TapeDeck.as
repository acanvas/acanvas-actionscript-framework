package com.jvm.audio.tapedeck {
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	/**
	 * All constants with comments are editable.
	 * Range values are provided for orientation.
	 * 
	 * @author Andre Michelle (andre.michelle@audiotool.com, 0162-2941641)
	 */
	public final class TapeDeck {
		private const SPOOLING_HIGHPASS : Boolean = true; // [false,true] Highpass on/off
		private const SPOOLING_HIGHPASS_MAX : Number = 0.5; // [0,SQRT1_2] If set to SQRT1_2, filter will not pass any audio on max spooling speed
		private const SPOOLING_HIGHPASS_EXP : Number = 32.0; // [2,128] Higher value will decrease highpass while spool
		private const FORCE_NORMAL_PLAYBACK : Number = 0.001; // [SMALLER,SMALL] Only do small changes: Higher values will increase start/stop time
		private const FORCE_SPOOLING_MIN : Number = FORCE_NORMAL_PLAYBACK * 0.01; // [SMALL,SMALL] Ensure minimal playback when spooling
		private const FORCE_SPOOLING_MAX : Number = FORCE_NORMAL_PLAYBACK * 32.0; // [2,INFINITY] Affects maximum spooling speed
		private const FORCE_SPOOLING_IMPULSE : Number = 0.0000002; // [SMALL,SMALLER] Only do small changes: Higher values will increase motor impulse
		private const BUFFER_SIZE : int = 2048; // [2048,3072,4096,8192] defines latency, but also affects playback stability
		private const BUFFER_EMPTY : ByteArray = new ByteArray();
		private const BALANCE_LATENCY : Boolean = false; // [false,true] Balancing is actually stable in release player, but may jump in debug player
		private const MOTOR_IDLE : int = 0;
		private const MOTOR_NORMAL : int = 1;
		private const MOTOR_FAST_FORWARD : int = 2;
		private const MOTOR_FAST_REWIND : int = 3;
		private const observers : Vector.<ITapeDeckObserver> = new Vector.<ITapeDeckObserver>();
		private const balancers : Vector.<LatencyBalancer> = new Vector.<LatencyBalancer>();
		private var _samplePosition : Number;
		private var _targetPosition : Number;
		private var _maxPosition : Number;
		private var _velocity : Number;
		private var _sound : Sound;
		private var _soundChannel : SoundChannel;
		private var _latency : Number;
		private var _audio : ByteArray;
		private var _motorMode : int;
		private var _autoPlay : Boolean;
		private var _fltLeft : Number;
		private var _fltRight : Number;

		public function TapeDeck() {
			BUFFER_EMPTY.length = BUFFER_SIZE << 3;

			_motorMode = MOTOR_IDLE;
			_targetPosition = 0.0;
			_samplePosition = 0.0;
			_velocity = 0.0;
			_latency = 0.0;
			_fltLeft = 0.0;
			_fltRight = 0.0;

			_sound = new Sound();
			_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);
			_soundChannel = _sound.play();
		}


		public function addObserver(observer : ITapeDeckObserver) : void {
			if ( -1 == observers.indexOf(observer) )
				observers.push(observer);
		}


		public function removeObserver(observer : ITapeDeckObserver) : void {
			const deleteIndex : int = observers.indexOf(observer);

			if ( -1 < deleteIndex )
				observers.splice(deleteIndex, 1);
		}


		public function get audio() : ByteArray {
			return _audio;
		}


		/**
		 * @param value ByteArray filled with audio data (float/stereo/44100Hz)
		 */
		public function set audio(value : ByteArray) : void {
			if ( null == value )
				throw new Error('Sound cannot be null.');

			if ( 0 == value.length )
				throw new Error('Sound is empty.');

			_audio = value;
			_maxPosition = ( value.length >> 3 ) - 2;
			// Two extra needed for interpolation
		}


		/**
		 * @return autoPlay
		 */
		public function get autoPlay() : Boolean {
			return _autoPlay;
		}


		/**
		 * @param value if value is true, tapedeck will play normal
		 */
		public function set autoPlay(value : Boolean) : void {
			if ( _autoPlay != value ) {
				_autoPlay = value;

				if ( _autoPlay ) {
					if ( _motorMode == MOTOR_IDLE )
						_motorMode = MOTOR_NORMAL;
				} else {
					if ( _motorMode == MOTOR_NORMAL )
						_motorMode = MOTOR_IDLE;
				}
			}
		}


		/**
		 * @param value The position in samples where to spool
		 */
		public function set targetPosition(value : Number) : void {
			if ( _targetPosition != value ) {
				_targetPosition = value;

				if ( _targetPosition > _samplePosition ) {
					notify(TapeDeckNotifyType.PLAYBACK_FAST_FORWARD_START);

					_motorMode = MOTOR_FAST_FORWARD;
				} else if ( _targetPosition < _samplePosition ) {
					notify(TapeDeckNotifyType.PLAYBACK_FAST_REWIND_START);

					_motorMode = MOTOR_FAST_REWIND;
				}
			}
		}


		/**
		 * return current position in samples > no latency included
		 */
		public function get samplePosition() : Number {
			return _samplePosition;
		}


		/**
		 * @return The amount of audio samples
		 */
		public function get samplesTotal() : uint {
			if ( null == _audio )
				return 0;

			return _audio.length >> 3;
		}


		/**
		 * @return latency in milliseconds
		 */
		public function get latency() : Number {
			return _latency;
		}


		/**
		 * Needs to be triggered from outside
		 */
		public function enterFrame() : void {
			var time : int = getTimer();

			while ( 0 < balancers.length ) {
				var balancer : LatencyBalancer = balancers[0];

				if ( time >= balancer.executionTime ) {
					notifyPosition(balancer.samplePosition);
					balancers.splice(0, 1);
				} else {
					break;
				}
			}
		}


		private function sampleData(event : SampleDataEvent) : void {
			if ( _soundChannel != null ) {
				_latency = event.position / 44.1 - _soundChannel.position;
			}

			if ( null == _audio ) {
				event.data.writeBytes(BUFFER_EMPTY);
			} else if ( BALANCE_LATENCY ) {
				const blockSize : int = 1024;
				const blockTime : Number = blockSize / 44100.0;
				// ~23ms
				const numBlocks : int = BUFFER_SIZE / blockSize;

				const time : int = getTimer();

				for ( var i : int = 0 ; i < numBlocks ; ++i ) {
					const balancer : LatencyBalancer = new LatencyBalancer();

					balancer.executionTime = time + _latency + i * blockTime;
					balancer.samplePosition = _samplePosition;
					balancers.push(balancer);

					process(event.data, blockSize);
				}
			} else {
				notifyPosition(samplePosition);

				process(event.data, BUFFER_SIZE);
			}
		}


		private function process(output : ByteArray, numSamples : int) : void {
			var l : Number;
			var r : Number;

			var motorForce : Number;

			for ( var i : int = 0 ; i < numSamples ; ++i ) {
				// CLAMP POSITION
				if ( _samplePosition < 0.0 ) {
					_velocity = 0.0;
					_samplePosition = 0.0;
				} else if ( _samplePosition >= _maxPosition ) {
					_velocity = 0.0;
					_samplePosition = _maxPosition;
				}

				// LINEAR INTERPOLATION SETUP
				var pInt : int = _samplePosition;
				var pAlp : Number = _samplePosition - pInt;

				// SET AUDIO POSITION
				_audio.position = pInt << 3;

				// READ SAMPLE
				l = _audio.readFloat();
				r = _audio.readFloat();

				// INTERPOLATE TO NEXT SAMPLE
				l += pAlp * ( _audio.readFloat() - l );
				r += pAlp * ( _audio.readFloat() - r );

				if ( SPOOLING_HIGHPASS ) {
					// COMPUTE HIGHPASS PASS COEFF (DEPENDING ON SPEED > SIMPLE MAPPING)
					var w : Number = 0.0 > _velocity ? -_velocity : _velocity;

					if ( w > 1.0 ) {
						w = Math.pow(( w - 1.0 ) / ( FORCE_SPOOLING_MAX - 1.0 ), SPOOLING_HIGHPASS_EXP) * SPOOLING_HIGHPASS_MAX;

						if ( w < 0.0 )
							w = 0.0;
						else if ( w > SPOOLING_HIGHPASS_MAX )
							w = SPOOLING_HIGHPASS_MAX;
					} else
						w = 0.0;

					_fltLeft += ( l - _fltLeft ) * w;
					_fltRight += ( r - _fltRight ) * w;

					// WRITE HIGHPASS OUTPUT
					output.writeFloat(l - _fltLeft);
					output.writeFloat(r - _fltRight);
				} else {
					// WRITE OUTPUT
					output.writeFloat(l);
					output.writeFloat(r);
				}

				// CONTROL MOTOR
				if ( MOTOR_FAST_FORWARD == _motorMode ) {
					if ( _samplePosition >= _targetPosition ) {
						_motorMode = _autoPlay ? MOTOR_NORMAL : MOTOR_IDLE;

						if ( _autoPlay )
							_velocity = 0.0;

						motorForce = FORCE_NORMAL_PLAYBACK;

						notify(TapeDeckNotifyType.PLAYBACK_FAST_FORWARD_COMPLETE);
					} else {
						motorForce = ( _targetPosition - _samplePosition ) * FORCE_SPOOLING_IMPULSE;

						if ( motorForce > FORCE_SPOOLING_MAX )
							motorForce = FORCE_SPOOLING_MAX;
						else if ( motorForce < FORCE_SPOOLING_MIN ) // ENSURE MINIMAL FORCE
							motorForce = FORCE_SPOOLING_MIN;
					}
				} else if ( MOTOR_FAST_REWIND == _motorMode ) {
					if ( _samplePosition <= _targetPosition ) {
						_motorMode = _autoPlay ? MOTOR_NORMAL : MOTOR_IDLE;

						if ( _autoPlay )
							_velocity = 0.0;

						motorForce = FORCE_NORMAL_PLAYBACK;

						notify(TapeDeckNotifyType.PLAYBACK_FAST_REWIND_COMPLETE);
					} else {
						motorForce = ( _targetPosition - _samplePosition ) * FORCE_SPOOLING_IMPULSE;

						if ( motorForce < -FORCE_SPOOLING_MAX )
							motorForce = -FORCE_SPOOLING_MAX;
						else if ( motorForce > -FORCE_SPOOLING_MIN ) // ENSURE MINIMAL FORCE
							motorForce = -FORCE_SPOOLING_MIN;
					}
				} else if ( MOTOR_NORMAL == _motorMode )
					motorForce = FORCE_NORMAL_PLAYBACK;
				else
					motorForce = 0.0;

				// APPLY FORCE AND FRICTION
				_velocity -= _velocity * FORCE_NORMAL_PLAYBACK;
				_velocity += motorForce;

				// APPLY VELOCITY
				_samplePosition += _velocity;
			}
		}


		private function notify(notifyType : int) : void {
			var i : int = observers.length;

			while ( --i > -1 )
				observers[i].onTapeDeckNotify(this, notifyType);
		}


		private function notifyPosition(samplePosition : Number) : void {
			var i : int = observers.length;

			while ( --i > -1 )
				observers[i].onTapeDeckPositionChanged(this, samplePosition);
		}
	}
}
final class LatencyBalancer {
	public var executionTime : int;
	public var samplePosition : Number;
}