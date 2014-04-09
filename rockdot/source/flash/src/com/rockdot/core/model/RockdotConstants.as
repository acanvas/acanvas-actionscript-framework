package com.rockdot.core.model {
	import com.hurlant.util.Base64;

	import org.springextensions.actionscript.context.IApplicationContext;

	import flash.display.LoaderInfo;
	import flash.display.Stage;



	public class RockdotConstants 
	{
		
		/* internals */
		private static var _oI : RockdotConstants;
		private var _loaderInfo : LoaderInfo;
		private var _stage : Stage;
		private var _bootStrap : Array;
		private var _context : IApplicationContext;
		
		public static const VAR_ITEM_CONTAINER_ID : String = "item_container_id";
		public static const VAR_ITEM_ID : String = "item_id";
		public static const VAR_REASON_KEY : String = "reason";
		public static const VAR_REASON_VALUE_APPREQUEST_VIEW : String = "apprequest_view";
		public static const VAR_REASON_VALUE_APPREQUEST_PARTICIPATE : String = "apprequest_participate";
		public static const VAR_REASON_VALUE_SHARE : String = "share";
		
		/* defaults if no vars are given */
		public static const COUNTRY_DEFAULT : String = Countries.GERMANY;
		public static const MARKET_DEFAULT : String = Markets.GERMANY;
		public static const LANGUAGE_DEFAULT : String = Languages.GERMAN;
		
		
		public static const UPLOAD_WIDTH_MAX : Number = 720;
		public static const UPLOAD_HEIGHT_MAX : Number = 720;
		public static const UPLOAD_WIDTH_THUMB : Number = 120;
		public static const UPLOAD_HEIGHT_THUMB : Number = 120;
		
		public static const WIDTH_MIN : uint =  320;
		public static const HEIGHT_MIN : uint = 480;

		public static const WIDTH_MAX : uint =  1920;
		public static const HEIGHT_MAX : uint = 1200;
		
		public static function get WIDTH_STAGE_REAL() : uint { 
			return RockdotConstants.getStage().stageWidth; 
		};
		public static function get HEIGHT_STAGE_REAL() : uint { return RockdotConstants.getStage().stageHeight; };

		public static function get WIDTH_STAGE() : uint { return Math.min(WIDTH_MAX, Math.max(WIDTH_MIN, RockdotConstants.getStage().stageWidth)); }
		public static function get HEIGHT_STAGE() : uint { return Math.min(HEIGHT_MAX, Math.max(HEIGHT_MIN, RockdotConstants.getStage().stageHeight));}
		
		public function RockdotConstants( access : PrivateConstructorAccess )
		{
			_bootStrap = [];
		}
		
		public static function getInstance() : RockdotConstants
		{
			if ( _oI == null ) 
				_oI = new RockdotConstants( new PrivateConstructorAccess() );

			return _oI;
		}

		/*
		 * Setting Loaderinfo 
		 */
		
		public static function getLoaderInfo() : LoaderInfo {
			return RockdotConstants.getInstance()._loaderInfo;
		}
		public static function setLoaderInfo(loaderInfo : LoaderInfo) : void {
			RockdotConstants.getInstance()._loaderInfo = ( loaderInfo);
		}
		
		public static function getBootstrap() : Array {
			return RockdotConstants.getInstance()._bootStrap;
		}
		
		public static function getStage() : Stage {
			return RockdotConstants.getInstance()._stage;
		}
		public static function setStage(stage : Stage) : void {
			RockdotConstants.getInstance()._stage = (stage);
		}

		public static function getContext() : IApplicationContext {
			return RockdotConstants.getInstance()._context;
		}
		
		public static function setContext(ctx : IApplicationContext) : void {
			RockdotConstants.getInstance()._context = ( ctx);
		}
		
		/**
		 *  The PHP session ID
		 *  "" if LOCAL is true
		 */
		public static function get PHP_SESSION_ID() : String {
			if(RockdotConstants.getInstance()._loaderInfo.parameters.php_session_id){
				return RockdotConstants.getInstance()._loaderInfo.parameters.php_session_id;
			}
			return "";
		}
		
		/**
		 *  The Protocol as detected by php
		 *  "" if LOCAL is true
		 */
		public static function get PROTOCOL() : String {
			if(RockdotConstants.getInstance()._loaderInfo.parameters.protocol){
				return RockdotConstants.getInstance()._loaderInfo.parameters.protocol;
			}
			return "";
		}
		
		
		/**
		 *  The Frontend Host as configured in @see project.properties
		 *  "" if LOCAL is true
		 */
		public static function get HOST_FRONTEND() : String {
			if(RockdotConstants.getInstance()._loaderInfo.parameters.host_frontend){
				return RockdotConstants.getInstance()._loaderInfo.parameters.host_frontend;
			}
			return "";
		}
		
		/**
		 *  The Language of the user's locale 
		 *  OR the one set by $_GET["language"]
		 *  OR the default language as configured in @see project.properties
		 */
		public static function get LANGUAGE() : String {
			if(RockdotConstants.getInstance()._loaderInfo.parameters.language){
				return RockdotConstants.getInstance()._loaderInfo.parameters.language as String;
			}
//			if(!str) str = Capabilities.language.substr(0, 2);

			return LANGUAGE_DEFAULT;
		}

		/**
		 * The Market set in PHP (mostly via $_GET["market"]) 
		 *  OR the default market as configured in @see project.properties
		 */ 
		public static function get MARKET() : String {
			if(RockdotConstants.getInstance()._loaderInfo.parameters.market){
				return RockdotConstants.getInstance()._loaderInfo.parameters.market as String;
			}

			return MARKET_DEFAULT;
		}

		/**
		 *  The Country of the user's locale 
		 *  OR the default country as configured in @see project.properties
		 */
		public static function get COUNTRY() : String {
			if(RockdotConstants.getInstance()._loaderInfo.parameters.market){
				return RockdotConstants.getInstance()._loaderInfo.parameters.country as String;
			}

			return COUNTRY_DEFAULT;
		}
		
		/**
		 *  The directory to load the config from. The standard is "v1", as configured in @see project.properties
		 */
		public static function get VERSION() : String
		{
			if(RockdotConstants.getInstance()._loaderInfo.parameters.version){
				return RockdotConstants.getInstance()._loaderInfo.parameters.version as String;
			}
			return "v1";
		}
		
		/**
		 *  Direct access to APP_DATA FlashParam
		 */
		public static function get APP_DATA() : String {
			//retrieve URLVariable ("app_data")
			return RockdotConstants.getInstance()._loaderInfo.parameters.app_data as String;
		}
		
		/**
		 *  Reads keys from base64 encoded string in APP_DATA FlashVar
		 *  mostly set if there's an initial deeplink (which can't be set as Anchor via Facebook's Frame) 
		 */
		public static function URLVAR(key : String) : String {
			//retrieve URLVariable ("app_data")
			var str_app_data : String = RockdotConstants.getInstance()._loaderInfo.parameters.app_data as String;
			if(!str_app_data){
				return null;
			}
			
			//decode app_data
			str_app_data = Base64.decode(str_app_data);
			
			//split query string
			var a_temp : Array = str_app_data.split("&");
			var app_data : Array = [];
			for (var i:int = 0; i <a_temp.length; i++){
				app_data[ a_temp[i].split("=")[0] ] = a_temp[i].split("=")[1];
			}
			
			//return value for key
			return app_data[key];
		}

		
		
		/**
		 *  Debug mode switch. Enables/Disables Logger.
		 *  @see config/users/username.properties
		 */
		public static function get DEBUG() : Boolean
		{
			return RockdotConstants.getInstance()._loaderInfo.parameters.debug == "true" ? true : false;
		}

		/**
		 * Local mode switch. Enables/Disables Facebook Functionality and Fake User 
		 */
		public static function get LOCAL() : Boolean
		{
			return RockdotConstants.getInstance()._loaderInfo.parameters.local == "true" ? true : false;
		}
	}
}

internal class PrivateConstructorAccess{}
