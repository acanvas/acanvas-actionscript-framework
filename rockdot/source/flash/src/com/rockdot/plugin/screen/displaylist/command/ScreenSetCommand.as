package com.rockdot.plugin.screen.displaylist.command {
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.model.ScreenConstants;
	import com.rockdot.plugin.screen.displaylist.command.event.ScreenDisplaylistEvents;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistTransitionPrepareVO;
	import com.rockdot.plugin.screen.displaylist.view.IManagedSpriteComponent;
	import com.rockdot.plugin.state.command.AbstractStateCommand;
	import com.rockdot.plugin.state.command.event.vo.VOStateChange;
	import com.rockdot.plugin.state.model.StateConstants;
	import com.rockdot.plugin.state.model.vo.StateVO;




	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class ScreenSetCommand extends AbstractStateCommand {
		private var _currentVO : StateVO;
		private var _nextVO : StateVO;
		private var _currentStateElement : IManagedSpriteComponent;
		private var _nextStateElement : IManagedSpriteComponent;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			
			var e : VOStateChange = event.data;
			_currentVO = e.oldVO;
			_nextVO = e.newVO;
			var modal : Boolean = false;

			if (_stateModel.currentState == StateConstants.MAIN_TRANSITIONING) {

				_stateModel.currentTransition.cancel(  );

				if(_stateModel.compositeTransitionCommand){
					_stateModel.compositeTransitionCommand.cancel();
					_stateModel.compositeTransitionCommand = null;
				}

				if(_stateModel.compositeEffectCommand){
					_stateModel.compositeEffectCommand.cancel();
					_stateModel.compositeEffectCommand = null;
				}

//				TweenMax.killAll();
			}

			_currentStateElement = null;
			
			if (_stateModel.currentPage && _currentVO && _nextVO && _stateModel.currentPage.name == _nextVO.view_id && _currentVO.substate == StateConstants.SUB_MODAL) {
				//do not retrieve nextStateElement from Context, since it is already present as modal background. see handling in switch/case below
			}
			else {
				_nextStateElement = _context.getObject(_nextVO.view_id, [_nextVO.view_id]);
				
				if (_nextVO.params) {
					_nextStateElement.setData(_nextVO.params);
				}
			}

			_stateModel.currentState = StateConstants.MAIN_TRANSITIONING;
			_stateModel.currentTransition = _context.getObject(_nextVO.transition);
			var transitionType : String = "";

			if (!_currentVO) {
				// 1. nullToNormal
				transitionType = ScreenConstants.TRANSITION_NONE_TO_NORMAL;
				_stateModel.currentPage = _nextStateElement;
			} else {

				if (_currentVO.substate == StateConstants.SUB_MODAL) {
					
					if (_stateModel.currentPage.name == _nextVO.view_id) {
						// 5.modalBack. _nextStateElement hasn't been created (line 36)
						transitionType = ScreenConstants.TRANSITION_MODAL_BACK;
						_stateModel.currentTransition = _context.getObject("transition.default.modal");
						_nextStateElement = _stateModel.currentPage;
					} else if (_nextVO.substate == StateConstants.SUB_MODAL) {
						// 4. modalToModal
						transitionType = ScreenConstants.TRANSITION_MODAL_TO_MODAL;
						modal = true;
					} else {
						// 6. modalToNormal
						_currentStateElement = _stateModel.currentPage;
						_stateModel.currentPage = _nextStateElement;
						transitionType = ScreenConstants.TRANSITION_MODAL_TO_NORMAL;
					}
				} else if (_nextVO.substate == StateConstants.SUB_MODAL) {
					// 3. normalToModal
					_currentStateElement = _stateModel.currentPage;
					transitionType = ScreenConstants.TRANSITION_NORMAL_TO_MODAL;
					modal = true;
					_stateModel.currentPage.enabled = false;
				} else {
					// 2. normalToNormal
					_currentStateElement = _stateModel.currentPage;
					_stateModel.currentPage = _nextStateElement;
					transitionType = ScreenConstants.TRANSITION_NORMAL_TO_NORMAL;
				}
			}

			new RockdotEvent(ScreenDisplaylistEvents.TRANSITION_PREPARE, new ScreenDisplaylistTransitionPrepareVO(transitionType, _currentStateElement, _stateModel.currentTransition, _nextStateElement, modal, _stateModel.currentTransition.initialAlpha), _onTransitionEnd).dispatch();
		}

		private function _onTransitionEnd(payload : * = null) : void {
			_stateModel.currentState = StateConstants.MAIN_PRESENTING;

			if (_nextVO.substate == StateConstants.SUB_MODAL) {
				_stateModel.currentSubState = StateConstants.SUB_MODAL;
				_stateModel.modalizedPage = _stateModel.currentPage;
			}

			dispatchCompleteEvent();
		}
	}
}
