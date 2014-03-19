package com.rockdot.project.view.element.frame {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.command.event.IOEvents;
	import com.rockdot.plugin.io.command.event.vo.IOURLOpenVO;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.project.model.Colors;

	import flash.display.DisplayObject;
	import flash.display.Shape;


	public class AbstractMenuBar extends RockdotSpriteComponent implements IStateModelAware{
		protected var _stateModel : StateModel;

		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}
		
		private var _arr : Array;
		private var _bg : Shape;

		public function AbstractMenuBar() {
			super();
			
			_bg = new Shape();
			addChild(_bg);			

			_arr = new Array();
		}
		
		
		override public function render() : void {
			super.render();
			
			// bg
			_bg.graphics.clear();
			_bg.graphics.beginFill(Colors.WHITE, .35);
			_bg.graphics.drawRoundRect(0, 0, _width, BootstrapConstants.HEIGHT_RASTER, 4, 4);
			_bg.graphics.endFill();
			
			
			// buttons
			var prev : DisplayObject;
			var current : DisplayObject;
			for (var i : int = 1; i < numChildren; i++) {
				current = getChildAt(i);
				current.x = BootstrapConstants.SPACER;
				if(prev){
					current.x += Math.round(prev.x + prev.width + 2);
				}
				prev = current;	
			}
		}
		
		public function setPath(path:String) : void {
			for(var i:String in _arr) {
				_arr[i].deselect();
			}
			if(_arr[path]){
				_arr[path].select();
			}
		}
		
		protected function _createMenuItem(key : String, fontSize : int = 18) : void {
			var menuItem : MenuButton = new MenuButton(getProperty(key).toUpperCase(), fontSize);

			var url : String = getProperty(key + ".url");
			if(url.indexOf("http") != -1){
				menuItem.submitEvent = new RockdotEvent(IOEvents.URL_OPEN, new IOURLOpenVO(url, "_blank", "width=1000,height=600,left=50,top=50,status=yes,scrollbars=yes,resizable=yes"));
			}
			else{
				menuItem.submitEvent = new RockdotEvent(StateEvents.ADDRESS_SET, url);
				_arr[url] = menuItem; 
			}
			addChild(menuItem);
		}
		
		
	}
}
