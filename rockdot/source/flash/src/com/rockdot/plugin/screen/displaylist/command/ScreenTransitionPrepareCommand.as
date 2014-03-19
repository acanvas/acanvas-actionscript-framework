package com.rockdot.plugin.screen.displaylist.command {
	import com.rockdot.core.mvc.CompositeCommandWithEvent;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.command.AbstractScreenCommand;
	import com.rockdot.plugin.screen.common.model.ScreenConstants;
	import com.rockdot.plugin.screen.displaylist.command.event.ScreenDisplaylistEvents;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistEffectApplyVO;
	import com.rockdot.plugin.screen.displaylist.command.event.vo.ScreenDisplaylistTransitionApplyVO;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import org.as3commons.async.command.CompositeCommandKind;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public class ScreenTransitionPrepareCommand extends AbstractScreenCommand {
		
		private var _vo : ScreenDisplaylistTransitionApplyVO;
		private var _compositeCommand : CompositeCommandWithEvent;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			_compositeCommand = new CompositeCommandWithEvent(CompositeCommandKind.SEQUENCE);
			_vo = event.data;
			_applyEffect(_vo.transitionType, _vo.targetPrimary, _vo.duration, dispatchCompleteEvent, _vo.targetSecondary);
			
			return null;
		}
		
		private function _applyEffect(effectType : String, target : ISpriteComponent, duration : Number, callback : Function, nextTarget : ISpriteComponent = null) : void {
			
			duration ||= _vo.effect.duration;
			
			var maxdepthTarget : int = 0;
			var maxdepthNextTarget : int = 0;
			if(_vo.effect.applyRecursively){
				 maxdepthTarget = _getDepth(target as DisplayObjectContainer, 0);
				 if(nextTarget){
					maxdepthNextTarget = _getDepth(nextTarget as DisplayObjectContainer, 0);
				 }
			}
			
			//some day, someone will explain this to you.
			switch(effectType){
				case ScreenConstants.EFFECT_IN:
					if(_vo.effect.applyRecursively){
						_addInEffectRecursively(target, 0 , duration, duration, maxdepthTarget);
					}
					_compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_IN, new ScreenDisplaylistEffectApplyVO(_vo.effect, target, duration)), _context);
				break;
				case ScreenConstants.EFFECT_OUT:
					if(_vo.effect.applyRecursively){
						_addOutEffectRecursively(target, 0 , duration, 0, maxdepthTarget);
					}
					_compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_OUT, new ScreenDisplaylistEffectApplyVO(_vo.effect, target, duration)), _context);
				break;
				case ScreenConstants.TRANSITION_SEQUENTIAL:
				
					_compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_OUT, new ScreenDisplaylistEffectApplyVO(_vo.effect, target, duration)), _context);
				
					if(_vo.effect.applyRecursively){
						_addOutEffectRecursively(target, 0 , duration, 0, maxdepthTarget);
						_addInEffectRecursively(nextTarget, 0 , duration, (maxdepthNextTarget * duration) + 2 * duration, maxdepthNextTarget);
					}
					_compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_IN, new ScreenDisplaylistEffectApplyVO(_vo.effect, nextTarget, duration)), _context);
				
				break;
				case ScreenConstants.TRANSITION_PARALLEL:
					_compositeCommand.kind = CompositeCommandKind.PARALLEL;
				
					_compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_OUT, new ScreenDisplaylistEffectApplyVO(_vo.effect, target, duration)), _context);
					
					if(_vo.effect.applyRecursively){
						_addOutEffectRecursively(target, 0 , duration, 0, maxdepthTarget);
						_addInEffectRecursively(nextTarget, 0 , duration, 0, maxdepthNextTarget);
					}
					_compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_IN, new ScreenDisplaylistEffectApplyVO(_vo.effect, nextTarget, duration)), _context);
					
				break;
			}
			
			
			/* add sequence listeners */
			_compositeCommand.addCompleteListener(dispatchCompleteEvent);
			_compositeCommand.addErrorListener(_handleError);
			_compositeCommand.execute();
			
			_stateModel.compositeEffectCommand = _compositeCommand;
		}

		
		private function _addInEffectRecursively(vcs : ISpriteComponent, depth : int, duration : Number, delay : Number, maxdepth : int) : void {
			var child : DisplayObject;
			for (var i : int = 0; i < (vcs as DisplayObjectContainer).numChildren; i++) {
				child = (vcs as DisplayObjectContainer).getChildAt(i);
				if(child is ISpriteComponent){
					_compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_IN, new ScreenDisplaylistEffectApplyVO(_vo.effect, child as ISpriteComponent, duration)), _context);
					_addInEffectRecursively(child as ISpriteComponent, depth+1 , duration, delay, maxdepth);
				}
			}
			
		}
		private function _addOutEffectRecursively(vcs : ISpriteComponent, depth : int, duration : Number, delay : Number, maxdepth : int) : void {
			var child : DisplayObject;
			for (var i : int = 0; i < (vcs as DisplayObjectContainer).numChildren; i++) {
				child = (vcs as DisplayObjectContainer).getChildAt(i);
				if(child is ISpriteComponent){
					_compositeCommand.addCommandEvent(new RockdotEvent(ScreenDisplaylistEvents.APPLY_EFFECT_OUT, new ScreenDisplaylistEffectApplyVO(_vo.effect, child as ISpriteComponent, duration)), _context);
					_addOutEffectRecursively(child as ISpriteComponent, depth+1 , duration, delay, maxdepth);
				}
			}
		}

		private function _getDepth(vcs : DisplayObjectContainer, depth : int) : int {
			var max : int = depth;
			var child : DisplayObject;
			for (var i : int = 0; i < vcs.numChildren; i++) {
				child = vcs.getChildAt(i);
				if(child is ISpriteComponent){
					max = Math.max(_getDepth(child as DisplayObjectContainer, depth+1), max);
				}
			}
			return max;
		}
		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			
			if(_vo.transitionType != ScreenConstants.EFFECT_IN){
				_vo.targetPrimary.destroy();
				_vo.targetPrimary = null;
				_vo = null;
			}
			else{
				if(_vo.targetPrimary.enabled != true){
					_vo.targetPrimary.enabled = true;
				}
			}
			
			return super.dispatchCompleteEvent(result);
		}
	}
}