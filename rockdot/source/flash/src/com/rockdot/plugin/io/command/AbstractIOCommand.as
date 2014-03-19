package com.rockdot.plugin.io.command {
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.plugin.io.inject.IIOModelAware;
	import com.rockdot.plugin.io.model.IOModel;

	public class AbstractIOCommand extends CoreCommand implements IIOModelAware {
		protected var _ioModel : IOModel;

		public function set ioModel(ioModel : IOModel) : void {
			_ioModel = ioModel;
		}


	}
}