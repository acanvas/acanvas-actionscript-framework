package com.rockdot.plugin.tracking.omniture.inject {
	import com.rockdot.plugin.tracking.omniture.model.OmnitureModel;
	/**
	 * @author nilsdoehring
	 */
	public interface IOmnitureModelAware {
		function set omnitureModel(omnitureModel : OmnitureModel) : void
	}
}
