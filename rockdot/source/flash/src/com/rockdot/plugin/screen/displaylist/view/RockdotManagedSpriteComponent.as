package com.rockdot.plugin.screen.displaylist.view {
	import com.greensock.TweenLite;

	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;




	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class RockdotManagedSpriteComponent extends ManagedSpriteComponent implements IApplicationContextAware {
		protected var _context : IApplicationContext;
		public function get applicationContext() : IApplicationContext {
			return _context;
		}
		public function set applicationContext(value : IApplicationContext) : void {
			_context = value as IApplicationContext;
			_properties = _context.propertiesProvider;
		}

		protected var _properties : IPropertiesProvider;

		protected function getProperty(key : String, omitPrefix : Boolean = false) : String {
			key = (omitPrefix ? "" : name + ".") + key;
			var str : String = _properties.getProperty( key );
			if(!str){
				str = key;
			}
			
			return str;
		}

		public function RockdotManagedSpriteComponent(id : String) {
			super (id);
			_ignoreCallSetSize = true;
		}
		
		override public function appear(duration : Number = 0.5) : void {
			super.appear(duration);
			TweenLite.delayedCall(duration, _onAppear);
		}

		override public function disappear(duration : Number = 0.5, autoDestroy : Boolean = false) : void {
			super.disappear(duration, autoDestroy);
			TweenLite.delayedCall(duration, _onDisappear);
		}
	}
}
