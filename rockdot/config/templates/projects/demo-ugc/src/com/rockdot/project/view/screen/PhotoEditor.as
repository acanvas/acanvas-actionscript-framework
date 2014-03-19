package com.rockdot.project.view.screen {
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.plugin.io.inject.IIOModelAware;
	import com.rockdot.plugin.io.model.IOModel;
	import com.rockdot.project.command.event.ProjectEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.editor.EditorMain;
	import com.rockdot.project.view.text.Headline;

	public class PhotoEditor extends AbstractScreen implements IIOModelAware{
		private var _head : UITextField;
		private var _pictureEditor : EditorMain;
		
		private var _ioModel : IOModel;
		public function set ioModel(ioModel : IOModel) : void {
			_ioModel = ioModel;
		}

		public function PhotoEditor(id : String)
		{
			super(id);
		}

		override public function init(data : * = null) : void 
		{
			super.init(data);

			// head
			_head = new Headline(getProperty("headline"), 24, Colors.BLACK);
			addChild(_head);
			

			// picture/quote editor
			_pictureEditor = new EditorMain("element.editor");
			_pictureEditor.submitCallback = _handleEditorSubmit;
			addChild(_pictureEditor);
			
			_didInit();
			_pictureEditor.setBitmap(_ioModel.importedFile);
		}

		private function _handleEditorSubmit() : void {
			new RockdotEvent(ProjectEvents.IMAGE_PROCESS, _appModel.image, _handleImagePrepareFinished).dispatch();
		}

		private function _handleImagePrepareFinished(res : * = null) : void {
			new RockdotEvent(ProjectEvents.APP_LOGIN_DISPATCH, {prompt:"upload", next:"/layer/presubmit"}).dispatch();
		}

		override public function render() : void
		{
			_head.x = BootstrapConstants.SPACER;
			_head.y = BootstrapConstants.SPACER;
			_head.width = _width - 2 * BootstrapConstants.SPACER;

			_pictureEditor.x = BootstrapConstants.SPACER;
			_pictureEditor.y = BootstrapConstants.HEIGHT_RASTER + 2 * BootstrapConstants.SPACER;
			_pictureEditor.setSize(_width - 2 * BootstrapConstants.SPACER, _height - BootstrapConstants.HEIGHT_RASTER - 2 * BootstrapConstants.SPACER);
			
			graphics.clear();
			graphics.beginFill(Colors.GREY_DARK, 1);
			graphics.drawRoundRect(0, _pictureEditor.y, _width, _height-_pictureEditor.y, 8, 8);
			graphics.endFill();

			super.render();
		}
		
	}
}
