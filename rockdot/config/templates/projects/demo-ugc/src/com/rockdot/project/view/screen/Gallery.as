package com.rockdot.project.view.screen {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.ugc.model.vo.UGCImageItemVO;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;
	import com.rockdot.project.view.element.dropdown.FilterGalleryDropdown;
	import com.rockdot.project.view.element.pager.PagerPolaroid;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class Gallery extends AbstractScreen {
		private var _photoPager : PagerPolaroid;
		private var _filterDropdown : FilterGalleryDropdown;

		public function Gallery(id : String) {
			super(id);
		}
		
		override public function init(data : * = null) : void {
			super.init(data);
			
			
			_photoPager = new PagerPolaroid();
			_photoPager.submitCallback = _onItemClicked;
			addChild(_photoPager);
			_photoPager.resetAndLoad();

			_filterDropdown = new FilterGalleryDropdown();
			_filterDropdown.submitCallback = _onDropdownClicked;
			addChild(_filterDropdown);
			
			_didInit();
		}

		private function _onDropdownClicked(cell : Cell) : void {
			_log.debug("Dropdown clicked. id: {0}, label: {1}", [cell.id, cell.data]);
		}
		
		private function _onItemClicked(dao : UGCItemVO) : void {
			_log.debug("Item clicked. id: {0}, url_big: {1}", [dao.id, (dao.type_dao as UGCImageItemVO).url_big]);
			_appModel.currentUGCItem = dao;
			new RockdotEvent(StateEvents.ADDRESS_SET, "/image/view").dispatch();
		}
		
		override public function render() : void {
			super.render();
			
			_filterDropdown.setListSizeMax(240, 300);
			_filterDropdown.setSize(200, 30);
			_filterDropdown.x = _width - 200;
			_filterDropdown.y = BootstrapConstants.SPACER;
			
			_photoPager.x = 0;
			_photoPager.y = _filterDropdown.y + 30 + BootstrapConstants.SPACER;
			_photoPager.setSize(_width, _height - _photoPager.y);
		}
		
		override public function appear(duration : Number = 0.5) : void {
			super.appear(duration);
		}

		
		override public function set enabled(value : Boolean) : void {
			super.enabled = value;
		}

	}
}
