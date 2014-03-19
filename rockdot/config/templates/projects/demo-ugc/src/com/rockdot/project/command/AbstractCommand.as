package com.rockdot.project.command {
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.project.inject.IModelAware;
	import com.rockdot.project.model.Model;

	public class AbstractCommand extends CoreCommand implements IModelAware {
		protected var _appModel : Model;

		public function set appModel(appModel : Model) : void {
			_appModel = appModel;
		}

	}
}