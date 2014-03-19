package com.rockdot.project.view.element.list.cell {
	import com.rockdot.library.view.component.common.ComponentImageLoader;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class FBAlbumListCell extends OverviewListCell {
		private var _pic : ComponentImageLoader;

		public function FBAlbumListCell(w : uint) {
			super(w);
		}

		override public function set data(data : Object) : void {
			if (data != _data) {
				_data = data;
				if (_data) {
					_title.text = _data.name;
					_subtitle.text = _data.count;

					if (_pic) {
						_pic.destroy();
					}

					_pic = new ComponentImageLoader("https://graph.facebook.com/" + _data.cover_photo + "/picture?type=normal&access_token=" + _data.access_token, CELL_HEIGHT - 2, CELL_HEIGHT - 2);
					addChild(_pic);

					render();
				}
			}
		}

		override public function render() : void {
			super.render();
			if (_pic) {
				_pic.x = _width - CELL_HEIGHT - 11;
				_pic.y = 1;
			}
		}
	}
}
