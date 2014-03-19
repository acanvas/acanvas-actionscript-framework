package com.rockdot.project.view.layer {
	import fl.controls.CheckBox;

	import com.rockdot.bootstrap.BootstrapConstants;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.textfield.UITextField;
	import com.rockdot.plugin.facebook.inject.IFBModelAware;
	import com.rockdot.plugin.facebook.model.FBModel;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.ugc.inject.IUGCModelAware;
	import com.rockdot.plugin.ugc.model.UGCModel;
	import com.rockdot.project.command.event.ProjectEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.button.YellowButton;
	import com.rockdot.project.view.text.Copy;
	import com.rockdot.project.view.text.Headline;

	import flash.display.Shape;





	public class PreSubmit extends AbstractLayer implements IUGCModelAware, IFBModelAware{
		private var _name : UITextField;
		private var _nameField : UITextField;
		private var _email : UITextField;
		private var _cbData : CheckBox;
		private var _cbDataLabel : UITextField;
		private var _emailField : UITextField;
		private var _buttonOK : YellowButton;
		private var _line : Shape;
		private var _disclaimer : UITextField;
		
		protected var _ugcModel : UGCModel;
		public function set ugcModel(ugcModel : UGCModel) : void {
			_ugcModel = ugcModel;
		}

		protected var _fbModel : FBModel;
		public function set fbModel(fbModel : FBModel) : void {
			_fbModel = fbModel;
		}

		public function PreSubmit(id : String) {
			super(id);
		}

		override public function init(data : * = null) : void 
		{
			super.init(data);


			// name + name field + name button

			_name = new Headline(getProperty("name"), 18, Colors.GREY_DARK);
			addChild(_name);

			_nameField = new Copy(_ugcModel.userDAO.name, 18, Colors.GREY);
			addChild(_nameField);

			// email

			_email = new Headline(getProperty("email"), 18, Colors.GREY_DARK);
			addChild(_email);


			if(RockdotConstants.LOCAL){
				_emailField = new Copy("fake.user@fake.de", 18, Colors.GREY);
			}
			else{
				_emailField = new Copy(_fbModel.user.email, 18, Colors.GREY);
			}
			addChild(_emailField);


			// line
			_line = new Shape();
			_line.graphics.lineStyle(1, Colors.GREY_MIDDLE, 1, false, "none");
			_line.graphics.moveTo(20, 0);
			_line.graphics.lineTo(_width - 20, 0);
			if ( _cbData ) _line.y = Math.floor(_cbDataLabel.y + _cbDataLabel.textHeight) + 75;
			addChild(_line);

			// disclaimer
			_disclaimer = new Copy(getProperty("disclaimer"), 12, Colors.GREY);
			addChild(_disclaimer);

			
			_buttonOK = new YellowButton(getProperty("button.ok"),  _width);
			_buttonOK.submitCallback = _checkData;
			addChild(_buttonOK);
			
			_didInit();
		}
		
		
		override public function render() : void {
			
			//text
			_headline.x = BootstrapConstants.SPACER;
			_headline.y = _headlineY;
			_headline.width = _width - 2*BootstrapConstants.SPACER;
			
			_name.width = _width - 40;
			_name.x = 20;
			_name.y = _headlineY + _headline.textHeight + BootstrapConstants.SPACER;
			
			_nameField.width = _width - 40;
			_nameField.x = 20;
			_nameField.y = _name.y + _name.textHeight + BootstrapConstants.SPACER;
			
			_email.width = _width - 40;
			_email.x = 20;
			_email.y = _nameField.y + _nameField.textHeight + BootstrapConstants.SPACER;
			
			_emailField.width = _width - 40;
			_emailField.x = 20;
			_emailField.y = _email.y + _email.textHeight + BootstrapConstants.SPACER;

			_line.y = Math.floor(_emailField.y + _emailField.textHeight + BootstrapConstants.SPACER);

			_disclaimer.width = _width - 40;
			_disclaimer.x = 20;
			_disclaimer.y = _line.y + BootstrapConstants.SPACER;
			
			_buttonOK.setWidth(_width);	
			_buttonOK.y = _disclaimer.y + _disclaimer.textHeight + BootstrapConstants.SPACER;
			
			super.render();
			
		}

		private function _checkData() : void
		{
			var error : Boolean = false;

			if ( !error ) {
				new RockdotEvent(ProjectEvents.IMAGE_UPLOAD, null, _onUploadComplete).dispatch();
			}
		}

		private function _onUploadComplete(result:*=null) : void {
			new RockdotEvent(StateEvents.ADDRESS_SET, "/layer/submitsuccess").dispatch();
		}


		

	}
}
