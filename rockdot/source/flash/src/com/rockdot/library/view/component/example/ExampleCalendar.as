package com.rockdot.library.view.component.example {
	import com.rockdot.library.view.component.common.form.calendar.Calendar;
	import com.rockdot.library.view.component.common.form.calendar.DayButton;

	import flash.events.MouseEvent;

	/**
	 * Copyright (c) 2012, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 17.01.2012 15:40:19
	 */
	public class ExampleCalendar extends Calendar {

		public function ExampleCalendar() {
			super();
			
			// Some examples for customizing, see superclass
			_dayButtonGap = 10;
			_dayButtonWidth = 60;
			_dayButtonHeight = 60;
			_monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		}
		
		override protected function addItems() : void {
			for(var i:int = 0; i < 6; i++)
			{
				for(var j:int = 0; j < 7; j++)
				{
					// User your own Buttons if needed, extend from DayButton
					var btn : DayButton = new DayButton(j.toString(), _dayButtonWidth, _dayButtonHeight);
					btn.addEventListener(MouseEvent.CLICK, _onDayButtonClick, false, 0, true);
					btn.x = j * (_dayButtonWidth + _dayButtonGap);
					btn.y = i * (_dayButtonHeight + _dayButtonGap);
					_dayButtonHolder.addChild(btn);
					_dayButtons.push(btn);
				}
			}
		}
	}
}
