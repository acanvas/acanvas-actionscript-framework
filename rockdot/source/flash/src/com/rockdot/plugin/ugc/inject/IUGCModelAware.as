package com.rockdot.plugin.ugc.inject {
	import com.rockdot.plugin.ugc.model.UGCModel;
	/**
	 * @author nilsdoehring
	 */
	public interface IUGCModelAware {
		function set ugcModel(ugcModel : UGCModel) : void
	}
}
