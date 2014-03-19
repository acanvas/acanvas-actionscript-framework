package com.rockdot.plugin.@plugin.package@.command {
	import com.rockdot.core.spring.CoreCommand;
	import com.greensock.TweenLite;
	import com.rockdot.plugin.@plugin.package@.model.@plugin.class.prefix@Model;

	import org.springextensions.actionscript.core.command.BaseEvent;


	public class @plugin.class.prefix@InitCommand extends CoreCommand {
		protected var _model@plugin.class.prefix@ : @plugin.class.prefix@Model;
		public function set @plugin.package@Model(model : @plugin.class.prefix@Model) : void {
			_model@plugin.class.prefix@ = model;
		}
		
		override public function execute(event : BaseEvent = null) : * {
			super.execute(event);
			
			_model@plugin.class.prefix@.success = true;
			
			TweenLite.delayedCall(.1, dispatchCompleteEvent);
			return null;
		}
	}
}