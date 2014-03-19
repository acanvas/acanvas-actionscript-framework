package com.rockdot.plugin.screen.displaylist.view {
	import com.rockdot.core.context.RockdotHelper;

	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;



	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class RockdotSpriteComponent extends SpriteComponent implements IApplicationContextAware{
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
			return _properties.getProperty( (omitPrefix ? "" : name + ".") + key);
		}
		
		public function RockdotSpriteComponent() {
			super ();
			RockdotHelper.wire(this);
		}
		
	}
}
