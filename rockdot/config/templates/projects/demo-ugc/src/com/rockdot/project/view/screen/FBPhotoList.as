package com.rockdot.project.view.screen {
	import com.jvm.components.Orientation;
	import com.jvm.utils.BitmapUtils;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.component.common.form.ComponentList;
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.library.view.component.common.scrollable.DefaultScrollbar;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.io.inject.IIOModelAware;
	import com.rockdot.plugin.io.model.IOModel;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.button.YellowButton;
	import com.rockdot.project.view.element.list.cell.FBPhotoListCell;
	import com.rockdot.project.view.text.Headline;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.TouchscreenType;




	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class FBPhotoList extends AbstractScreen implements IFBModelAware, IIOModelAware{
		private var _list : ComponentList;
		private var _pictureLoader : Loader;
		private var _head : Headline;
		private var _button : YellowButton;

		protected var _fbModel : FBModel;
		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}
		
		private var _ioModel : IOModel;
		public function set ioModel(ioModel : IOModel) : void {
			_ioModel = ioModel;
		}

		public function FBPhotoList(id : String) {
			super(id);
		}


		override public function init(data : * = null) : void {

			super.init();

			var friends : Array = _fbModel.userAlbumPhotos;
			friends.sortOn("name");
			
			_head = new Headline(getProperty("headline"), 24, Colors.BLACK);
			_head.width = _width- 140;
			_head.x = BootstrapConstants.SPACER;
			_head.y = BootstrapConstants.SPACER;
			addChild(_head);

			// List
			_list = new ComponentList(Orientation.VERTICAL, FBPhotoListCell, DefaultScrollbar, true);
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
			_list.setData( friends);
			addChild(_list);
			_list.render();
			
			
			_button = new YellowButton(getProperty("button.back"), _width - 2*BootstrapConstants.SPACER);
			_button.submitEvent = new RockdotEvent(StateEvents.STATE_VO_BACK);
			_button.x = BootstrapConstants.SPACER;
			addChild(_button);
			
			// Picture loader
			_pictureLoader = new Loader();
			_pictureLoader.addEventListener(MouseEvent.CLICK, _onPictureLoaderClicked);
			_pictureLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onPictureLoaderComplete);

			_didInit();
		}
		
		override public function render() : void {
			
			super.render();
			
			_list.setSize(_width, _height - 2*BootstrapConstants.HEIGHT_RASTER - 4*BootstrapConstants.SPACER);
			
			_button.x = BootstrapConstants.SPACER;
			_button.y = _height - _button.height - BootstrapConstants.SPACER;
			_button.setWidth(_width - 2*BootstrapConstants.SPACER);

			_list.y = BootstrapConstants.HEIGHT_RASTER + 2 * BootstrapConstants.SPACER;
			_list.hScrollbar.enabled = false;
		}

		private function _onCellCommit(cell : Cell) : void {
			_pictureLoader.load(new URLRequest(cell.data.images[0].source), new LoaderContext(true));
		}

		private function _onPictureLoaderComplete(event : Event) : void {
			_ioModel.importedFile = BitmapUtils.getBitmapFromDisplayObject(_pictureLoader.content);
			new RockdotEvent(StateEvents.ADDRESS_SET, "/image/edit").dispatch();
		}

		private function _onPictureLoaderClicked(event : MouseEvent) : void {
		}

	}
}
