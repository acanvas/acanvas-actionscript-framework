package com.rockdot.project.view.element.dropdown {
	import com.jvm.components.Orientation;
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.library.view.component.common.form.ComponentDropdown;
	import com.rockdot.library.view.component.common.form.ComponentList;
	import com.rockdot.library.view.component.common.scrollable.DefaultScrollbar;
	import com.rockdot.project.view.element.button.YellowButton;
	import com.rockdot.project.view.element.list.cell.LabelListCell;

	import flash.system.Capabilities;
	import flash.system.TouchscreenType;


	/**
	 * @author nilsdoehring
	 */
	public class FilterGalleryDropdown extends ComponentDropdown {
		private static const NUM_OPTIONS : Number = 11;
		
		private var _aOptions : Array;
		public function FilterGalleryDropdown() {
			name = "element.dropdown.filter";
			RockdotHelper.wire(this);
			
			_aOptions = [];
			for (var i : int = 0; i < NUM_OPTIONS; i++) {
				_aOptions.push(getProperty("option" + (i+1)));
			}
			
			_cmpListFlyout = new ComponentList( Orientation.VERTICAL, LabelListCell, DefaultScrollbar, true);
			_cmpListFlyout.touchEnabled = true;
			_cmpListFlyout.doubleClickEnabled = false;
			_cmpListFlyout.keyboardEnabled = false;
			_cmpListFlyout.doubleClickToZoom = false;
			if(Capabilities.touchscreenType == TouchscreenType.NONE){
				_cmpListFlyout.mouseWheelEnabled = true;
			}else{
				_cmpListFlyout.bounce = true;//bounce if touchscreen
			}
			_cmpListFlyout.setData(_aOptions);
			
			_btnRolloutToggle = new YellowButton(getProperty("button.open"), 0, 30, 12);
				
			super();
			
		}

		
	}
}
