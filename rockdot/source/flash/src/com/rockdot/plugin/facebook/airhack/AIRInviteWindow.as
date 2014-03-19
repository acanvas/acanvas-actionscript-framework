/*
Copyright (c) 2010, Adobe Systems Incorporated
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Adobe Systems Incorporated nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package com.rockdot.plugin.facebook.airhack {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * Displays a new NativeWindow that allows the current user to login to
	 * Facebook. The login process found at:
	 * http://developers.facebook.com/docs/authentication/desktop,
	 * will be handled by this class.
	 *
	 */
	public class AIRInviteWindow extends AbstractAIRWindow {


		protected var inviteRequest:URLRequest;
		protected var userClosedWindow:Boolean = true;

		public var requestSentCallback:Function;

		/**
		 * Creates a new LoginWindow instance.
		 * @param loginCallback Method to call when login is successful
		 *
		 */
		private var _redirect_uri : String;

		public function AIRInviteWindow(requestSent : Function, stage : Stage) {
			this.requestSentCallback = requestSent;
			super(stage);
		}

		/**
		 * Opens a new login window, pointing to the Facebook authorization
		 * page (https://graph.facebook.com/oauth/authorize).
		 *
		 * @param applicationId Current ID of the application being used.
		 * @param extendedPermissions (Optional) List of extended permissions
		 * to ask the user for after login.
		 * @param display (Optional) The display type for the OAuth dialog. "wap" for older mobile browsers,
		 * "touch" for smartphones. The Default is "touch".
		 *
		 * @see http://developers.facebook.com/docs/guides/mobile/ 
		 *
		 */
		public function open(applicationId:String,
							 webView:StageWebView,
							 rect : Rectangle,
							 redirect_uri:String, 
							 message:String=null,
							 data:String=null,
							 title:String=null,
							 max_recipients : int = 0
		):void {
			_redirect_uri = redirect_uri;
			this.webView = webView;
			
			var vars:URLVariables = new URLVariables();
			vars.app_id = applicationId;
			vars.redirect_uri = redirect_uri;
			vars.message = message;
			vars.data = data;
			vars.title = title;
			vars.display = "popup";
			if(max_recipients>0){
				vars.max_recipients = max_recipients;
			}
			
			inviteRequest = new URLRequest();
			inviteRequest.method = URLRequestMethod.GET;
			inviteRequest.url = "http://www.facebook.com/dialog/apprequests?"+ vars;
			
			//INVITE URL LOOKS LIKE http://www.facebook.com/dialog/apprequests?message=Invite%20that%20one%20Friend%20you%20want%20to%20play%20with&title=Invite%20Mission%20Buddy&redirect_uri=http%3A%2F%2Fndoehring%2Eneckar-server%2Ede%2Frockdot-prototype-backend%2Finvite%2Ephp&app_id=124996407530343&data=aXRlbV9jb250YWluZXJfaWQ9MSZyZWFzb249YXBwcmVxdWVzdF9wYXJ0aWNpcGF0ZSZ1aWQ9MTY4NTQ5MTcwOQ%3D%3D&display=popup

			showWindow(inviteRequest, rect);
		}

		override protected function handleLocationChange(event:Event):void
		{
			var location:String = webView.location;
			
			//SUCCESS LOOKS LIKE: http://ndoehring.neckar-server.de/rockdot-prototype-backend/invite.php?request=333784710031466&to%5B0%5D=100000533255902#_=_
			//ABORT LOOKS LIKE: http://ndoehring.neckar-server.de/rockdot-prototype-backend/invite.php#_=_
			if (location.indexOf(_redirect_uri) == 0)
			{
				if(location.indexOf("?request") == -1){
					requestSentCallback(null, "user aborted");
				}
				else{
					webView.removeEventListener(Event.COMPLETE, handleLocationChange);
					webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, handleLocationChange);

					location = location.slice(0, location.indexOf('#') + 0);
					var params : String = location.slice(location.indexOf('?') + 1);
					
					var vars:URLVariables = new URLVariables();
					vars.decode(params);
					
					requestSentCallback(vars, null);
				}
				
				userClosedWindow =  false;
				closeWindow();
			}
		}
	}
}
