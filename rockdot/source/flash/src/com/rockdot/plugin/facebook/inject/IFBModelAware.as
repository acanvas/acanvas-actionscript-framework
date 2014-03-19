package com.rockdot.plugin.facebook.inject {
	import com.rockdot.plugin.facebook.model.FBModel;
	/**
	 * @author nilsdoehring
	 */
	public interface IFBModelAware {
		function set fbModel(fbModel : FBModel) : void;
	}
}
