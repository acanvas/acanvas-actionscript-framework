package com.rockdot.plugin.screen.displaylist.command {
	import com.rockdot.core.mvc.CompositeCommandWithEvent;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.effect.IEffect;
	import com.rockdot.plugin.screen.common.command.AbstractScreenCommand;
	import com.rockdot.plugin.screen.common.command.event.ScreenEvents;
	import com.rockdot.plugin.screen.common.model.ScreenConstants;
	import com.rockdot.plugin.screen.displaylist.command.event.ScreenDisplaylistEvents;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistAppearDisappearVO;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistEffectApplyVO;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistTransitionApplyVO;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistTransitionPrepareVO;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import org.as3commons.async.command.CompositeCommandKind;
	import org.as3commons.async.operation.event.OperationEvent;

	import flash.display.DisplayObject;

	public class ScreenTransitionRunCommand extends AbstractScreenCommand {
		private var _vo : ScreenDisplaylistTransitionPrepareVO;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);

			var APPLY_EFFECT : String = ScreenDisplaylistEvents.TRANSITION_RUN;

			_uiService.lock();
			_vo = event.data;

			var compositeCommand : CompositeCommandWithEvent = new CompositeCommandWithEvent(CompositeCommandKind.SEQUENCE);

			// check if the transition requires an extra root sprite
			if (_vo.effect && _vo.effect.useSprite()) {
				switch(_vo.transitionType) {
					case ScreenConstants.TRANSITION_NORMAL_TO_MODAL:
					case ScreenConstants.TRANSITION_MODAL_TO_MODAL:
						_uiService.layer.addChild(_vo.effect.sprite);
						break;
					default:
						_uiService.content.addChild(_vo.effect.sprite);
						break;
				}
			}

			if (_vo.outTarget && _vo.outTarget.enabled) {
				_vo.outTarget.enabled = false;
			}

			if (_vo.inTarget && _vo.transitionType != ScreenConstants.TRANSITION_MODAL_BACK) {
				_vo.inTarget.alpha = _vo.initialAlpha;

				// provide intarget with stage
				if (_vo.inTarget.stage == null) {
					switch(_vo.transitionType) {
						case ScreenConstants.TRANSITION_NORMAL_TO_MODAL:
						case ScreenConstants.TRANSITION_MODAL_TO_MODAL:
							// add intarget to layer stack
							_uiService.layer.addChild(_vo.inTarget as DisplayObject);
							break;
						default:
							_uiService.content.addChild(_vo.inTarget as DisplayObject);
							break;
					}
				}

				compositeCommand.addCommandEvent(new RockdotEvent(ScreenEvents.RESIZE, _vo.inTarget), _context);
				compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.SCREEN_INIT, _vo.inTarget), _context);
			}

			var layer : ISpriteComponent;

			switch(_vo.transitionType) {
				case ScreenConstants.TRANSITION_NONE_TO_NORMAL:
					compositeCommand.addCommandEvent(new RockdotEvent(APPLY_EFFECT, new ScreenDisplaylistTransitionApplyVO(_vo.effect, ScreenConstants.EFFECT_IN, _vo.inTarget, _vo.effect.duration)), _context);
					break;
				case ScreenConstants.TRANSITION_NORMAL_TO_NORMAL:
					compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.DISAPPEAR, new ScreenDisplaylistAppearDisappearVO(_vo.outTarget, 0, false)), _context);
					compositeCommand.addCommandEvent(new RockdotEvent(APPLY_EFFECT, new ScreenDisplaylistTransitionApplyVO(_vo.effect, _vo.effect.type, _vo.outTarget, _vo.effect.duration, _vo.inTarget)), _context);
					break;
				case ScreenConstants.TRANSITION_NORMAL_TO_MODAL:
					_applyModalFilter();
					compositeCommand.addCommandEvent(new RockdotEvent(APPLY_EFFECT, new ScreenDisplaylistTransitionApplyVO(_vo.effect, ScreenConstants.EFFECT_IN, _vo.inTarget, _vo.effect.duration)), _context);
					break;
				case ScreenConstants.TRANSITION_MODAL_TO_MODAL:
					_vo.outTarget = _uiService.layer.getChildAt(0) as ISpriteComponent;
					compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.DISAPPEAR, new ScreenDisplaylistAppearDisappearVO(_vo.outTarget, 0, false)), _context);
					compositeCommand.addCommandEvent(new RockdotEvent(APPLY_EFFECT, new ScreenDisplaylistTransitionApplyVO(_vo.effect, _vo.effect.type, _vo.outTarget, _vo.effect.duration, _vo.inTarget)), _context);
					break;
				case ScreenConstants.TRANSITION_MODAL_BACK:
					// unblur content
					_removeModalFilter();
					compositeCommand.addCommandEvent(new RockdotEvent(APPLY_EFFECT, new ScreenDisplaylistTransitionApplyVO(_vo.effect, ScreenConstants.EFFECT_OUT, _uiService.layer.getChildAt(_uiService.layer.numChildren-1) as ISpriteComponent, _vo.effect.duration), _destroyLayer), _context);
					break;
				case ScreenConstants.TRANSITION_MODAL_TO_NORMAL:
					// unblur content
					_removeModalFilter();
					layer = _uiService.layer.getChildAt(0) as ISpriteComponent;
					compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.DISAPPEAR, new ScreenDisplaylistAppearDisappearVO(layer, 0, false)), _context);
					var effect : IEffect = _context.getObject("transition.default.modal");
					compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_OUT, new ScreenDisplaylistEffectApplyVO(effect, layer, _vo.effect.duration), _destroyLayer), _context);
					compositeCommand.addCommandEvent(new RockdotEvent(APPLY_EFFECT, new ScreenDisplaylistTransitionApplyVO(_vo.effect, _vo.effect.type, _vo.outTarget, _vo.effect.duration, _vo.inTarget)), _context);
					break;
			}

			compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPEAR, new ScreenDisplaylistAppearDisappearVO(_vo.inTarget, _vo.effect.duration)), _context);

			/* add sequence listeners */
			compositeCommand.addCompleteListener(_onSequenceComplete);
			compositeCommand.addErrorListener(_handleError);
			compositeCommand.execute();

			_stateModel.compositeTransitionCommand = compositeCommand;

			return null;
		}

		private function _applyModalFilter() : void {
			_uiService.content.enabled = false;
//			_uiService.content.mouseEnabled = false;
			_uiService.background.enabled = false;
			
			// blur background/content
			if (_uiService.modalBackgroundFilter != null) {
				_uiService.content.filters = [_uiService.modalBackgroundFilter];
				if (_uiService.background.numChildren > 0) {
					_uiService.background.filters = [_uiService.modalBackgroundFilter];
				}
			}
		}

		private function _removeModalFilter() : void {
//			if(_uiService.content.enabled != true){
//				_uiService.content.enabled = true;
//			}
//			_uiService.content.mouseEnabled = true;
			_uiService.background.enabled = true;
			// unblur background/content
			_uiService.content.filters = [];
			_uiService.background.filters = [];
		}

		private function _destroyLayer(result : * = null) : void {
			if (_uiService.layer.numChildren > 0) {
				var layer : ISpriteComponent = _uiService.layer.getChildAt(0) as ISpriteComponent;
				layer.destroy();
				layer = null;
			}
		}

		private function _onSequenceComplete(event : OperationEvent = null) : void {
			if (_vo.effect) {
				_vo.effect.destroy();
			}

			if (_vo.inTarget) {
				if (_vo.inTarget.enabled != true) {
					_vo.inTarget.enabled = true;
				}
			}
			_vo = null;
			_uiService.unlock();
			dispatchCompleteEvent();
		}
	}
}