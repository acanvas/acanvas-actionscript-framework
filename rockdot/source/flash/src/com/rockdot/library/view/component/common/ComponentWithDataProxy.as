package com.rockdot.library.view.component.common {
	import com.rockdot.plugin.io.model.DataProxy;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;



	public class ComponentWithDataProxy extends RockdotSpriteComponent {
		
		protected var _proxy : DataProxy;
		public function set proxy(m : DataProxy) : void {
			_proxy = m;
		}
		public function get proxy() : DataProxy {
			return _proxy;
		}
		
		private var _data : *;
		public function get data() : * {
			return _data;
		}
		public function set data(data : *) : void {
			_data = data;
		}

		public function ComponentWithDataProxy( ) {
			super();
		}


		
	}
}
