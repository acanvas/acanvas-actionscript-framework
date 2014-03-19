package com.rockdot.project.view.element.frame {

	/**
	 * @author nilsdoehring
	 */
	public class Footer extends AbstractMenuBar {
		public function Footer() {
			super();
			name = "element.footer";
			
			_createMenuItem("imprint", 14);
			_createMenuItem("terms", 14);
			_createMenuItem("privacy", 14);

		}

		
		
		override public function render() : void {
			super.render();
			
		}
	}
}
