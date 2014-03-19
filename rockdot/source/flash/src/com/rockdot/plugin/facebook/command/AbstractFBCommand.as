package com.rockdot.plugin.facebook.command {
	import com.rockdot.core.mvc.CoreCommand;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;

	public class AbstractFBCommand extends CoreCommand implements IFBModelAware {
		protected var _fbModel : FBModel;
		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}

	}
}