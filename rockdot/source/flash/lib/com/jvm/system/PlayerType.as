package com.jvm.system {

	/**
	 * Copyright (c) 2009, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author	Thomas Eckhardt
	 * @since	18.08.2009 14:08:08
	 * 
	 * Klasse enthält die String-Konstanten von Capabilities.playerType.
	 * http://help.adobe.com/de_DE/AS3LCR/Flash_10.0/flash/system/Capabilities.html#playerType
	 */

	public class PlayerType 
	{
		/**
		 * "ActiveX" für das in Microsoft Internet Explorer verwendete Flash Player-ActiveX-Steuerelement
		 */
		public static const ACTIVE_X : String = "ActiveX";
		 
		/**
		 * "Desktop" für die Adobe AIR-Laufzeitumgebung (mit Ausnahme von SWF-Inhalt, der von einer HTML-Seite geladen wird, für die Capabilities.playerType auf "PlugIn" gesetzt wurde)
		 */
		public static const DESKTOP : String = "Desktop";
		
		/**
		 * "External" für den externen Flash Player oder im Testmodus
		 */
		public static const EXTERNAL : String = "External";
		
		/**
		 * "PlugIn" für das Browser-Plug-In von Flash Player (und für SWF-Inhalt, der von einer HTML-Seite in einer AIR-Anwendung geladen wird)
		 */
		public static const PLUG_IN : String = "PlugIn";
		
		/**
		 * "StandAlone" für den eigenständigen Flash Player 
		 */ 
		public static const STAND_ALONE : String = "StandAlone";
	}
}
