package com.rockdot.project.view.screen {
	import com.jvm.components.Orientation;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.component.common.form.ComponentList;
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.library.view.component.common.scrollable.DefaultScrollbar;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.plugin.state.model.vo.StateVO;
	import com.rockdot.project.view.element.StateVOCell;

	import flash.system.Capabilities;
	import flash.system.TouchscreenType;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class Home extends AbstractScreen implements IStateModelAware{
		private var _list : ComponentList;
		private var _stateModel : StateModel;


		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}
		
		public function Home(id : String)
		{
				super(id);
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);

			_list = new ComponentList( Orientation.VERTICAL, StateVOCell, DefaultScrollbar, true);
			_list.touchEnabled = true;
			_list.doubleClickEnabled = false;
			_list.keyboardEnabled = false;
			_list.doubleClickToZoom = false;
			_list.bounce = Capabilities.touchscreenType != TouchscreenType.NONE;//bounce if touchscreen
			_list.setData(_stateModel.getPageVOArray(true, 1));
			_list.submitCallback = _onCellCommit;
			addChild(_list); 
			
			
			_didInit();
		}


		private function _onCellCommit(cell : Cell) : void
		{
			var vo : StateVO = cell.data as StateVO;
			new RockdotEvent(StateEvents.ADDRESS_SET, vo.url).dispatch();
		}

		override public function render() : void {
			super.render();
			
			_list.setSize(_width, _height);
		}

	}
}
