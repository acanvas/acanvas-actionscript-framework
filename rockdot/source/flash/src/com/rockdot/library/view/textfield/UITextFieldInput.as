package com.rockdot.library.view.textfield {
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	/**
	 * Copyright (c) 2009, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author	Thomas Eckhardt
	 * @since	22.07.2009 12:11:50
	 */

	public class UITextFieldInput extends UITextField
	{
		/*
		 * Konstruktor
		 * 
		 * @param value			Der Text mit dem das Textfeld gefüllt werden soll
		 * @param format 		Das Standard Textformat
		 * @param properties	Ein Objekt das alle Eigenschaften eines Textfelds definieren kann
		 */
		public function UITextFieldInput ( value : String, format : TextFormat )
		{
			// Setze die Standardeigenschaften eines Input-Feldes sofern diese nicht im Objekt
			// "properties" übergeben wurde.
			super( value, format, false );
			
			type = TextFieldType.INPUT;
			selectable = true;
			mouseEnabled = true;
			autoSize = TextFieldAutoSize.NONE;
			wordWrap = false;
			multiline = false;
			
		}
	}
}
