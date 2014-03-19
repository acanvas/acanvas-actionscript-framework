package com.rockdot.project.view.screen {
	import com.danielfreeman.extendedMadness.UIe;
	import com.danielfreeman.madcomponents.UI;
	import com.danielfreeman.madcomponents.UIButton;
	import com.danielfreeman.madcomponents.UIDividedList;
	import com.danielfreeman.madcomponents.UIForm;
	import com.danielfreeman.madcomponents.UINavigation;
	import com.danielfreeman.stage3Dacceleration.LongListScrolling;
	import com.danielfreeman.stage3Dacceleration.PageFlipping;
	import com.danielfreeman.stage3Dacceleration.PageFlippingE;
	import com.rockdot.plugin.screen.displaylist.view.ManagedSpriteComponentMC3D;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.plugin.state.model.vo.StateVO;

	import org.as3commons.lang.Assert;

	import flash.events.Event;




	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 * 
	 * Subclass View to create ViewComponents with a lifecycle.
	 * View does provide a Logger.
	 */
	public class PageFlippingDemo extends ManagedSpriteComponentMC3D implements  IStateModelAware {
		private var _stateModel : StateModel;
		private var _layout : XML;
		private var _navigation : UINavigation;
		private var _pageFlipping : PageFlippingE;
		private var _listScrolling : LongListScrolling;
		private var _list : UIDividedList;
		private var _columns0 : UIForm;
		private var _columns1 : UIForm;
		
		protected static const WORDS:Vector.<String> = new <String>["Open Source","Popular","Lightweight","Versatile","Styleable","Skinnable","Powerful","Easily Extensible","Stage3D Accelerated"];

		public function PageFlippingDemo(id : String) {
			super(id);

			Assert.notNull(_context, "the objectFactory argument must not be null");

		}

		override public function init(data : * = null) : void {
			
			var aPages:Array = _stateModel.getPageVOArray();
			
			_layout = 
			<navigation id="pages" alt="true" colour="#334433" background="#FFCCFF" rightButton="MadPages">
			
			</navigation>;

			//add pages to ScreenNavigator				
			for (var k : int = 0; k < aPages.length; k++) {
				var stateVO : StateVO = aPages[k];
				_layout.child("navigation").appendChild(stateVO.madUI);
			}
			
			UIe.create(this, _layout);
			
			_navigation = UINavigation(UI.findViewById("pages"));
			_navigation.navigationBar.rightButton.addEventListener(UIButton.CLICKED, pageFlipping);
			_navigation.autoForward = false;
			
			//Populate the first list
			var aData:Array = [];
			for (var i:int=0; i<WORDS.length; i++) {
				aData.push({label:WORDS[i]/*, image:getQualifiedClassName(PICTURES[i%PICTURES.length])*/, label2:'here is some small text'});
			}
			_list = UIDividedList(UI.findViewById("list"));
			var groupedData:Array = [];
			for (var j:int = 0; j<5; j++)
				groupedData.push("MadComponents is ...", aData);
			_list.data = groupedData;

			_columns0 = UIForm(UI.findViewById("columns0"));
			_columns1 = UIForm(UI.findViewById("columns1"));
			
			addEventListener(PageFlipping.FINISHED, _pageFlippingFinished);
			
			super.init(data);
		}

		override protected function _onContextCreated(event : Event) : void {
			_pageFlipping = new PageFlippingE();
			_pageFlipping.containerPageTextures(_navigation);
			_listScrolling = new LongListScrolling();
			_listScrolling.allListTextures();
		}
		
		protected function pageFlipping(event:Event):void {
			_listScrolling.freezeLists();
			if (_navigation.pageNumber < 3) {
				_pageFlipping.updatePage(_navigation.pageNumber, [_columns0, _columns1, _list][_navigation.pageNumber]);
			}
			_pageFlipping.zoomOutToMadPages(true);
		}
		
		override protected function _pageFlippingFinished( event : Event):void {
		}


		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}
	}
}
