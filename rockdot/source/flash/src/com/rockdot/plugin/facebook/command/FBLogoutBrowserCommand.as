package com.rockdot.plugin.facebook.command {	import com.facebook.graph.Facebook;	import com.greensock.TweenLite;	import com.rockdot.core.model.RockdotConstants;	import com.rockdot.core.mvc.RockdotEvent;	public class FBLogoutBrowserCommand extends AbstractFBCommand {		override public function execute(event : RockdotEvent = null) : * {			super.execute(event);			if (RockdotConstants.LOCAL) {				log.debug("Facebook Not Supported here.");				TweenLite.delayedCall(.01, dispatchCompleteEvent);			} else {				Facebook.logout(_handleComplete);			}		}		private function _handleComplete(response : Object, fail : Object = null) : void {			if (response != null) {				_fbModel.userIsAuthenticated = false;				_fbModel.session = null;				_fbModel.user = null;				_fbModel.userAlbumPhotos = [];				_fbModel.userAlbums = [];			}			dispatchCompleteEvent(response);		}	}}