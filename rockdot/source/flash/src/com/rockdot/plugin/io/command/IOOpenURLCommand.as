package com.rockdot.plugin.io.command {	import com.rockdot.core.mvc.CoreCommand;	import com.rockdot.core.mvc.RockdotEvent;	import com.rockdot.plugin.io.command.event.vo.IOURLOpenVO;	import flash.net.URLRequest;	import flash.net.navigateToURL;	/**	 * Copyright 2009 Jung von Matt/Neckar	 */	public class IOOpenURLCommand extends CoreCommand {		override public function execute(event : RockdotEvent = null) : * {			super.execute(event);						var vo : IOURLOpenVO = event.data;			log.debug("callURL [" + vo.targetUrl + "]:::_currentEvent.targetURL = " + vo.targetUrl);			navigateToURL(new URLRequest(vo.targetUrl), vo.targetWindow);						dispatchCompleteEvent();		}	}}