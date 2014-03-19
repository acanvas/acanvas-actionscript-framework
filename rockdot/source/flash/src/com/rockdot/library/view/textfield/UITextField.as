package com.rockdot.library.view.textfield {
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;



	/**
	 * Copyright (c) 2009, Jung von Matt/Neckar
	 * 
	 * @author	Thomas Eckhardt
	 * @since	15.06.2009 13:33:27
	 * 
	 * Diese Klasse soll als Vorlage für Textfelder dienen.
	 * Sie überschreibt ein paar Default-Werte lässt aber
	 * eine beliebige Konfiguration zu.
	 * 
	 * Beispiel:
	 * var tf : TextField = new CoreTextField( "Hello World", new TextFormat( "Arial", 11, 0x0 ), true, { width:100, embedFonts:false } );
	 *  
	 */
	public class UITextField extends TextField {

		/**
		 * Konstruktor
		 * 
		 * @param	value		Der Text mit dem das Textfeld gefüllt werden soll
		 * @param	format 		Das Standard Textformat
		 * @param	html		Soll es sich um ein HTML-Textfeld handeln (Default: true)
		 * @param	properties	Ein Objekt das alle Eigenschaften eines Textfelds definieren kann
		 * 
		 * @throws	Error		Falls über properties eine Eigenschaft gesetzt wird, die in der Klasse TextField nicht implementiert ist
		 */
		public function UITextField(value : String, format : TextFormat, html : Boolean = true) {
			super();

			// Standardwerte für dynamische Textfelder setzen
			displayAsPassword = false;
			type = TextFieldType.DYNAMIC;
			maxChars = 0;
			restrict = null;

			// Mouse-Interaktion
			mouseWheelEnabled = false;
			mouseEnabled = false;
			selectable = false;

			// Textfeldverhalten
			autoSize = TextFieldAutoSize.LEFT;
			wordWrap = true;
			multiline = true;

			// Schriftbild
			//TODO fix embedding autodetection
			embedFonts = true;//ApplicationFontProxy.EMBED_FONT(format.font);
			defaultTextFormat = format;
			this.setTextFormat(format);
			antiAliasType = AntiAliasType.ADVANCED;
			gridFitType = GridFitType.SUBPIXEL;
			sharpness = 0;
			thickness = 0;

			// Dekorationen
			background = false;
			backgroundColor = 0x0;
			border = false;
			borderColor = 0x0;

			// Text
			if (html) {
				condenseWhite = true;
				htmlText = value;
			} else {
				text = value;
			}

			// Interpretation der übergebenen Eigenschaften
//			if ( properties != null ) {
//				for ( var p : String in properties ) {
//					if ( this.hasOwnProperty(p) ) {
//						this[ p ] = properties[ p ];
//						// log.info("-------- " + p +" = "+ properties[ p ] );
//					} else {
//						log.warn("The CoreTextField class does not implement this property or method. (Property=" + p + ", Value=" + properties[ p ] + ")");
//					}
//				}
//			}
		}

		public function get color() : uint {
			return uint(getTextFormat().color);
		}

		public function set color(value : uint) : void {
			var format : TextFormat = getTextFormat();
			format.color = value;
			setTextFormat(format);
		}

		public function get underline() : Boolean {
			return Boolean(uint(getTextFormat().underline));
		}

		public function set underline(value : Boolean) : void {
			var format : TextFormat = getTextFormat();
			format.underline = value;
			setTextFormat(format);
		}

		override public function get width() : Number {
			return textWidth;
		}
		override public function get height() : Number {
			return textHeight;
		}

	}
}
