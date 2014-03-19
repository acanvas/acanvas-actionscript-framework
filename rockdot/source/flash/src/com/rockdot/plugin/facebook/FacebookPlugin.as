package com.rockdot.plugin.facebook {
	import com.jvm.utils.DeviceDetector;
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.plugin.facebook.command.FBEventCreateCommand;
	import com.rockdot.plugin.facebook.command.FBFriendsGetCommand;
	import com.rockdot.plugin.facebook.command.FBFriendsGetInfoCommand;
	import com.rockdot.plugin.facebook.command.FBInitBrowserCommand;
	import com.rockdot.plugin.facebook.command.FBInitStageWebViewCommand;
	import com.rockdot.plugin.facebook.command.FBLoginBrowserCommand;
	import com.rockdot.plugin.facebook.command.FBLoginStageWebViewCommand;
	import com.rockdot.plugin.facebook.command.FBLogoutBrowserCommand;
	import com.rockdot.plugin.facebook.command.FBLogoutStageWebViewCommand;
	import com.rockdot.plugin.facebook.command.FBPhotoGetAlbumsCommand;
	import com.rockdot.plugin.facebook.command.FBPhotoGetFromAlbumCommand;
	import com.rockdot.plugin.facebook.command.FBPhotoUploadCommand;
	import com.rockdot.plugin.facebook.command.FBPromptInviteBrowserCommand;
	import com.rockdot.plugin.facebook.command.FBPromptInviteStageWebViewCommand;
	import com.rockdot.plugin.facebook.command.FBPromptShareCommand;
	import com.rockdot.plugin.facebook.command.FBTestCommand;
	import com.rockdot.plugin.facebook.command.FBUserGetInfoCommand;
	import com.rockdot.plugin.facebook.command.FBUserGetInfoPermissionsCommand;
	import com.rockdot.plugin.facebook.command.event.FBEvents;
	import com.rockdot.plugin.facebook.command.operation.FacebookOperation;
	import com.rockdot.plugin.facebook.command.operation.FacebookOperationMobile;
	import com.rockdot.plugin.facebook.inject.FBModelInjector;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.facebook.model.FacebookConstants;

	import org.as3commons.async.operation.IOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.AbstractOrderedFactoryPostProcessor;

	import flash.utils.Dictionary;





	/**
	 * @flowerModelElementId _0QWzkC9LEeG0Qay4mHgS6g
	 */
	public class FacebookPlugin extends AbstractOrderedFactoryPostProcessor {
		public static const MODEL_FB : String = "MODEL_FB";

		public function FacebookPlugin() {
			super(30);
		}


		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{

			/* Objects */
			RockdotHelper.registerClass(objectFactory, MODEL_FB, FBModel, true);
			
			/* Object Postprocessors */
			objectFactory.addObjectPostProcessor(new FBModelInjector(objectFactory));
			
			/* Commands */
			var commandMap : Dictionary = new Dictionary();

			commandMap[ FBEvents.PROMPT_SHARE ] = FBPromptShareCommand; 
			
			if(DeviceDetector.IS_MOBILE || DeviceDetector.IS_AIR){
				commandMap[ FBEvents.INIT ] = FBInitStageWebViewCommand; 
				commandMap[ FBEvents.USER_LOGIN ] = FBLoginStageWebViewCommand; 
				commandMap[ FBEvents.USER_LOGOUT ] = FBLogoutStageWebViewCommand; 
				commandMap[ FBEvents.PROMPT_INVITE ] = FBPromptInviteStageWebViewCommand;
				
				RockdotHelper.registerClass(objectFactory, FacebookConstants.OPERATION_FB, FacebookOperationMobile);
			}
			else{
				commandMap[ FBEvents.INIT ] = FBInitBrowserCommand; 
				commandMap[ FBEvents.USER_LOGIN ] = FBLoginBrowserCommand; 
				commandMap[ FBEvents.USER_LOGOUT ] = FBLogoutBrowserCommand; 
				commandMap[ FBEvents.PROMPT_INVITE ] = FBPromptInviteBrowserCommand; 

				RockdotHelper.registerClass(objectFactory, FacebookConstants.OPERATION_FB, FacebookOperation);
			}
			commandMap[ FBEvents.TEST ] = FBTestCommand; 
			commandMap[ FBEvents.USER_GETINFO ] = FBUserGetInfoCommand; 
			commandMap[ FBEvents.USER_GETINFO_PERMISSIONS ] = FBUserGetInfoPermissionsCommand; 
			commandMap[ FBEvents.FRIENDS_GET ] = FBFriendsGetCommand; 
			commandMap[ FBEvents.FRIENDS_GETINFO ] = FBFriendsGetInfoCommand; 
			commandMap[ FBEvents.EVENT_CREATE ] = FBEventCreateCommand; 
			commandMap[ FBEvents.ALBUMS_GET ] = FBPhotoGetAlbumsCommand; 
			commandMap[ FBEvents.PHOTOS_GET ] = FBPhotoGetFromAlbumCommand; 
			commandMap[ FBEvents.PHOTO_UPLOAD ] = FBPhotoUploadCommand; 
			
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			
			/* Bootstrap Command */
			RockdotConstants.getBootstrap().push( FBEvents.INIT );
			
			return null;
		}
		


	}
}