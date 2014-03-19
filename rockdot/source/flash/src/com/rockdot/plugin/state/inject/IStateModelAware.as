package com.rockdot.plugin.state.inject {
	import com.rockdot.plugin.state.model.StateModel;
	/**
	 * @author nilsdoehring
	 */
	public interface IStateModelAware {
		function set stateModel(stateModel : StateModel) : void;
	}
}
