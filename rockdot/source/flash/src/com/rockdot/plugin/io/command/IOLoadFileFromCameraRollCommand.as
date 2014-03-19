package com.rockdot.plugin.io.command {
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.command.event.IOEvents;
	import com.rockdot.plugin.state.command.event.StateEvents;

	import org.as3commons.lang.Assert;

	import flash.display.Bitmap;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.MediaEvent;
	import flash.media.CameraRoll;
	import flash.media.CameraRollBrowseOptions;
	import flash.media.MediaPromise;






	public class IOLoadFileFromCameraRollCommand extends AbstractIOCommand {
		private var _roll : CameraRoll;

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			if(CameraRoll.supportsBrowseForImage){
				var crOpts:CameraRollBrowseOptions = new CameraRollBrowseOptions();
				crOpts.height = RockdotConstants.HEIGHT_STAGE_REAL / 2;
				crOpts.width = RockdotConstants.WIDTH_STAGE_REAL / 2;
//				crOpts.origin = new Rectangle(e.target.x, e.target.y, e.target.width, e.target.height);
					
				_roll = new CameraRoll();
				_roll.addEventListener(MediaEvent.SELECT, _onCameraRollSelect);
				_roll.addEventListener(Event.CANCEL, _onCameraRollCancel);
				_roll.addEventListener(ErrorEvent.ERROR, _onCameraRollError);

				_roll.browseForImage(crOpts);
			}
		}

		private function _onCameraRollSelect(e : MediaEvent) : void {
			var promise : MediaPromise = e.data as MediaPromise;
			new RockdotEvent(IOEvents.LOAD_MEDIAPROMISE, promise, _onPromiseLoaded).dispatch();
		}
		
		private function _onCameraRollCancel(event : Event = null) : void {
			new RockdotEvent(StateEvents.STATE_VO_BACK).dispatch();
		}

		private function _onCameraRollError(event : ErrorEvent) : void {
			log.debug("error " + event.text);
			dispatchErrorEvent(event.text);
			_onCameraRollCancel();
		}

		private function _onPromiseLoaded(image : Bitmap) : void {
			Assert.notNull(image, "Loaded image is null.");		
			
			if(_ioModel.importedFile){
				_ioModel.importedFile.bitmapData.dispose();
				_ioModel.importedFile = null;
				log.debug("I found a Bitmap already present in _ioModel.importedFile, so I deleted it. For science. And memory.");
			}
			_ioModel.importedFile = image;
			dispatchCompleteEvent(image);
		}		
	}
}