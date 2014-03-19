package com.jvm.net {
	import com.jvm.system.PlayerType;

	import flash.errors.IOError;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;

	/**
	 * Copyright (c) 2009, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author	Thomas Eckhardt
	 * @since	27.07.2009 16:07:31
	 * 
	 * @version 1.1 - Simon Schmid (contact(at)sschmid.com)
	 * 
	 */
	public class ExternalInterfaceHelper {
		public static function call( ... args ) : * {
			var success : Boolean;
			var response : * = null;
			
			_info("call, HTML object tag id attribute (IE) / name attribute (Firefox): " + ExternalInterface.objectID);
			
			if ( Capabilities.playerType == PlayerType.EXTERNAL || Capabilities.playerType == PlayerType.STAND_ALONE ) {
				_warn("CALL BLOCKED. Testing mode or stand alone player!");
			} else {	
				if ( ExternalInterface.available ) {
					try {
						response = ExternalInterface.call.apply(ExternalInterface, args);
						success = true;
						if ( response == null ) {
							_warn("External interface call returns null");
						} else {
							_debug("Response: " + response + " [" + typeof( response ) + "]");
						}
					} catch ( error : SecurityError ) {
						_error("A security error occurred: " + error.message);
					} catch ( error : Error ) {
						_error("An error occurred: " + error.message);
					}
				} else {
					_warn("External interface is not available");				}
	            
				if ( !success ) {
					_warn("External interface call failed. Trying navigateToURL()");
					try {
						var request : String = "javascript:" + args[ 0 ] + "(";
						for ( var i : int = 1;i < args.length;i++ ) {
							request += "'" + args[ i ] + "'";
							if ( i < args.length - 1 )
	            				request += ",";
						}
						request += ");";
						navigateToURL(new URLRequest(request), "_self");	
						success = true;
					} catch ( error : SecurityError ) {
						_error("A security error occurred: " + error.message);
					} catch ( error : IOError ) {
						_error("An IO error occurred: " + error.message);
					} catch ( error : Error ) {
						_error("An error occurred: " + error.message);
					}
				}
			}
            
			return response;
		}

		
		private static function _debug(msg : String) : void {
			_log("DEBUG", msg);		}

		
		private static function _info(msg : String) : void {
			_log("INFO", msg);
		}

		
		private static function _warn(msg : String) : void {
			_log("WARNING", msg);
		}

		
		private static function _error(msg : String) : void {			_log("ERROR", msg);		}

		
		private static function _log(type : String, msg : String) : void {
			trace("[ExternalInterfaceHelper] " + type + ": " + msg);
		}
	}
}
