package com.rockdot.project.view.element.home {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.library.view.component.common.form.ComponentFlickImage;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.project.model.Assets;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Copy;
	import com.rockdot.project.view.text.Headline;

	import org.bytearray.display.ScaleBitmapSprite;

	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;

	/**
	 * @author nilsdoehring
	 */
	public class HomeTutorial extends RockdotSpriteComponent {
		private static const WIDTH_FOR_BIG : int = 700;
		private static const BIG : int = 1;
		private static const SMALL : int = 2;
		private var _bg : ScaleBitmapSprite;
		private var _currentVersion : int;
		private var _imageFlicker : ComponentFlickImage;

		public function HomeTutorial(id : String) {
			super();
			name = id;

			// Teaser Rules------------------------------------------------------------------

			_createVersion();
		}

		private function _createVersion(version : int = BIG) : void {
			if (version == _currentVersion) {
				return;
			}
			while (numChildren > 0) {
				disposeChild(getChildAt(numChildren - 1));
			}

			var bg : Bitmap = Assets.home_teaser_rules_bg;
			_bg = new ScaleBitmapSprite(bg.bitmapData, new Rectangle(10, 10, bg.width - 20, bg.height - 20));
			addChild(_bg);

			var rulesHead : Headline = new Headline(getProperty("headline"), 18, Colors.BLACK);
			rulesHead.width = 320;
			rulesHead.x = 2*BootstrapConstants.SPACER;
			rulesHead.y = 15;
			addChild(rulesHead);

			var rulesItem : Sprite;
			var rulesNumber : Headline;
			var rulesCopy : Copy;
			var rulesImg : Bitmap;
			var rulesLine : Shape;

			var rulesItems : Array = [];

			for (var i : int = 0;i < 3;i++) {
				rulesItem = new Sprite();

				rulesNumber = new Headline(String(i + 1), 24, Colors.GREY_DARK);
				rulesItem.addChild(rulesNumber);

				rulesCopy = new Copy(getProperty("rules" + (i + 1)), 14, Colors.GREY_DARK);
				rulesItem.addChild(rulesCopy);
				rulesCopy.wordWrap = true;

				rulesImg = Assets["home_teaser_rules_" + (i + 1)];
				rulesItem.addChild(rulesImg);

				if (version == BIG) {
					rulesNumber.width = 20;
					rulesNumber.x = 0;
					rulesNumber.y = 30;

					rulesCopy.x = 25;
					rulesCopy.y = 33;
					rulesCopy.width = 185;

					rulesImg.x = rulesCopy.x;
					rulesImg.y = 90 - i * 5;

					rulesItem.x = 20 + (i * 240);
					rulesItem.y = rulesHead.y;
					addChild(rulesItem);

					if (i < 2) {
						rulesLine = new Shape();
						rulesLine.graphics.lineStyle(1, Colors.GREY);
						rulesLine.graphics.lineTo(0, 0);
						rulesLine.graphics.lineTo(0, 113);
						rulesLine.x = rulesItem.width;
						rulesLine.y = rulesNumber.y + 10;
						rulesItem.addChild(rulesLine);
					}
				} else {
					var tfm : TextFormat = rulesNumber.getTextFormat();
					tfm.size = 156;
					rulesNumber.setTextFormat(tfm);
					rulesNumber.width = rulesNumber.textWidth + 5;
					rulesNumber.x = 0;
					rulesNumber.y = 30;

					rulesCopy.x = int(rulesNumber.x + rulesNumber.textWidth + 20);
					rulesCopy.y = 33;
					rulesCopy.width = 210;

					rulesImg.x = int(rulesCopy.x + 40);
					rulesImg.y = 75 - i * 5;

					rulesItems.push(rulesItem);
				}
			}

			if (version == SMALL) {
				_imageFlicker = new ComponentFlickImage(rulesItems, 5000);
				_imageFlicker.x = 20;
				_imageFlicker.y = rulesHead.y;
				addChild(_imageFlicker);
			}

			_currentVersion = version;
		}

		override public function render() : void {
			super.render();

			if (_width > WIDTH_FOR_BIG) {
				_createVersion(BIG);
			} else {
				_createVersion(SMALL);
				_imageFlicker.setSize(_width, 210);
				// _imageFlicker.x = Math.round(_width/2 - _imageFlicker.width/2);
			}

			_bg.width = _width;
			_bg.height = 210;
		}
	}
}
