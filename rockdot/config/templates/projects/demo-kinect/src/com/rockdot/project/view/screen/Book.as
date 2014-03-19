package com.rockdot.project.view.screen {
	import com.rockdot.library.view.component.book.BookView;
	import com.rockdot.library.view.component.book.view.Page;
	import com.rockdot.plugin.screen.displaylist.view.RockdotManagedSpriteComponent;
	import com.rockdot.project.model.Assets;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Book extends RockdotManagedSpriteComponent {
		protected var _book : BookView;
		protected var _fireInit : Boolean;

		public function Book(id : String) {
			super(id);
			_fireInit = true;
		}

		override public function init(data : * = null) : void {
			super.init(data);

			_book = new BookView("book");
			_book.setSize(1200, 590);
			_book.openAt = 0;
			_book.autoFlipDuration = 600;
			_book.easing = 0.7;
			_book.regionSize = 150;
			_book.sideFlip = true;
			_book.hardCover = true;
			_book.hover = true;
			_book.snap = false;
			_book.flipOnClick = true;
			addChild(_book);

			/* Initialize stuff here. You can use _width and _height. */
			// first page

			var page : Page;
			for (var i : int = 1; i < 28; i++) {
				page = new Page(Assets["C_" + (i < 10 ? "0" + i : i) + "_768x1024Px_Vorschaufenster"]);
				_book.addChild(page);
			}

			_book.init();

			if (_fireInit) {
				_didInit();
			}
		}

		override public function render() : void {
			super.render();
			if (_book) {
				_book.x = 10;
				_book.y = 10;

				_book.render();
			}
			/* Optionally resize your stuff here. You can use _width and _height.  */
		}
	}
}
