package com.rockdot.plugin.tracking.omniture.command.event.vo {


	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 27.05.2011 18:05:26
	 */
	public class OmnitureLinkVO{

		public static const LINK_TYPE_O : String = "o";
		public static const LINK_TYPE_E : String = "e";
		public var linkType : String;
		public var context : String;
		public var action : String;
		

		public function OmnitureLinkVO(linkType : String, context : String, action : String) {
			this.linkType = linkType;
			this.context = context;
			this.action = action;
		}
		
	}
}