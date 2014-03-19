package com.rockdot.project.command {
	import com.jvm.utils.DateUtils;
	import com.jvm.utils.DeviceDetector;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.CompositeCommandWithEvent;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.io.command.event.IOEvents;
	import com.rockdot.plugin.io.command.event.vo.IOImageUploadVO;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.plugin.ugc.command.event.UGCEvents;
	import com.rockdot.plugin.ugc.inject.IUGCModelAware;
	import com.rockdot.plugin.ugc.model.UGCModel;
	import com.rockdot.plugin.ugc.model.vo.UGCImageItemVO;
	import com.rockdot.plugin.ugc.model.vo.UGCItemVO;

	import org.as3commons.async.command.CompositeCommandKind;





	public class UploadImageCommand extends AbstractCommand implements IUGCModelAware{
		private static const UPLOAD_WIDTH_MAX : Number = 720;
		private static const UPLOAD_HEIGHT_MAX : Number = 720;
		private static const UPLOAD_WIDTH_THUMB : Number = 120;
		private static const UPLOAD_HEIGHT_THUMB : Number = 120;
		

		protected var _ugcModel : UGCModel;
		public function set ugcModel(ugcModel : UGCModel) : void {
			_ugcModel = ugcModel;
		}

		override public function execute(event : RockdotEvent = null) : * {
			
			super.execute(event);
			
			//filenames
			var filenameBig : String = DateUtils.getTimeInMilliseconds(new Date()) + "_" + _ugcModel.userExtendedDAO.hash + ".jpg";
			var filenameThumb : String = DateUtils.getTimeInMilliseconds(new Date()) + "_" + _ugcModel.userExtendedDAO.hash + "_thumb.jpg";
		
			// Database VO
			var itemVO : UGCItemVO = new UGCItemVO();
			itemVO.type = UGCItemVO.TYPE_IMAGE;
			itemVO.title = String(_appModel.iamtype);
			itemVO.description = _appModel.iamline;
			itemVO.creator_uid = _ugcModel.userDAO.uid;
			
			
			var dao : UGCImageItemVO= new UGCImageItemVO();
			dao.url_big = getProperty("project.host.download") + "/" + filenameBig;
			dao.url_thumb = getProperty("project.host.download") + "/" + filenameThumb;
			dao.w = _appModel.image.width;
			dao.h = _appModel.image.height;
			itemVO.type_dao = dao;
		
			//Upload VOs
			var voBig : IOImageUploadVO = new IOImageUploadVO(_appModel.image, filenameBig, RockdotConstants.UPLOAD_WIDTH_MAX, RockdotConstants.UPLOAD_HEIGHT_MAX);
			var voThumb : IOImageUploadVO = new IOImageUploadVO(_appModel.image, filenameThumb, RockdotConstants.UPLOAD_WIDTH_THUMB, RockdotConstants.UPLOAD_HEIGHT_THUMB);
			
			//command chain
			var compositeCommand : CompositeCommandWithEvent = new CompositeCommandWithEvent(CompositeCommandKind.SEQUENCE);
			compositeCommand.addCommandEvent(new RockdotEvent(StateEvents.ADDRESS_SET, "/layer/loading"), _context);
			
			
			if(DeviceDetector.IS_MOBILE){
				//on mobile, save memory by uploading sequentially
				compositeCommand.addCommandEvent(new RockdotEvent(IOEvents.IMAGE_UPLOAD, [voBig]), _context);
				compositeCommand.addCommandEvent(new RockdotEvent(IOEvents.IMAGE_UPLOAD, [voThumb]), _context);
			}
			else{
				//in flash player, uploading sequentially could cause a security exception in some environments. this, upload all the things AT ONCE
				compositeCommand.addCommandEvent(new RockdotEvent(IOEvents.IMAGE_UPLOAD, [voBig, voThumb]), _context);
			}
			
			compositeCommand.addCommandEvent(new RockdotEvent(UGCEvents.CREATE_ITEM, itemVO), _context);
			compositeCommand.addCommandEvent(new RockdotEvent(IOEvents.MEMORY_CLEAR), _context);
			
			//we don't need to go back from loading layer, as there will be a redirect after login, anyways
//			compositeCommand.addCommandEvent(new RockdotEvent(StateEvents.STATE_VO_BACK), _context);
			
			compositeCommand.failOnFault = true;
			compositeCommand.addCompleteListener(dispatchCompleteEvent);
			compositeCommand.addErrorListener(_handleError);
			compositeCommand.execute();
			return null;
		}

		
		override public function dispatchCompleteEvent(result : * = null) : Boolean {
			
			_appModel.image.bitmapData.dispose();
			_appModel.image = null;
			
			return super.dispatchCompleteEvent(result);
		}
		
	}
}