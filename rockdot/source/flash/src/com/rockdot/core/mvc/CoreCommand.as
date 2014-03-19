package com.rockdot.core.mvc {
	import org.as3commons.async.command.IAsyncCommand;
	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.async.operation.impl.AbstractOperation;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;



	public class CoreCommand extends AbstractOperation implements IAsyncCommand, IApplicationContextAware {
		protected var log : ILogger = getLogger(ClassUtils.forInstance(this));			

		protected var _callback : Function;
		
		protected function getProperty(key : String) : String {
			return _context.propertiesProvider.getProperty(key);
		}
		
		protected var _context : IApplicationContext;
		public function get applicationContext() : IApplicationContext {
			return _context;
		}
		public function set applicationContext(value : IApplicationContext) : void {
			_context = value;
		}


		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			if(result && result is OperationEvent){
				result = result.result;
			}
			if(_callback != null) {
				_callback.call(null, result);
				_callback = null;
			}
			return super.dispatchCompleteEvent(result);
		}

		protected function _handleError(event : OperationEvent) : void {
			log.error(event.error);
			dispatchErrorEvent(event.error);
		}

		public function execute(event : RockdotEvent = null) : * {
			if(event && event.completeCallBack != null) {
				_callback = event.completeCallBack;
			}
		}
		
		//TODO
		protected function dispatchMessage(string : String) : void {
			log.info("Message: " + string);
//			new BaseEvent(StateEvents.ADDRESS_SET, string).dispatch();
		}
		//TODO
		protected function hideMessage(string : String) : void {
//			new BaseEvent(StateEvents.ADDRESS_UNSET, string).dispatch();
		}
	}
}