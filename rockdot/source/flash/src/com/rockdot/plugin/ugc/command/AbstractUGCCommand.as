package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.plugin.ugc.command.operation.PersistenceOperation;
	import com.rockdot.plugin.ugc.inject.IUGCModelAware;
	import com.rockdot.plugin.ugc.model.UGCModel;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.event.OperationEvent;

	public class AbstractUGCCommand extends CoreCommand implements IUGCModelAware{
		protected var _ugcModel : UGCModel;
		public function set ugcModel(ugcModel : UGCModel) : void {
			_ugcModel = ugcModel;
		}

		protected function amfOperation(string : String, object : Object = null) : void {
			var operation : IOperation = new PersistenceOperation(_ugcModel.service, string, object);
			operation.addCompleteListener(dispatchCompleteEvent);
			operation.addErrorListener(_handleError);
		}
		
		override protected function _handleError(event : OperationEvent) : void {
			log.error(event.error);
			dispatchErrorEvent(event.error);
		}
	}
}