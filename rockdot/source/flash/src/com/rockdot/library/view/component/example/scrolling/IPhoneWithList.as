package com.rockdot.library.view.component.example.scrolling {
	import com.rockdot.library.view.component.common.form.ComponentList;
	import com.jvm.components.Orientation;

	import flash.display.Sprite;
	import flash.events.KeyboardEvent;



	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class IPhoneWithList extends Sprite {
		[Embed(source="images/iPhone4.png")]
		private var iPhone : Class;
		private var _list : ComponentList;

		public function IPhoneWithList(mode : uint = 0) {
			addChild(new iPhone());
			// iPhone4: 571x1119
			// Display: 480X720
			// Display offset: 50x200

			

			// List data
			var data : Array = [];
			var o : Object;
			for (var i : int = 0; i < 200; i++) {
				o = {title: "Cell " + i, subtitle: "This is cell " + i};
				data.push(o);
			}

			// List
			_list = new ComponentList(Orientation.VERTICAL, MyCell, MyScrollbar, true);
			_list.touchEnabled = true;
			_list.keyboardEnabled = true;
			_list.bounce = true;
			_list.bufferSize = 30;
			_list.setData(data);
			_list.hScrollbar.y -= 12;
			_list.vScrollbar.x -= 12;
			_list.x = 50;
			_list.y = 200;
			_list.setSize(480, 720);
			addChild(_list);
			
			addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		}


		private function _onKeyDown(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case 49:
					_list.jumpToCell(0);
					break;
				case 50:
					_list.jumpToCell(1);
					break;
				case 51:
					_list.jumpToCell(2);
					break;
				case 52:
					_list.jumpToCell(3);
					break;
				case 53:
					_list.jumpToCell(856);
					break;
				case 54:
					_list.jumpToCell(531);
					break;
				default:
			}
		}
	}
}
