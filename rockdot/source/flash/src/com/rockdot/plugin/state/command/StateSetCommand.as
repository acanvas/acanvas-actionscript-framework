package com.rockdot.plugin.state.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.state.command.event.vo.VOStateChange;
	import com.rockdot.plugin.state.model.vo.StateVO;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateSetCommand extends AbstractStateCommand {
		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			var saveHistory : Boolean = true;
			if (_stateModel.historyCount > 0 && _stateModel.history[_stateModel.historyCount].url == event.data.url) {
				saveHistory = false;
			}

			_setStateVO(event.data, saveHistory);
			log.info("Go  to: count {0}, url {1}, history: {2}", [_stateModel.historyCount, _stateModel.history[_stateModel.historyCount].url, saveHistory]);
		}

		private function _setStateVO(stateVO : StateVO, saveToHistory : Boolean) : void {
			if (!_stateModel.currentStateVO || stateVO.url != _stateModel.currentStateVO.url) {
				// initial view after app start
				var naviVOwasNull : Boolean;
				if (!_stateModel.currentStateVO) {
					naviVOwasNull = true;
				}

				var oldNaviVO : StateVO = _stateModel.currentStateVO;

				_stateModel.currentStateVO = stateVO;
				_stateModel.currentPageVOParams = stateVO.params;
				new RockdotEvent(StateEvents.STATE_CHANGE, new VOStateChange(oldNaviVO, stateVO), dispatchCompleteEvent).dispatch();

				if (naviVOwasNull) {
					new RockdotEvent(StateEvents.STATE_PARAMS_CHANGE, _stateModel.currentStateVO).dispatch();
				}

				if (saveToHistory) {
					_addToHistory(_stateModel.currentStateVO);
				}
			} else {
				// Same naviVO, check if params have changed.
				if (stateVO.params != _stateModel.currentPageVOParams) {
					// Different params
					_stateModel.currentPageVOParams = stateVO.params;
					
					_stateModel.addressService.onAddressChanged(_stateModel.currentStateVO);
					if(_stateModel.currentPage){
						_stateModel.currentPage.setData( _stateModel.currentPageVOParams );
					}
				} else {
					// Same params. Do nothing.
				}
			}
		}

		private function _addToHistory(naviVO : StateVO) : void {
			_stateModel.historyCount++;
			_stateModel.history[_stateModel.historyCount] = naviVO;

			// Cleanup
			var n : uint = _stateModel.history.length;
			for (var i : int = _stateModel.historyCount + 1; i < n; i++) {
				_stateModel.history.pop();
			}

			n = _stateModel.history.length;
			var history : String = "";
			for (i = 0; i < n; i++) {
				history += _stateModel.history[i].view_id + ", ";
			}
			log.info("History: " + history);
		}
	}
}
