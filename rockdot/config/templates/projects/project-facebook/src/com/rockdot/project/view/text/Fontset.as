package com.rockdot.project.view.text {
	import com.rockdot.core.model.Markets;
	import com.rockdot.core.model.RockdotConstants;

	import flash.text.Font;





	public class Fontset {
		FrutigerNextLTW1GLight;
		FrutigerNextLTW1GHeavyCondensed;
	 	HelveticaNeue55;
	 	HelveticaNeue75;
		
		private static const DEFAULT_SYSTEM_ID : String = 'Arial';
		
		public static const EMBED_LIGHT : String = "Frutiger Next LT W1G Light";
		public static const EMBED_COPY : String = ( RockdotConstants.MARKET == Markets.RUSSIA || RockdotConstants.MARKET == Markets.BULGARIA) ? EMBED_LIGHT : "Helvetica Neue CE 55 Roman";	
		public static const EMBED_HEADLINE : String = ( RockdotConstants.MARKET == Markets.RUSSIA || RockdotConstants.MARKET == Markets.BULGARIA) ? "Frutiger Next LT W1G Heavy Condensed" : "Helvetica Neue CE 75 Bold";
		
		public function Fontset() {

			FontProxy.SYSTEM = DEFAULT_SYSTEM_ID;
			FontProxy.COPY = EMBED_COPY;
			FontProxy.LIGHT = EMBED_LIGHT;
			FontProxy.HEADLINE = EMBED_HEADLINE;
		}

		protected function registerFonts(fontList : Array) : void {
			for ( var i : uint = 0; i < fontList.length; i++ ) {
				try {
					Font.registerFont(fontList[i]);
				} catch( e : ReferenceError ) {
					trace(this + " -> " + e.message);
				}
			}
		}

	}
}
