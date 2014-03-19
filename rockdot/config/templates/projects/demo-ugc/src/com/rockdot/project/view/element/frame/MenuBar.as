package com.rockdot.project.view.element.frame {
	import com.rockdot.bootstrap.BootstrapConstants;
	/**
	 * @author nilsdoehring
	 */
	public class MenuBar extends AbstractMenuBar {
		public function MenuBar(id : String) {
			name = id;
			super();
			
			_createMenuItem("home");
			_createMenuItem("gallery");
			_createMenuItem("upload");
			if(BootstrapConstants.COMPETITION_ACTIVE == true){
				_createMenuItem("prizes");
			}
			

		}
	}
}
