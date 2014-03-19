package com.jvm.audio.tapedeck {
	/**
	 * @author Andre Michelle
	 */
	public final class TapeDeckNotifyType {
		public static const PLAYBACK : int = 0x0100;
		public static const PLAYBACK_FAST_FORWARD_START : int = PLAYBACK | 0x01;
		public static const PLAYBACK_FAST_REWIND_START : int = PLAYBACK | 0x02;
		public static const PLAYBACK_FAST_FORWARD_COMPLETE : int = PLAYBACK | 0x03;
		public static const PLAYBACK_FAST_REWIND_COMPLETE : int = PLAYBACK | 0x04;
	}
}