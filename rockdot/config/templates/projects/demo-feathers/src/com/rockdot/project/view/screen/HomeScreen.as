package com.rockdot.project.view.screen {
	import feathers.controls.Header;
	import feathers.controls.List;
	import feathers.data.ListCollection;
	import feathers.skins.StandardIcons;

	import starling.events.Event;
	import starling.textures.Texture;

	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.feathers.view.RockdotFeatherScreen;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.plugin.state.model.vo.StateVO;



	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class HomeScreen extends RockdotFeatherScreen implements IStateModelAware{
		private var _list : feathers.controls.List;

		protected var _stateModel : StateModel;
		private var _header : Header;

		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}

		public function HomeScreen() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void {

			
			this._header = new Header();
			this._header.title = "Feathers";
			this.addChild(this._header);

			this._list = new feathers.controls.List();
			_list.dataProvider = new ListCollection( _stateModel.getPageVOArray(true, 1) );
			this._list.typicalItem = {label: "Item 1000"};
			this._list.isSelectable = true;
			this._list.scrollerProperties.hasElasticEdges = true;
			this._list.itemRendererProperties.labelField = "label";
			this._list.itemRendererProperties.accessorySourceFunction = accessorySourceFunction;
			this._list.addEventListener(Event.CHANGE, list_changeHandler);
			this.addChildAt(this._list, 0);
			
		}
		
		private function accessorySourceFunction(item:Object):Texture
		{
			return StandardIcons.listDrillDownAccessoryTexture;
		}

		private function list_changeHandler(event : Event) : void {
            new RockdotEvent(StateEvents.ADDRESS_SET, (_list.selectedItem as StateVO).url).dispatch();
		}
		
		override protected function draw():void
		{
			this._header.width = this.actualWidth;
			this._header.validate();

			this._list.y = this._header.height;
			this._list.width = this.actualWidth;
			this._list.height = this.actualHeight - this._list.y;
		}


	}
}
