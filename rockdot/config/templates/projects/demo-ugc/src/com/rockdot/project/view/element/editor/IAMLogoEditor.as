package com.rockdot.project.view.element.editor {
	import com.greensock.TweenLite;
	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.library.view.component.common.form.ComponentDropdown;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.project.model.Assets;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.shared.IAMLogo;

	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;


	public class IAMLogoEditor extends RockdotSpriteComponent
	{
		
		public static const DRAG_START : String = "DRAG_START";
		public static const DRAG_STOP: String = "DRAG_STOP";
		private static var SCALE_NORMAL : Number = 1.0;
		private static var SCALE_SMALL : Number = .7;
		private var _scale : Number = 1;
		
		//I AM claim
		private static var IAM_HEIGHT : Number = 43;
		private var _cmpIAMLine : IAMLogo;
		private var _iIAMLineID : int = -1;
		
		//I AM line rollout
		private var _cmpRollout : IAMLogoEditorRollout;
		
		//holder for claim + dropdown + dragbuttons
		private var _numHolderCenterY : Number;
		private var _numHolderY : Number;
		private var _sprHolder : Sprite;
		
		//limits of claim's placement
		private var _numIAMLineBorderTop : Number;
		private var _numIAMLineBorderBottom : Number;
		
		//placement limit markers
		private var _shaBorderLinesMask : Shape;
		private var _sprBorderLines : Sprite;
		private var _bmpBorderLinesBottom : Bitmap;
		
		
		//I AM line placement arrows
		private var _btnDragUp : IAMLogoEditorDragButton;
		private var _btnDragDown : IAMLogoEditorDragButton;
		private var _sprDragButtonHolder : Sprite;
		
		/**
		 * Holds the I AM line + dropdown and drag buttons
		 */
		public function IAMLogoEditor(id:String)
		{
			super();
			name = id;

			_sprHolder = new Sprite();
			addChild(_sprHolder);

			// Yellow lines = border for quote position
			var linesTop : Bitmap = Assets.quote_editor_lines;
			_bmpBorderLinesBottom = Assets.quote_editor_lines;

			_shaBorderLinesMask = new Shape();
			addChild(_shaBorderLinesMask);
			
			_sprBorderLines = new Sprite();
			_sprBorderLines.addChild(linesTop);
			_sprBorderLines.addChild(_bmpBorderLinesBottom);
			_sprBorderLines.visible = false;
			_sprBorderLines.alpha = 0;
			addChild(_sprBorderLines);

			_sprBorderLines.mask = _shaBorderLinesMask;
			
			_numIAMLineBorderTop		= linesTop.height;
			_numIAMLineBorderBottom	= _height - 2 * _numIAMLineBorderTop;

			_cmpIAMLine = new IAMLogo(getProperty("copy.choose"));
			_cmpIAMLine.submitCallback = _updateCenterX;
			_sprHolder.addChild(_cmpIAMLine);

			// arrows up and down
			_btnDragUp = new IAMLogoEditorDragButton();
			_btnDragUp.y = IAM_HEIGHT;
		
			_btnDragDown = new IAMLogoEditorDragButton();
			_btnDragDown.scaleY = -1;
			_btnDragDown.y = 0;
		
			_sprDragButtonHolder = new Sprite();
			_sprDragButtonHolder.name = "moveArrows";
			_sprDragButtonHolder.addChild(_btnDragUp);
			_sprDragButtonHolder.addChild(_btnDragDown);
			_sprHolder.addChild(_sprDragButtonHolder);

			//rollout button and rollout
			_cmpRollout = new IAMLogoEditorRollout(name + ".rollout");
			_cmpRollout.submitCallback = _onRolloutChange;
			_cmpRollout.onToggleCallback = _onRolloutToggle;
			_sprHolder.addChild(_cmpRollout);
			
			// update position
			_updateCenterX();
			_updateCenterY();
			_numHolderY = _numHolderCenterY;
		}
		
		override public function render() : void
		{
			super.render();
			_scale = 1;
			if ( _width < 600 ) {
				_scale = SCALE_SMALL;
			} else {
				_scale = SCALE_NORMAL;
			}
			
			scaleX = scaleY = _scale;
			_width /= _scale;
			_height /= _scale;
			
			// Yellow lines = border for quote position
			_shaBorderLinesMask.graphics.clear();
			_shaBorderLinesMask.graphics.beginFill(Colors.BLACK);
			_shaBorderLinesMask.graphics.drawRoundRect(0, 0, _width, _height, 8, 8);
			_sprBorderLines.width = _width;

			_bmpBorderLinesBottom.y = _height - _bmpBorderLinesBottom.height + 1;
			_numIAMLineBorderBottom = ( _bmpBorderLinesBottom.y - IAM_HEIGHT  );

			_cmpRollout.setHeight(45);
			_cmpRollout.closeRollout();

			// update position
			_updateCenterX();
			_updateCenterY();
			_numHolderY = _numHolderCenterY;
		}

		/**
		 * Callback for Rollout Button Click and Rollout Entry Click
		 */
		private function _onRolloutToggle(text : String) : void {
			switch(text){
				case ComponentDropdown.ROLLOUT_CLOSE:
					_btnDragDown.visible = true;
					_btnDragUp.visible = true;
					_submitCallback.call(null, text);
					TweenLite.to(_sprHolder, .5, {y:_numHolderY});
				break;
				case ComponentDropdown.ROLLOUT_OPEN:
					_btnDragDown.visible = false;
					_btnDragUp.visible = false;
					_submitCallback.call(null, text);
					TweenLite.to(_sprHolder, .5, {y:_numHolderCenterY - (_cmpRollout.height * _scale) / 2});
	
					if ( _cmpIAMLine.width < _cmpRollout.width - BootstrapConstants.HEIGHT_RASTER) {
						_cmpIAMLine.setWidth(_cmpRollout.width - BootstrapConstants.HEIGHT_RASTER);
						_cmpRollout.x = 5 + _cmpIAMLine.width - 1;
					}
				break;
			}

			_updateCenterX();
		}	

		private function _onRolloutChange(id : int, text : String, editable : Boolean = false) : void {
			switch(text){
				default:
					if(editable == true){
						_cmpIAMLine.enableWriteMode();
					}
					else{
						_cmpIAMLine.setText(text);
					}
					_iIAMLineID = (id > 2 && id < 6) ? id + 2 : ((id == 6) ? 4 : id);
				break;
			}

			_updateCenterX();
		}	
			
		override public function set enabled(value : Boolean) : void {
			super.enabled = value;
			if(value){
				_sprDragButtonHolder.addEventListener(MouseEvent.MOUSE_DOWN, _onDragStart);
			}
			else{
				_sprDragButtonHolder.removeEventListener(MouseEvent.MOUSE_DOWN, _onDragStart);
			}
		}
		

		/***********************************************************************
		 * UPDATE-/CHANGE-Functions
		 ***********************************************************************/

		private function _updateCenterX() : void
		{
			_sprDragButtonHolder.x = _cmpIAMLine.width / 2 - 25;
			_sprHolder.x = _width/2 - _cmpIAMLine.width / 2 + 3 ;
			_log.debug("width: {0}, iam width: {1}, x:{2}", [_width, _cmpIAMLine.width, _sprHolder.x]);
			_cmpRollout.x = _cmpIAMLine.x + _cmpIAMLine.width;
		}

		private function _updateCenterY() : void
		{
			_numHolderCenterY = ( _height - (_cmpIAMLine.height * _scale) ) / 2 + 60;
			_sprHolder.y = _numHolderCenterY;
		}

		private function _onDragStart(event : MouseEvent) : void {

			_btnDragUp.dragging = true;
			_btnDragDown.dragging = true;
			
			_submitCallback.call(null, DRAG_START);

			TweenLite.to(_sprBorderLines, 0.3, {autoAlpha:1});
			
			stage.addEventListener(Event.ENTER_FRAME, _onDragEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onDragStop);
		}

		private function _onDragEnterFrame(event : Event) : void {
			var top : Number = _numIAMLineBorderTop;
			var btm : Number = ( _bmpBorderLinesBottom.y - IAM_HEIGHT  );
			
			_sprHolder.y = mouseY;
			if(_sprHolder.y < top){
				_sprHolder.y = top;
			}
			else if(_sprHolder.y > btm){
				_sprHolder.y = btm;
			}
		}

		private function _onDragStop(event : MouseEvent) : void
		{
			stage.removeEventListener(Event.ENTER_FRAME, _onDragEnterFrame);

			_btnDragUp.dragging = false;
			_btnDragDown.dragging = false;
			_btnDragUp.doOut();
			_btnDragDown.doOut();

			_numHolderY = _sprHolder.y;
			
			_submitCallback.call(null, DRAG_STOP);

			TweenLite.to(_sprBorderLines, 0.3, {autoAlpha:0});

			stage.removeEventListener(MouseEvent.MOUSE_UP, _onDragStop);
		}

		/***********************************************************************
		 * EXTERNAL CALLS
		 ***********************************************************************/

		public function getQuoteType() : int
		{
			return _iIAMLineID;
		}

		public function minimize() : void
		{
			_cmpRollout.closeRollout();
			TweenLite.to(_sprHolder, 0.2, {autoAlpha:0, y:_numHolderCenterY});
		}

		public function maximize(imageType : String) : void
		{
			TweenLite.to(_sprHolder, 0.5, {autoAlpha:1});

			showArrows();

			if ( imageType == "portrait" ) {
				_scale = SCALE_SMALL;
			} else {
				_scale = 1;
			}

			// FULL RESET:
			
			_cmpRollout.x = _cmpIAMLine.width - 1;
			_sprHolder.scaleX = _sprHolder.scaleY = _scale;

			_updateCenterX();
			_updateCenterY();
			
			_cmpRollout.x = _cmpIAMLine.width - 1;
			_sprDragButtonHolder.x =  _cmpIAMLine.width  / 2 - _sprDragButtonHolder.width / 2;
		}

		/*
		 * ARROWS SHOW / HIDE (NEEDED FOR BITMAP SCREENIE)
		 */
		public function hideArrows() : void
		{
			if ( _cmpRollout ) _cmpRollout.visible = false;
			if ( _btnDragUp ) _btnDragUp.visible = false;
			if ( _btnDragDown ) _btnDragDown.visible = false;
		}

		public function showArrows() : void
		{
			if ( _cmpRollout ) _cmpRollout.visible = true;
			if ( _btnDragUp ) _btnDragUp.visible = true;
			if ( _btnDragDown ) _btnDragDown.visible = true;
		}


		// used for badword check
		public function get iamInputText() : String {
			return String(_cmpIAMLine.getText());
		}
	}
}
