package com.rockdot.plugin.screen.common.service {
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.plugin.screen.common.command.event.ScreenEvents;
	import com.rockdot.plugin.screen.displaylist.view.ManagedSpriteComponent;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.BitmapFilter;


	/**
	 * @author nilsdoehring
	 */
	public class AbstractScreenService implements IScreenService{
		
		protected static var log : ILogger = getLogger(IScreenService);			

		/**
		 * GETTER AND SETTER
		 */
		protected var _background : ManagedSpriteComponent;

		public function get background() : ManagedSpriteComponent {
			return _background;
		}

		protected var _content : ManagedSpriteComponent;
		public function get content() : ManagedSpriteComponent {
			return _content;
		}

		protected var _navi : ManagedSpriteComponent;
		public function get navi() : ManagedSpriteComponent {
			return _navi;
		}

		protected var _layer : ManagedSpriteComponent;
		public function get layer() : ManagedSpriteComponent {
			return _layer;
		}

		protected var _foreground : ManagedSpriteComponent;
		public function get foreground() : ManagedSpriteComponent {
			return _foreground;
		}	

		public function get stage() : Stage {
			return RockdotConstants.getStage();
		}
		
		protected var _initialized : Boolean;
		public function get initialized() : Boolean {
			return _initialized;
		}
		
		protected var  _filter : BitmapFilter;
		public function get modalBackgroundFilter() : BitmapFilter {
			return _filter;
		}
		public function set modalBackgroundFilter(filter : BitmapFilter) : void {
			_filter = filter;
		}


		public function AbstractScreenService() {
			_initialized = false;
		}
		
		public function init(callback : Function = null) : void {
			
			_background = new ManagedSpriteComponent();
			_content = new ManagedSpriteComponent();
			_navi = new ManagedSpriteComponent();
			_layer = new ManagedSpriteComponent();
			_foreground = new ManagedSpriteComponent();
			
			stage.addChild(_background);
			stage.addChild(_content);
			stage.addChild(_navi);
			stage.addChild(_layer);
			stage.addChild(_foreground);
			
			_initialized = true;
			
			if(callback != null){
				callback.call();
			}

			resize();
			stage.addEventListener(Event.RESIZE, resize);
		}

		public function resize(event : Event = null) : void {
			
			_background.setSize(RockdotConstants.WIDTH_STAGE, RockdotConstants.HEIGHT_STAGE);
			_content.setSize(RockdotConstants.WIDTH_STAGE, RockdotConstants.HEIGHT_STAGE);
			_navi.setSize(RockdotConstants.WIDTH_STAGE, RockdotConstants.HEIGHT_STAGE);
			_layer.setSize(RockdotConstants.WIDTH_STAGE, RockdotConstants.HEIGHT_STAGE);
			_foreground.setSize(RockdotConstants.WIDTH_STAGE, RockdotConstants.HEIGHT_STAGE);
			
			log.debug(RockdotConstants.WIDTH_STAGE);
			log.debug(RockdotConstants.HEIGHT_STAGE);

			new RockdotEvent(ScreenEvents.RESIZE).dispatch();
			
		}

		public function lock() : void {
			_content.mouseEnabled = false;
			_content.mouseChildren = false;
		}
		public function unlock() : void {
			_content.mouseEnabled = true;
			_content.mouseChildren = true;
		}
	}
}
