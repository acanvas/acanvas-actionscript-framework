package com.rockdot.plugin.facebook.command {	import com.facebook.graph.Facebook;	import com.rockdot.core.mvc.RockdotEvent;	import com.rockdot.plugin.facebook.command.event.vo.VOFBShare;	public class FBPromptShareCommand extends AbstractFBCommand {		override public function execute(event : RockdotEvent = null) : * {			super.execute(event);			var vo : VOFBShare = event.data;			var attachment : Object = {					'name': vo.title, 'href': vo.contentlink, 'description': vo.message, 'media': [{ 'type': 'image', 'src': vo.image, 'href': vo.contentlink}]					}; 			var action_links : Array = [{'text': vo.actionText, 'href':vo.actionLink}];  							//http://developers.facebook.com/docs/reference/dialogs			Facebook.ui("stream.publish", {attachment : attachment, action_links:action_links}, null, "iframe");			dispatchCompleteEvent();		}	}}