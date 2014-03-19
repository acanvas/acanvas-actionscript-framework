package com.rockdot.project.view.element.shared {
	import com.rockdot.core.model.Markets;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.library.view.textfield.UITextFieldInput;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.project.model.Assets;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Fontset;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author nilsdoehring
	 */
	public class IAMLogo extends RockdotSpriteComponent {
		private static var TXT_LETTERS_MAX : Number = 17;
		private var _sprTFBackground : Sprite;
		private var _tfInput : UITextFieldInput;
		private var _sprClaimBackground : Sprite;
		private var _bmpClaim : Bitmap;

		public function IAMLogo(text : String, editable : Boolean = false) {
			super();

			// "I AM" text
			
			_bmpClaim = Assets.claim_iam;
			if ( RockdotConstants.MARKET == Markets.FRANCE ) {
				_bmpClaim = Assets.claim_jesuis;
			} else if ( RockdotConstants.MARKET == Markets.CZECH_REPUBLIC ) {
				_bmpClaim = Assets.claim_jsem_cz;
			} else if ( RockdotConstants.MARKET == Markets.RUSSIA ) {
				_bmpClaim = Assets.claim_ru;
			}
			_bmpClaim.x = 9;
			_bmpClaim.y = 9;
			addChild(_bmpClaim);

			// box with yellow bg
			_sprClaimBackground = new Sprite();
			_sprClaimBackground.graphics.lineStyle(2, Colors.YELLOW, 1, false, "none");
			_sprClaimBackground.graphics.beginFill(Colors.YELLOW);
			_sprClaimBackground.graphics.drawRect(0, 0, _bmpClaim.width + 18, _bmpClaim.height + 18);
			_sprClaimBackground.graphics.endFill();
			addChildAt(_sprClaimBackground, 0);

			// I AM input
			_tfInput = new UITextFieldInput(text, new TextFormat(Fontset.EMBED_LIGHT, 35, Colors.WHITE));
			_tfInput.autoSize = TextFieldAutoSize.LEFT;
			_tfInput.x = _sprClaimBackground.width + 8;
			_tfInput.y = 6;
			_tfInput.addEventListener(Event.CHANGE, textChangeHandler);
			if ( RockdotConstants.MARKET == Markets.CZECH_REPUBLIC ) {
				_tfInput.restrict = "A-Z 0-9 ČĎĚŘŠŤŮŽÁÉÍÓÚÝčďěřšťůžáéíóúý";
			} else if ( RockdotConstants.MARKET == Markets.RUSSIA ) {
				_tfInput.restrict = "A-Z 0-9 ЀЁЂЃЄЅІЇЈЉЊЋЌЍЎЏАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяѐёђѓєѕіїјљњћќѝўџѠѡѢѣѤѥѦѧѨѩѪѫѬѭѮѯѰѱѲѳѴѵѶѷѸѹѺѻѼѽѾѿҀҁ҂҃҄҅҆ҊҋҌҍҎҏҐґҒғҔҕҖҗҘҙҚқҜҝҞҟҠҡҢңҤҥҦҧҨҩ";
			} else {
				_tfInput.restrict = "A-Z 0-9";
			}
			_tfInput.selectable = false;
			_tfInput.maxChars = TXT_LETTERS_MAX;
			_tfInput.scrollH = 0;
			addChild(_tfInput);
			
			if (editable == true) {
				enableWriteMode();
			} 

			// box with black bg and yellow border
			_sprTFBackground = new Sprite();
			addChildAt(_sprTFBackground, 0);
			
			render();
		}
		
		
		override public function render() : void {
			super.render();
			
			_sprTFBackground.graphics.clear();
			_sprTFBackground.graphics.lineStyle(2, Colors.YELLOW, 1, false, "none");
			_sprTFBackground.graphics.beginFill(Colors.BLACK, .4);
			_sprTFBackground.graphics.drawRect(0, 0, _tfInput.textWidth + 18, _bmpClaim.height + 18);
			_sprTFBackground.graphics.endFill();
			_sprTFBackground.x = _sprClaimBackground.width;
			
			
			_sprTFBackground.width = _tfInput.textWidth + 25;
		}
		
		public function setText(text : String) : void {

			_tfInput.selectable = false;
			_tfInput.text = text;

			_toUpperCase();
			render();
		}

		public function enableWriteMode() : void {

			_tfInput.selectable = true;
			_tfInput.text = "...";

			stage.focus = _tfInput;
		}

		public function reset() : void {
			_tfInput.visible = false;

			_tfInput.maxChars = TXT_LETTERS_MAX;
			_tfInput.selectable = false;
			_tfInput.text = "";

			_sprTFBackground.scaleX = 1;
		}

		private function textChangeHandler(event : Event) : void {
			_tfInput.text = String(_tfInput.text).split(".").join("");

			_toUpperCase();
			render();
			
			if(_submitCallback != null){
				_submitCallback.call(null);
			}
		}

		private function _toUpperCase() : void {
			var strInputText : String = _tfInput.text;

			// var regsearch : RegExp = /[č,ě,ň,ř,š,ů,ž,á,é,í,ó,ú,ý]/;
			// var regreplace: RegExp = /[Č,Ď,Ě,Ř,Š,Ť,Ů,Ž,Á,É,Í,Ó,Ú,Ý]/;
			// ČĎĚŘŠŤŮŽÁÉÍÓÚÝčďěřšťůžáéíóúý
			strInputText.replace(new RegExp(/\u0269/), "Č");
			strInputText.replace(new RegExp(/\u0271/), "Ď");
			strInputText.replace(new RegExp(/\u0283/), "Ě");
			strInputText.replace(new RegExp(/\u0250/), "Ř");
			strInputText.replace(new RegExp(/\u0353/), "Š");
			strInputText.replace(new RegExp(/\u0357/), "Ť");
			strInputText.replace(new RegExp(/\u0367/), "Ů");
			strInputText.replace(new RegExp(/\u0382/), "Ž");
			strInputText.replace(new RegExp(/\u0225/), "Á");
			strInputText.replace(new RegExp(/\u0233/), "É");
			strInputText.replace(new RegExp(/\u0237/), "Í");
			strInputText.replace(new RegExp(/\u0243/), "Ó");
			strInputText.replace(new RegExp(/\u0250/), "Ú");
			strInputText.replace(new RegExp(/\u0253/), "Ý");
			// newtext.replace(new RegExp(/č/), "Č");
			// newtext.replace(new RegExp(/ď/), "Ď");
			// newtext.replace(new RegExp(/ě/), "Ě");
			// newtext.replace(new RegExp(/ř/), "Ř");
			// newtext.replace(new RegExp(/š/), "Š");
			// newtext.replace(new RegExp(/ť/), "Ť");
			// newtext.replace(new RegExp(/ů/), "Ů");
			// newtext.replace(new RegExp(/ž/), "Ž");
			// newtext.replace(new RegExp(/á/), "Á");
			// newtext.replace(new RegExp(/é/), "É");
			// newtext.replace(new RegExp(/í/), "Í");
			// newtext.replace(new RegExp(/ó/), "Ó");
			// newtext.replace(new RegExp(/ú/), "Ú");
			// newtext.replace(new RegExp(/ý/), "Ý");

			_tfInput.text = strInputText.toLocaleUpperCase();
		}

		public function getText() : String {
			return _tfInput.text;
		}

		
	}
}
