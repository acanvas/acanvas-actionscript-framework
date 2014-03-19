package com.rockdot.plugin.tracking.omniture.command.event.vo {

	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 27.05.2011 18:05:26
	 */
	public class OmniturePageVO{

		public static const CHANNEL_TYPE_PRELOADER: String = "preloader";
		public static const CHANNEL_TYPE_INTRO: String = "intro";
		public static const CHANNEL_TYPE_HOME: String = "home";
		public static const CHANNEL_TYPE_NAVIGATION : String = "navigation";
		
		public var channel : String;
		public var subChannel : String;
		public var pageName : String;
		public var action : String;

		public function OmniturePageVO(channel : String, subChannel : String, pageName : String, action : String) {
			this.channel = channel;
			this.subChannel = subChannel;
			this.pageName = pageName;
			this.action = action;
		}
	}
}