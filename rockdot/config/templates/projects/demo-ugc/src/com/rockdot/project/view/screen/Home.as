package com.rockdot.project.view.screen {
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.ugc.model.vo.UGCImageItemVO;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.home.HomeHeader;
	import com.rockdot.project.view.element.home.HomeTutorial;
	import com.rockdot.project.view.element.pager.MultiRowPhotoPager;
	import com.rockdot.project.view.text.Headline;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class Home extends AbstractScreen{

		private var _header : HomeHeader;
		private var _tutorial : HomeTutorial;
		private var _photoPager : MultiRowPhotoPager;
		private var _pagerHeadline : Headline;

		public function Home(id : String)
		{
				super(id);
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);
			
			_header = new HomeHeader(name + ".header");
			addChild(_header);
			
			_tutorial = new HomeTutorial(name + ".tutorial");
			addChild(_tutorial);
			
			_pagerHeadline = new Headline(getProperty("pager.headline"), 18, Colors.BLACK);
			addChild(_pagerHeadline);
			
			// gallery display
			_photoPager = new MultiRowPhotoPager();
			_photoPager.submitCallback = _onItemClicked;
			addChild(_photoPager);

			_photoPager.resetAndLoad();
						
			_didInit();
		}

		private function _onItemClicked(dao : UGCItemVO) : void {
			_log.debug("Item clicked. id: {0}, url_big: {1}", [dao.id, (dao.type_dao as UGCImageItemVO).url_big]);
			_appModel.currentUGCItem = dao;
			new RockdotEvent(StateEvents.ADDRESS_SET, "/image/view").dispatch();
		}

		override public function render() : void {
			super.render();
			
			_header.setWidth(_width);
			
			_tutorial.x = 0;
			_tutorial.y = _header.y + _header.height + 2*BootstrapConstants.SPACER;
			_tutorial.setWidth(_width);

			_pagerHeadline.x = 2*BootstrapConstants.SPACER;
			_pagerHeadline.y = _tutorial.y + _tutorial.height;
			_pagerHeadline.width = _width - BootstrapConstants.SPACER;
			
			_photoPager.x = 0;
			_photoPager.y = _pagerHeadline.y + _pagerHeadline.textHeight + BootstrapConstants.SPACER;
			_photoPager.setSize(_width, _height - _photoPager.y );

			//readjustments due to varying device/pager height combinations
			_photoPager.y = _photoPager.y + ((_height - _photoPager.y)/2 - _photoPager.height/2);
			_pagerHeadline.y = _photoPager.y - _pagerHeadline.textHeight - BootstrapConstants.SPACER;
			
		}
		
	}
}
