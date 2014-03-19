package com.rockdot.core.mvc {
	import org.as3commons.async.command.ICommand;
	/**
	 * @author nilsdoehring
	 */
	public class CommandVO {
		public var command : ICommand;
		public var event : RockdotEvent;

		public function CommandVO(command:ICommand, event: RockdotEvent) {
			
			this.event = event;
			this.command = command;
		}
	}
}
