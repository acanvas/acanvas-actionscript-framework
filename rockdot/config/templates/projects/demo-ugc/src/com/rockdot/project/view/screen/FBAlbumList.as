package com.rockdot.project.view.screen {
	import com.jvm.components.Orientation;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.component.common.form.ComponentList;
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.library.view.component.common.scrollable.DefaultScrollbar;
	import com.rockdot.plugin.facebook.command.event.FBEvents;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.list.cell.FBAlbumListCell;
	import com.rockdot.project.view.text.Headline;

	import flash.system.Capabilities;
	import flash.system.TouchscreenType;



	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class FBAlbumList extends AbstractScreen implements IFBModelAware{

		protected var _fbModel : FBModel;
		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}

		private var _list : ComponentList;
		private var _head : Headline;

		public function FBAlbumList(id : String) {
			super(id);
		}

		override public function init(data : * = null) : void {
			
			super.init(data);
			
			_head = new Headline(getProperty("headline"), 24, Colors.BLACK);
			_head.x = BootstrapConstants.SPACER;
			_head.y = BootstrapConstants.SPACER;
			addChild(_head);

			var albums : Array = _fbModel.userAlbums;
			albums.sortOn("name");

			// List
			_list = new ComponentList(Orientation.VERTICAL, FBAlbumListCell, DefaultScrollbar, true);
			_list.touchEnabled = true;
			_list.doubleClickEnabled = false;
			_list.keyboardEnabled = false;
			_list.doubleClickToZoom = false;
			if(Capabilities.touchscreenType == TouchscreenType.NONE){
				_list.mouseWheelEnabled = true;
			}else{
				_list.bounce = true;//bounce if touchscreen
			}
			_list.submitCallback = _onCellCommit;
			_list.setData( albums);
			addChild(_list);
			_list.render();
			
			_didInit();
		}
		
		override public function render() : void {
			_head.width = _width- 140;
			_list.setSize(_width, _height - /*2* */BootstrapConstants.HEIGHT_RASTER - 2/*4*/ * BootstrapConstants.SPACER);
//			_button.setWidth(_width - 2*Constants.SPACER);
			super.render();
			
//			_button.y = _height - _button.height - Constants.SPACER;
			_list.y = BootstrapConstants.HEIGHT_RASTER + 2 * BootstrapConstants.SPACER;
			_list.hScrollbar.enabled = false;
		}


		private function _onCellCommit(cell : Cell) : void {
			new RockdotEvent(FBEvents.PHOTOS_GET, cell.data.id, _onFBPhotosReceived).dispatch();
		}

		private function _onFBPhotosReceived(data:*=null) : void {
			new RockdotEvent(StateEvents.ADDRESS_SET, "/import/facebook/photos").dispatch();
			
		}




	}
}
