package com.rockdot.project.view.text {
	import com.rockdot.core.model.Languages;
	import com.rockdot.core.model.RockdotConstants;


	public class FontProxy 
	{
		private static var _oI : FontProxy;
		private var _regular : String;
		private var _light : String;
		private var _bold : String;
		private var _system : String;
		

		public function FontProxy(access : PrivateConstructorAccess)
		{
		}
		
		public static function getInstance() : FontProxy
		{
			if ( _oI == null ) 
				_oI = new FontProxy( new PrivateConstructorAccess() );

			return _oI;
		}

		/**
		 * Regular Font Name 
		 */
		public static function get COPY() : String
		{
			return _getFont(FontProxy.getInstance()._regular);
		}
		/**
		 * Light Font Name 
		 */
		public static function get LIGHT() : String
		{
			return _getFont(FontProxy.getInstance()._light);
		}
		/**
		 * Bold Font Name 
		 */
		public static function get HEADLINE() : String
		{
			return _getFont(FontProxy.getInstance()._bold);
		}
		/**
		 * System Font Name 
		 */
		public static function get SYSTEM() : String
		{
			return FontProxy.getInstance()._system;
		}


		public static function set COPY(fontName : String) : void {
			FontProxy.getInstance()._regular = fontName;
		}
		public static function set LIGHT(fontName : String) : void {
			FontProxy.getInstance()._light = fontName;
		}
		public static function set HEADLINE(fontName : String) : void {
			FontProxy.getInstance()._bold = fontName;
		}
		public static function set SYSTEM(fontName : String) : void {
			FontProxy.getInstance()._system = fontName;
		}
		
		
		/**
		 * Checks if the given font ID is tagged as embedded.
		 */
		public static function EMBED_FONT(fontID : String) : Boolean {

			return !_isSystem(fontID);
		}

		/**
		 * Checks if font is available as embedded.
		 * Reason: Arabic and Japanese are not embedded and always default to Arial.
		 */
		private static function _getFont(fontID : String) : String {
			if (!_isSystem(fontID)) {
				switch( RockdotConstants.LANGUAGE ) {
					default:
						return fontID;
						break;
				}
			} else {

				return FontProxy.getInstance()._system;
			}

			return null;
		}

		/**
		 * Checks if font is available as embedded, depending on Language.
		 * Reason: Arabic and Japanese are not embedded and always default to Arial.
		 */
		private static function _isSystem(fontID : String) : Boolean {
			switch (fontID) {
				case FontProxy.getInstance()._regular:
				case FontProxy.getInstance()._light:
				case FontProxy.getInstance()._bold:
					switch( RockdotConstants.LANGUAGE ) {
						case Languages.JAPANESE:
						case Languages.ARABIC:
							return true;
						default:
							return false;
							break;
					}
					break;
			}

			return true;
		}
		
	}
}

internal class PrivateConstructorAccess{}
