package com.rockdot.plugin.ugc.command {
	import com.rockdot.core.mvc.RockdotEvent;






	public class UGCMailSendCommand extends AbstractUGCCommand {

		override public function execute(event : RockdotEvent = null) : * {
			super.execute(event);
			var sender : String = getProperty("email.confirm.sender").split("$sender").join(getProperty("project.host.email.sender"));
			var body : String = getProperty("email.confirm.body").split("$name").join(_ugcModel.userDAO.name);
			if(_ugcModel.userExtendedDAO.firstname && _ugcModel.userExtendedDAO.lastname){
				body = getProperty("email.confirm.body").split("$name").join(_ugcModel.userExtendedDAO.firstname + " " + _ugcModel.userExtendedDAO.lastname);
			}
			body = body.split("$link").join(getProperty("project.host.email.confirm") + "?e="+_ugcModel.userExtendedDAO.email + "&h=" + _ugcModel.userExtendedDAO.hash);
			
			amfOperation("UGCEndpoint.sendMail", {subject: getProperty("email.confirm.subject"), sender:sender, body:body, hash:_ugcModel.userExtendedDAO.hash, email:_ugcModel.userExtendedDAO.email});
		}
	} 
}