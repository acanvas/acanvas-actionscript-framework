package com.rockdot.library.view.component.common.form.calendar {
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;


	/**
	 * Copyright (c) 2012, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author danielhuebschmann
	 * @since 16.01.2012 18:10:16
	 */
	public class Calendar extends SpriteComponent {
		
		protected var _firstDay : Number = 1; //1=Sunday, 0=Monday
		protected var _monthNames : Array = ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"];
		protected var _dayButtons : Array = [];
		protected var _dayButtonGap : int = 1;
		protected var _dayButtonWidth : int = 30;
		protected var _dayButtonHeight : int = 30;
		protected var _dateLabel : UITextField;
		protected var _dayButtonHolder : Sprite;

		private var _month : Number;
		private var _year : Number;
		private var _day : Number;
		
		public function Calendar() {
			super();
			
			_dayButtonHolder = new Sprite();
			_dayButtonHolder.x = 0;
			_dayButtonHolder.y = 21;
			addChild(_dayButtonHolder);
			
			addItems();
			setDate(new Date());
		}
		
		/**
		 * Override this method for new ui.
		 * All day-Buttons should be pushed into the _dayButtons-Array (user your own buttons if needed)
		 * Create and position all other buttons you need, for example prevMonth, nextMonth, prevYear, nextYear and use appropriate functions
		 * Use _dateLabel to show active month and year, for example "Januar 2012"
		 * 
		 */
		protected function addItems() : void {
			for(var i:int = 0; i < 6; i++)
			{
				for(var j:int = 0; j < 7; j++)
				{
					var btn : DayButton = new DayButton(j.toString(), _dayButtonWidth, _dayButtonHeight);
					btn.addEventListener(MouseEvent.CLICK, _onDayButtonClick, false, 0, true);
					btn.x = j * (_dayButtonWidth + _dayButtonGap);
					btn.y = i * (_dayButtonHeight + _dayButtonGap);
					_dayButtonHolder.addChild(btn);
					_dayButtons.push(btn);
				}
			}
			
			var prevYearButton : NextPrevButton = new NextPrevButton("«", 20, 20);
			prevYearButton.x = 0;
			prevYearButton.y = 0;
			prevYearButton.addEventListener(MouseEvent.CLICK, _onPrevYearButtonClick, false, 0, true);
			addChild(prevYearButton);
			
			var nextYearButton : NextPrevButton = new NextPrevButton("»", 20, 20);
			nextYearButton.x = Math.floor( _dayButtonHolder.x + _dayButtonHolder.width - nextYearButton.width);
			nextYearButton.y = 0;
			nextYearButton.addEventListener(MouseEvent.CLICK, _onNextYearButtonClick, false, 0, true);
			addChild(nextYearButton);
			
			var prevMonthButton : NextPrevButton = new NextPrevButton("<", 20, 20);
			prevMonthButton.x = Math.floor( prevYearButton.x + prevYearButton.width ) + 1;
			prevMonthButton.y = 0;
			prevMonthButton.addEventListener(MouseEvent.CLICK, _onPrevMonthButtonClick, false, 0, true);
			addChild(prevMonthButton);
			
			var nextMonthButton : NextPrevButton = new NextPrevButton(">", 20, 20);
			nextMonthButton.x = Math.floor( nextYearButton.x - nextMonthButton.width ) - 1;
			nextMonthButton.y = 0;
			nextMonthButton.addEventListener(MouseEvent.CLICK, _onNextMonthButtonClick, false, 0, true);
			addChild(nextMonthButton);
			
			var fm : TextFormat = new TextFormat("Arial", 12, 0x0, true);
			fm.align = TextFormatAlign.CENTER;
			_dateLabel = new UITextField("22", fm, 131);
			_dateLabel.embedFonts = false;
			_dateLabel.wordWrap = true;
			_dateLabel.multiline = false;
			_dateLabel.autoSize = TextFieldAutoSize.CENTER;
			_dateLabel.x = Math.floor( prevMonthButton.x + prevMonthButton.width + 1);
			addChild(_dateLabel);
		}
		
		protected function getLastDayOfMonth(month : Number, year : Number) : int {
			switch(month)
			{
				case 0:		// jan
				case 2:		// mar
				case 4:		// may
				case 6:		// july
				case 7:		// aug
				case 9:		// oct
				case 11:	// dec
					return 31;
				case 1:		// feb
					if((year % 400 == 0) ||  ((year % 100 != 0) && (year % 4 == 0))) return 29;
					return 28;
				default:	
					break;
			}
			// april, june, sept, nov.
			return 30;
		}
		
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		public function setDate(date : Date) : void {
			_year = date.fullYear;
			_month = date.month;
			_day = date.date;
			
			var firstDay : int = new Date(_year, _month, _firstDay).day;
			var lastDay : int = getLastDayOfMonth(_month, _year);
			
			for (var i : int = 0; i < 42; i++) {
				_dayButtons[i].visible = false;
			}
			
			for (var j : int = 0; j < lastDay; j++) {
				var btn : DayButton = _dayButtons[j + firstDay];
				btn.visible = true;
				btn.label = (j + 1).toString();
				btn.tag = j + 1;
			}
			
			if(_dateLabel) _dateLabel.text = _monthNames[_month] + " " + _year;
		}
		
		public function setYearMonthDay(year:int, month:int, day:int):void
		{
			setDate(new Date(year, month, day));
		}
		
		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////

		protected function _onPrevYearButtonClick(event : MouseEvent) : void {
			_year--;
			_day = Math.min(_day, getLastDayOfMonth(_month, _year));
			setYearMonthDay(_year, _month, _day);
			
		}
		
		protected function _onPrevMonthButtonClick(event : MouseEvent) : void {
			_month--;
			if(_month < 0)
			{
				_month = 11;
				_year--;
			}
			_day = Math.min(_day, getLastDayOfMonth(_month,_year));
			setYearMonthDay(_year, _month, _day);
		}

		protected function _onNextMonthButtonClick(event : MouseEvent) : void {
			_month++;
			if(_month > 11)
			{
				_month = 0;
				_year++;
			}
			_day = Math.min(_day, getLastDayOfMonth(_month, _year));
			setYearMonthDay(_year, _month, _day);
		}
		
		protected function _onNextYearButtonClick(event : MouseEvent) : void {
			_year++;
			_day = Math.min(_day, getLastDayOfMonth(_month, _year));
			setYearMonthDay(_year, _month, _day);
		}
		
		protected function _onDayButtonClick(event : MouseEvent) : void {
			_day = event.target.tag;
			setYearMonthDay(_year, _month, _day);
		}
		
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		public function get selectedDate():Date
		{
			return new Date(_year, _month, _day);
		}

		public function get month() : int {
			return _month;
		}
		
		public function get year() : int {
			return _year;
		}
		
		public function get day():int
		{
			return _day;
		}
	}
}
