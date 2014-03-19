package com.rockdot.project.inject {
	import com.rockdot.project.model.Model;
	/**
	 * @author nilsdoehring
	 */
	public interface IModelAware {
		function set appModel(appModel : Model) : void;
	}
}
