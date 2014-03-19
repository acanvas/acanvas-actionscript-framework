package com.rockdot.plugin.state.command.event.vo {
	import com.rockdot.core.RockdotVO;
	import com.rockdot.plugin.state.model.vo.StateVO;
	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class VOStateChange extends RockdotVO {
		public var oldVO : StateVO;
		public var newVO : StateVO;
		
		public function VOStateChange(oldVO : StateVO, newVO : StateVO) {
			this.oldVO = oldVO;
			this.newVO = newVO;
		}
	}
}
