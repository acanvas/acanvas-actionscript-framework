package com.rockdot.plugin.state.model {
	import com.google.analytics.GATracker;
	import com.jvm.utils.SortedDictionary;
	import com.rockdot.core.mvc.CompositeCommandWithEvent;
	import com.rockdot.library.view.effect.IEffect;
	import com.rockdot.plugin.screen.displaylist.view.IManagedSpriteComponent;
	import com.rockdot.plugin.state.model.vo.StateVO;
	import com.rockdot.plugin.state.service.IAddressService;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateModel implements IApplicationContextAware{

		protected var _log : ILogger = getLogger(StateModel);
		
		protected var _context : IApplicationContext;
		public function get applicationContext() : IApplicationContext {
			return _context;
		}
		public function set applicationContext(value : IApplicationContext) : void {
			_context = value as IApplicationContext;
		}
		
		protected var _addressService : IAddressService;
		public function get addressService() : IAddressService {
			return _addressService;
		}
		public function set addressService(navigationProxy : IAddressService) : void {
			_addressService = navigationProxy;
		}

		protected var _history : Array;
		public function get history() : Array {
			return _history;
		}
		public function set history(history : Array) : void {
			_history = history;
		}

		protected var _historyCount : int = -1;
		public function get historyCount() : int {
			return _historyCount;
		}
		public function set historyCount(historyCount : int) : void {
			_historyCount = historyCount;
		}
		
		
		private var _currentState : String;
		public function get currentState() : String {
			return _currentState;
		}
		public function set currentState(currentState : String) : void {
			_currentState = currentState;
		}

		private var _currentSubState : String;
		public function get currentSubState() : String {
			return _currentSubState;
		}
		public function set currentSubState(currentSubState : String) : void {
			_currentSubState = currentSubState;
		}
		
		
		private var _currentPage : IManagedSpriteComponent;
		public function get currentPage() : IManagedSpriteComponent {
			return _currentPage;
		}
		public function set currentPage(currentPage : IManagedSpriteComponent) : void {
			_currentPage = currentPage;
		}
		
		private var _pageVOs : SortedDictionary;
		public function get pageVOs() : SortedDictionary {
			return _pageVOs;
		}

		private var _currentPageVO : StateVO;
		public function get currentStateVO() : StateVO {
			return _currentPageVO;
		}
		public function set currentStateVO(pageVO : StateVO) : void {
			_currentPageVO = pageVO;
		}

		private var _currentPageVOParams : Object;
		public function get currentPageVOParams() : Object {
			return _currentPageVOParams;
		}
		public function set currentPageVOParams(pageVOParams : Object) : void {
			_currentPageVOParams = pageVOParams;
		}
		
		
		private var _modalizedPage : IManagedSpriteComponent;
		public function get modalizedPage() : IManagedSpriteComponent {
			return _modalizedPage;
		}
		public function set modalizedPage(modalizedPage : IManagedSpriteComponent) : void {
			_modalizedPage = modalizedPage;
		}
		
		//TODO move to tracking plugin
		private var _tracker : GATracker;
		public function get tracker() : GATracker {
			return _tracker;
		}
		public function set tracker(tracker : GATracker) : void {
			_tracker = tracker;
		}

		public var _currentTransition : IEffect;
		public function get currentTransition() : IEffect {
			return _currentTransition;
		}
		public function set currentTransition(currentTransition : IEffect) : void {
			_currentTransition = currentTransition;
		}
		private var _compositeTransitionCommand : CompositeCommandWithEvent;

		public function get compositeTransitionCommand() : CompositeCommandWithEvent {
			return _compositeTransitionCommand;
		}

		public function set compositeTransitionCommand(compositeTransitionCommand : CompositeCommandWithEvent) : void {
			_compositeTransitionCommand = compositeTransitionCommand;
		}
		private var _compositeEffectCommand : CompositeCommandWithEvent;
		public function get compositeEffectCommand() : CompositeCommandWithEvent {
			return _compositeEffectCommand;
		}

		public function set compositeEffectCommand(compositeEffectCommand : CompositeCommandWithEvent) : void {
			_compositeEffectCommand = compositeEffectCommand;
		}
		
		public function StateModel() {
			_history = [];
			_pageVOs = new SortedDictionary();
		}
		
		public function addStateVO(pageVO : StateVO) : void {
			pageVO.label = _context.propertiesProvider.getProperty(pageVO.view_id + ".label");
			pageVO.title = _context.propertiesProvider.getProperty(pageVO.view_id + ".title");
			if(pageVO.url == null){
				pageVO.url = _context.propertiesProvider.getProperty(pageVO.view_id + ".url");
			}
			var voKey : String = pageVO.url.toLowerCase();
			_pageVOs.addItem(voKey, pageVO);
			_log.info("Registered URL: " + voKey);
		}


		public function getPageVOArray(sort : Boolean = true, tree_parent : int = 0) : Array {
			var naviVOs : Array = _pageVOs.getSortedValues();
			var arr : Array = [];
			if(sort){
				naviVOs.sortOn("tree_order", Array.NUMERIC);
			}
			for (var i : int = 0; i < naviVOs.length; i++) {
				if(naviVOs[i]["tree_parent"] == tree_parent){
					arr.push(naviVOs[i]);
				}
			}
			return arr;
		}
		
		public function getPageVO(url : String) : StateVO {
			return _pageVOs.getItem(url.toLowerCase());
		}

		

		
	}
}
