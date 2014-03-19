package com.rockdot.plugin.io.inject {
	import com.rockdot.plugin.io.model.IOModel;
	/**
	 * @author nilsdoehring
	 */
	public interface IIOModelAware {
		function set ioModel(ioModel : IOModel) : void;
	}
}
