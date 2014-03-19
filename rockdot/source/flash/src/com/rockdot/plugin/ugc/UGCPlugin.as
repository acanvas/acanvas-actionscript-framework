package com.rockdot.plugin.ugc {
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.plugin.ugc.command.GamingCheckPermissionToPlayCommand;
	import com.rockdot.plugin.ugc.command.GamingCheckPermissionToPlayLocaleCommand;
	import com.rockdot.plugin.ugc.command.GamingGetGamesCommand;
	import com.rockdot.plugin.ugc.command.GamingGetHighscoreCommand;
	import com.rockdot.plugin.ugc.command.GamingSaveGameCommand;
	import com.rockdot.plugin.ugc.command.GamingSetScoreAtLevelCommand;
	import com.rockdot.plugin.ugc.command.TaskGetCategoriesCommand;
	import com.rockdot.plugin.ugc.command.TaskGetTasksByCategoryCommand;
	import com.rockdot.plugin.ugc.command.UGCComplainCommand;
	import com.rockdot.plugin.ugc.command.UGCCreateItemCommand;
	import com.rockdot.plugin.ugc.command.UGCCreateItemContainerCommand;
	import com.rockdot.plugin.ugc.command.UGCDeleteCommand;
	import com.rockdot.plugin.ugc.command.UGCFilterItemCommand;
	import com.rockdot.plugin.ugc.command.UGCFriendsReadCommand;
	import com.rockdot.plugin.ugc.command.UGCGetLikersCommand;
	import com.rockdot.plugin.ugc.command.UGCHasExtendedUserCommand;
	import com.rockdot.plugin.ugc.command.UGCHasExtendedUserTodayCommand;
	import com.rockdot.plugin.ugc.command.UGCInitCommand;
	import com.rockdot.plugin.ugc.command.UGCLikeCommand;
	import com.rockdot.plugin.ugc.command.UGCMailSendCommand;
	import com.rockdot.plugin.ugc.command.UGCRateCommand;
	import com.rockdot.plugin.ugc.command.UGCReadItemCommand;
	import com.rockdot.plugin.ugc.command.UGCReadItemContainerCommand;
	import com.rockdot.plugin.ugc.command.UGCReadItemContainersByUIDCommand;
	import com.rockdot.plugin.ugc.command.UGCRegisterCommand;
	import com.rockdot.plugin.ugc.command.UGCRegisterExtendedCommand;
	import com.rockdot.plugin.ugc.command.UGCTestCommand;
	import com.rockdot.plugin.ugc.command.UGCTrackInviteCommand;
	import com.rockdot.plugin.ugc.command.UGCUnlikeCommand;
	import com.rockdot.plugin.ugc.command.event.GamingEvents;
	import com.rockdot.plugin.ugc.command.event.UGCEvents;
	import com.rockdot.plugin.ugc.inject.UGCModelInjector;
	import com.rockdot.plugin.ugc.model.UGCModel;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.AbstractOrderedFactoryPostProcessor;

	import flash.utils.Dictionary;








	/**
	 * @flowerModelElementId _0eA1EC9LEeG0Qay4mHgS6g
	 */
	public class UGCPlugin extends AbstractOrderedFactoryPostProcessor{
		public static const MODEL_UGC : String = "MODEL_UGC";
		protected var _log : ILogger = getLogger(UGCPlugin);

		public function UGCPlugin() {
			super(40);
		}


		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation{
			
			/* Objects */
			RockdotHelper.registerClass(objectFactory, MODEL_UGC, UGCModel, true);
			
			/* Object Postprocessors */
			objectFactory.addObjectPostProcessor(new UGCModelInjector(objectFactory));
			

			/* Commands */
			var commandMap : Dictionary = new Dictionary();

			/* AMF */
			commandMap[ UGCEvents.CREATE_ITEM ] = UGCCreateItemCommand; 
			commandMap[ UGCEvents.READ_ITEM ] = UGCReadItemCommand; 

			commandMap[ UGCEvents.READ_ITEM_CONTAINER ] = UGCReadItemContainerCommand; 
			commandMap[ UGCEvents.READ_ITEM_CONTAINERS_UID ] = UGCReadItemContainersByUIDCommand; 
			commandMap[ UGCEvents.CREATE_ITEM_CONTAINER ] = UGCCreateItemContainerCommand; 

			/* Gaming */
			commandMap[ GamingEvents.SET_SCORE_AT_LEVEL] = GamingSetScoreAtLevelCommand; 
			commandMap[ GamingEvents.GET_HIGHSCORE ] = GamingGetHighscoreCommand;
			commandMap[ GamingEvents.GET_GAMES ] = GamingGetGamesCommand;
			commandMap[ GamingEvents.CHECK_PERMISSION_TO_PLAY ] = GamingCheckPermissionToPlayCommand;
			commandMap[ GamingEvents.CHECK_PERMISSION_TO_PLAY_LOCALE ] = GamingCheckPermissionToPlayLocaleCommand;
			commandMap[ GamingEvents.SAVE_GAME ] = GamingSaveGameCommand;
 
			/* UGC (User Generated Content) */
			commandMap[ UGCEvents.INIT ] = UGCInitCommand;
			commandMap[ UGCEvents.TEST ] = UGCTestCommand;
			commandMap[ UGCEvents.USER_REGISTER ] = UGCRegisterCommand;
			commandMap[ UGCEvents.USER_REGISTER_EXTENDED ] = UGCRegisterExtendedCommand;
			commandMap[ UGCEvents.USER_HAS_EXTENDED ] = UGCHasExtendedUserCommand;
			commandMap[ UGCEvents.USER_HAS_EXTENDED_TODAY ] = UGCHasExtendedUserTodayCommand;
			
			commandMap[ UGCEvents.ITEM_LIKE ] = UGCLikeCommand; 
			commandMap[ UGCEvents.ITEM_UNLIKE ] = UGCUnlikeCommand; 
			commandMap[ UGCEvents.ITEM_RATE ] = UGCRateCommand; 
			
			commandMap[ UGCEvents.ITEM_COMPLAIN ] = UGCComplainCommand; 
			commandMap[ UGCEvents.ITEM_DELETE ] = UGCDeleteCommand; 
			commandMap[ UGCEvents.ITEMS_FILTER] = UGCFilterItemCommand; 
			commandMap[ UGCEvents.ITEMS_FRIENDS_GET ] = UGCFriendsReadCommand; 
			commandMap[ UGCEvents.ITEM_LIKERS_GET ] = UGCGetLikersCommand; 
			commandMap[ UGCEvents.USER_MAIL_SEND ] = UGCMailSendCommand; 

			commandMap[ UGCEvents.TRACK_INVITE ] = UGCTrackInviteCommand; 

			commandMap[ UGCEvents.TASK_GET_CATEGORIES ] = TaskGetCategoriesCommand; 
			commandMap[ UGCEvents.TASK_GET_TASK_BY_CATEGORY ] = TaskGetTasksByCategoryCommand; 
			
			RockdotHelper.registerCommands(objectFactory, commandMap);
			
			
			/* Bootstrap Command */
			RockdotConstants.getBootstrap().push( UGCEvents.INIT );
			
			
			return null;
		}
		
		
	}
}