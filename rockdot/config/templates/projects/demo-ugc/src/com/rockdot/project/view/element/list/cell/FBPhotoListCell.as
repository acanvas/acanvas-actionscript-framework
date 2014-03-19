package com.rockdot.project.view.element.list.cell {
	import com.rockdot.library.view.component.common.ComponentImageLoader;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class FBPhotoListCell extends OverviewListCell {
		private var _pic : ComponentImageLoader;

		public function FBPhotoListCell(w : uint) {
			super(w);
		}

		override public function set data(data : Object) : void {
			if (data != _data) {
				_data = data;
				if (_data) {
					_title.text = _data.from.name;
					_subtitle.y = _title.y + _title.height;
					_subtitle.text = _data.created_time;

					if (_pic) {
						_pic.destroy();
					}

					/*
					 *   "images": [
					{
					"height": 258, 
					"width": 200, 
					"source": "http://a8.sphotos.ak.fbcdn.net/hphotos-ak-snc6/166821_10150147237176729_20531316728_7857601_4280017_n.jpg"
					}, 
					{
					"height": 232, 
					"width": 180, 
					"source": "http://photos-h.ak.fbcdn.net/hphotos-ak-snc6/166821_10150147237176729_20531316728_7857601_4280017_a.jpg"
					}, 
					{
					"height": 130, 
					"width": 100, 
					"source": "http://photos-h.ak.fbcdn.net/hphotos-ak-snc6/166821_10150147237176729_20531316728_7857601_4280017_s.jpg"
					}, 
					{
					"height": 96, 
					"width": 75, 
					"source": "http://photos-h.ak.fbcdn.net/hphotos-ak-snc6/166821_10150147237176729_20531316728_7857601_4280017_t.jpg"
					}
					 */
					_pic = new ComponentImageLoader(_data.images[1].source, CELL_HEIGHT - 2, CELL_HEIGHT - 2);
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
