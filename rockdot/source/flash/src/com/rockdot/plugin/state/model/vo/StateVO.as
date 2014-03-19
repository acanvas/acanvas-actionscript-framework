package com.rockdot.plugin.state.model.vo {
	import com.rockdot.core.RockdotVO;

	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class StateVO extends RockdotVO {
		public var view_id : String;
		public var property_key : String;
		public var substate : String;
		public var tree_order : uint;
		public var tree_parent: uint;
		
		public var url : String;
		public var label : String;
		public var title : String;
		public var params : Object;
		public var transition : String;
		public var madUI : XML;

		public function StateVO(...params){
			super(params);
			if(!property_key){
				property_key = view_id;
			}
		}

	}
}
