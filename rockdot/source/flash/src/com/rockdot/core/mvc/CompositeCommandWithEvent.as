/*
 * Copyright 2007-2010 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.rockdot.core.mvc {
	import org.as3commons.async.command.CompositeCommandKind;
	import org.as3commons.async.command.ICommand;
	import org.as3commons.async.command.ICompositeCommand;
	import org.as3commons.async.command.event.CommandEvent;
	import org.as3commons.async.command.event.CompositeCommandEvent;
	import org.as3commons.async.command.impl.CompositeCommand;
	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.async.operation.impl.AbstractProgressOperation;
	import org.as3commons.lang.Assert;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;

	import flash.errors.IllegalOperationError;
	import flash.utils.getTimer;

	/**
	 * Basic implementation of the <code>ICompositeCommand</code> that executes a list of <code>ICommand</code> instances
	 * that were added through the <code>addCommand()</code> method. The commands are executed in the order in which
	 * they were added.
	 * @author Christophe Herreman
	 * @author Roland Zwaga
	 * @docref the_operation_api.html#composite_commands
	 */
	public class CompositeCommandWithEvent extends AbstractProgressOperation implements ICompositeCommand {

		private static const LOGGER:ILogger = getLogger(CompositeCommand);

		/**
		 * Determines if the execution of all the <code>ICommands</code> should be aborted if an
		 * <code>IAsyncCommand</code> instance dispatches an <code>AsyncCommandFaultEvent</code> event.
		 * @default false
		 * @see org.springextensions.actionscript.core.command.IAsyncCommand IAsyncCommand
		 */
		public var failOnFault:Boolean = false;

		private var _commands : Array = [];
		private var _timer : int;

		public function get commands():Array {
			return _commands;
		}

		protected function setCommands(value:Array):void {
			_commands = value;
		}

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>CompositeCommand</code> instance.
		 * @default CompositeCommandKind.SEQUENCE
		 */
		public function CompositeCommandWithEvent(kind : CompositeCommandKind = null) {
			super();
			_kind = (kind != null) ? kind : CompositeCommandKind.SEQUENCE;
		}

		// --------------------------------------------------------------------
		//
		// Properties
		//
		// --------------------------------------------------------------------

		private var _kind:CompositeCommandKind;

		public function get kind():CompositeCommandKind {
			return _kind;
		}

		public function set kind(value:CompositeCommandKind):void {
			_kind = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get numCommands():uint {
			return _commands.length;
		}

		private var _currentCommandVO:CommandVO;

		/**
		 * The <code>ICommand</code> that is currently being executed.
		 */
		public function get currentCommandVO():CommandVO {
			return _currentCommandVO;
		}

		// --------------------------------------------------------------------
		//
		// Implementation: ICommand
		//
		// --------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function execute(event : RockdotEvent = null):* {
			if (_commands) {
				switch (_kind) {
					case CompositeCommandKind.SEQUENCE:
						LOGGER.debug("Executing composite command '{0}' in sequence", [this]);
						executeNextCommand();
						break;
					case CompositeCommandKind.PARALLEL:
						LOGGER.debug("Executing composite command '{0}' in parallel", [this]);
						executeCommandsInParallel();
						break;
					default:
						break;
				}
			} else {
				LOGGER.debug("No commands were added to this composite command. Dispatching complete event.");
				dispatchCompleteEvent();
			}
		}

		public function cancel() : void {
			_commands = [];
		}


		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function addCommandEvent(event:RockdotEvent, objectFactory:IObjectFactory):ICompositeCommand {
			Assert.notNull(event, "The event argument must not be null");
			Assert.notNull(objectFactory, "The objectFactory argument must not be null");
			_commands[_commands.length] = new CommandVO(objectFactory.getObject(event.type), event);
			total++;
			return this;
		}

		public function addOperation(operationClass:Class, ... constructorArgs):ICompositeCommand {
			Assert.notNull(operationClass, "The operationClass argument must not be null");
			throw new IllegalOperationError("method not allowed in this implementation");
			//addCommand(GenericOperationCommand.createNew(operationClass, constructorArgs));
			//return null;
		}

		// --------------------------------------------------------------------
		//
		// Protected Methods
		//
		// --------------------------------------------------------------------

		/**
		 * If the specified <code>ICommand</code> implements the <code>IAsyncCommand</code> interface the <code>onCommandResult</code>
		 * and <code>onCommandFault</code> event handlers are added. Before the <code>ICommand.execute()</code> method is invoked
		 * the <code>CompositeCommandEvent.EXECUTE_COMMAND</code> event is dispatched.
		 * <p>When the <code>command</code> argument is <code>null</code> the <code>CompositeCommandEvent.COMPLETE</code> event is dispatched instead.</p>
		 * @see org.springextensions.actionscript.core.command.event.CommandEvent CompositeCommandEvent
		 */
		protected function executeCommand(commandVO:CommandVO):void {
			Assert.notNull(commandVO, "The 'command' must not be null");

			LOGGER.debug("Executing command: " + commandVO.command);

			_currentCommandVO = commandVO;

			// listen for "result" or "fault" if we have an async command
			addCommandListeners(commandVO.command as IOperation);

			// execute the command
			//TODO why this event?
			dispatchEvent(new CommandEvent(CommandEvent.EXECUTE, commandVO.command));
			dispatchBeforeCommandEvent(commandVO.command);
			commandVO.command.execute(commandVO.event);
			if (!(commandVO.command is IOperation)) {
				dispatchAfterCommandEvent(commandVO.command);
			}

			// execute the next command if the executed command was synchronous
			if (commandVO.command is IOperation) {
				LOGGER.debug("Command '{0}' is asynchronous. Waiting for response.", [commandVO.command]);
			} else {
				progress++;
				dispatchProgressEvent();
				LOGGER.debug("Command '{0}' is synchronous and is executed. Trying to execute next command.", [commandVO.command]);
				executeNextCommand();
			}
		}

		/**
		 * Retrieves and removes the next <code>ICommand</code> from the internal list and passes it to the
		 * <code>executeCommand()</code> method.
		 */
		protected function executeNextCommand():void {
			var nextCommand:CommandVO = _commands.shift() as CommandVO;
			if(!_timer){
				_timer = getTimer();
			}
			var time : int = getTimer();

			if (nextCommand) {
				LOGGER.debug("Executing next command '{0}'. Remaining number of commands: '{1}'. Time: {2}", [nextCommand.command, _commands.length, time - _timer]);
				executeCommand(nextCommand);
			} else {
				LOGGER.debug("All commands in '{0}' have been executed. Dispatching 'complete' event.", [this]);
				dispatchCompleteEvent();
			}
		}

		protected function removeCommand(asyncCommand:IOperation):void {
			Assert.notNull(asyncCommand, "asyncCommand argument must not be null");
			if (_commands != null) {
				
				for each (var cmd:CommandVO in _commands) {
					var idx:int = _commands.indexOf(cmd);
					if (idx > -1) {
						_commands.splice(idx, 1);
						break;
					}
				}
				
				if (_commands.length < 1) {
					dispatchCompleteEvent();
				}
			}
		}

		protected function executeCommandsInParallel():void {
			var containsOperations:Boolean = false;
			for each (var cmd:CommandVO in _commands) {
				if (cmd.command is IOperation) {
					containsOperations = true;
					addCommandListeners(IOperation(cmd.command));
				}
				dispatchBeforeCommandEvent(cmd.command);
				cmd.command.execute(cmd.event);
				if (!(cmd is IOperation)) {
					dispatchAfterCommandEvent(cmd.command);
				}
			}
			if (!containsOperations) {
				dispatchCompleteEvent();
			}
		}

		/**
		 * Adds the <code>onCommandResult</code> and <code>onCommandFault</code> event handlers to the specified <code>IAsyncCommand</code> instance.
		 */
		protected function addCommandListeners(asyncCommand:IOperation):void {
			if (asyncCommand) {
				asyncCommand.addCompleteListener(onCommandResult);
				asyncCommand.addErrorListener(onCommandFault);
			}
		}

		/**
		 * Removes the <code>onCommandResult</code> and <code>onCommandFault</code> event handlers from the specified <code>IAsyncCommand</code> instance.
		 */
		protected function removeCommandListeners(asyncCommand:IOperation):void {
			if (asyncCommand) {
				asyncCommand.removeCompleteListener(onCommandResult);
				asyncCommand.removeErrorListener(onCommandFault);
			}
		}

		protected function onCommandResult(event:OperationEvent):void {
			progress++;
			dispatchProgressEvent();
			LOGGER.debug("Asynchronous command '{0}' returned result. Executing next command.", [event.target]);
			removeCommandListeners(IOperation(event.target));
			dispatchAfterCommandEvent(ICommand(event.target));
			switch (_kind) {
				case CompositeCommandKind.SEQUENCE:
					executeNextCommand();
					break;
				case CompositeCommandKind.PARALLEL:
					removeCommand(IOperation(event.target));
				break;
				default:
					break;
			}
		}

		protected function onCommandFault(event:OperationEvent):void {
			LOGGER.debug("Asynchronous command '{0}' returned error.", [event.target]);
			dispatchErrorEvent(event.error);
			removeCommandListeners(event.target as IOperation);
			switch (_kind) {
				case CompositeCommandKind.SEQUENCE:
					if (failOnFault) {
						_currentCommandVO = null;
					} else {
						executeNextCommand();
					}
					break;
				case CompositeCommandKind.PARALLEL:
					removeCommand(IOperation(event.target));
					break;
				default:
					break;
			}
		}

		protected function dispatchAfterCommandEvent(command:ICommand):void {
			Assert.notNull(command, "the command argument must not be null");
			dispatchEvent(new CompositeCommandEvent(CompositeCommandEvent.AFTER_EXECUTE_COMMAND, command));
		}

		protected function dispatchBeforeCommandEvent(command:ICommand):void {
			Assert.notNull(command, "the command argument must not be null");
			dispatchEvent(new CompositeCommandEvent(CompositeCommandEvent.BEFORE_EXECUTE_COMMAND, command));
		}

		public function addCommand(command : ICommand) : ICompositeCommand {
			return null;
		}

		public function addCommandAt(command : ICommand, index : int) : ICompositeCommand {
			return null;
		}

		public function addOperationAt(operationClass : Class, index : int, ... constructorArgs) : ICompositeCommand {
			return null;
		}

		

	}

}