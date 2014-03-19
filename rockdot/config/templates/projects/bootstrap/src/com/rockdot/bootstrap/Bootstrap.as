package com.rockdot.bootstrap {
	import com.greensock.OverwriteManager;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.BezierThroughPlugin;
	import com.greensock.plugins.BlurFilterPlugin;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.DropShadowFilterPlugin;
	import com.greensock.plugins.RemoveTintPlugin;
	import com.greensock.plugins.ScalePlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.jvm.utils.DeviceDetector;
	import com.rockdot.core.context.RockdotApplicationContext;
	import com.rockdot.core.context.RockdotHelper;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.plugin.screen.displaylist.view.ManagedSpriteComponent;

	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.logging.api.LOGGER_FACTORY;
	import org.as3commons.logging.setup.ILogTarget;
	import org.as3commons.logging.setup.RegExpSetup;
	import org.as3commons.logging.setup.target.TraceTarget;

	import flash.events.Event;
	import flash.events.IOErrorEvent;


	/**
	 * @author Simon Schmid (contact@sschmid.com)
	 */
	public class Bootstrap extends ManagedSpriteComponent {
		private var _logTarget : ILogTarget;
		
		// Retain context
		private var _applicationContext : RockdotApplicationContext;

		public function Bootstrap() {
			super();
			enabled = true;
		}

		override public function init(data : * = null) : void {
			super.init(data);
			
			// AppConfig
			BootstrapConstants.init(data);
			RockdotConstants.setLoaderInfo(data["loaderInfo"]);
			RockdotConstants.setStage(data);

			//Logging
			if (RockdotConstants.DEBUG == false && !DeviceDetector.IS_AIR) {
				trace("_logging Disabled. Good Bye.");
				LOGGER_FACTORY.setup = null;
			} else {
				_logTarget = new TraceTarget();
				LOGGER_FACTORY.setup = new RegExpSetup()
					.addTargetRule(/^org\.as3commons\./, null)
					.addTargetRule(/^com\.rockdot\./, _logTarget)
					.addTargetRule(/^com\.rockdot\.core\./, null);
				_log.debug("_logging Enabled. Welcome.");
			}

			/* TweenLite Config */
			TweenPlugin.activate([AutoAlphaPlugin, TintPlugin, BlurFilterPlugin,  RemoveTintPlugin, ColorMatrixFilterPlugin, TransformAroundCenterPlugin, TransformAroundPointPlugin, DropShadowFilterPlugin, ScalePlugin, BezierThroughPlugin]);
			OverwriteManager.init(OverwriteManager.AUTO);
			
			_didInit();
		}


		override public function load(data : * = null) : void {
			super.load(data);

			// Instantiate and load context
			_log.debug("_initAppContext");

			/** Instantiate Context. */
			_applicationContext = new RockdotApplicationContext(RockdotHelper.getConfigLocation(), null);
			
			RockdotConstants.setContext( _applicationContext );
			
			/** add load listeners */
			_applicationContext.addEventListener(Event.COMPLETE, _onCoreApplicationContextLoadResult);
			_applicationContext.addEventListener(IOErrorEvent.IO_ERROR, _onCoreApplicationContextLoadFault);

			/** Load */
			_applicationContext.load();
		}
		
		/**
		 * Listener for COMPLETE Event of @see CoreApplicationContext
		 * Configures and executes (asynchronously) a @see CompositeCommandWithEvent
		 */
		private function _onCoreApplicationContextLoadResult(event : Event) : void {
			_log.debug("CoreApplicationContext Loaded...");
			_applicationContext.initApplication(_onCoreApplicationContextInitComplete, _onCoreApplicationContextInitError);
		}

		/**
		 * Listener for @see IOErrorEvent of @see CoreApplicationContext
		 * TODO Display error message
		 */
		private function _onCoreApplicationContextLoadFault(iOErrorEvent:IOErrorEvent) : void {
			_log.error("Spring Application Context Failed to Load: [" + iOErrorEvent.toString() + "]");
		}

		/**
		 * Listener for COMPLETE Event of @see CompositeCommandWithEvent
		 * By now, @see StatePlugin has taken over control.
		 */
		private function _onCoreApplicationContextInitComplete(event : OperationEvent = null) : void {
			// All models are loaded. Wiring is done. Extensions are ready. App is ready to go!
			_log.info("Application Context Initialized");

			// App.as listens to ViewEvent.DID_LOAD and will hide AppPreloader and show this
			_didLoad();
		}

		/**
		 * Listener for ERROR Event of @see CompositeCommandWithEvent
		 * TODO Display error message
		 */
		private function _onCoreApplicationContextInitError(event : OperationEvent = null) : void {
			_log.error("Application Error: " + event.error);
		}

		override public function set enabled(value : Boolean) : void {
			_enabled = mouseChildren = mouseEnabled = value; 
		}
	}
}
