package com.jvm.audio.tapedeck {
	/**
	 * @author Andre Michelle
	 */
	public interface ITapeDeckObserver {
		function onTapeDeckNotify(deck : TapeDeck, notifyType : int) : void;


		function onTapeDeckPositionChanged(deck : TapeDeck, samplePosition : Number) : void;
	}
}
