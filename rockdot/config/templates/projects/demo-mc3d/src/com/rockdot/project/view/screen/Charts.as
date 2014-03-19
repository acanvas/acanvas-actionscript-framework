package com.rockdot.project.view.screen {
	import com.danielfreeman.extendedMadness.UIe;
	import com.danielfreeman.madcomponents.UI;
	import com.rockdot.plugin.screen.displaylist.view.ManagedSpriteComponentMC3D;
	import com.rockdot.plugin.state.inject.IStateModelAware;
	import com.rockdot.plugin.state.model.StateModel;
	import com.rockdot.plugin.state.model.vo.StateVO;

	import org.springextensions.actionscript.ioc.config.property.IPropertyPlaceholderResolver;
	import org.springextensions.actionscript.ioc.config.property.impl.PropertyPlaceholderResolver;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.PropertyPlaceholderConfigurerFactoryPostProcessor;


	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 */
	public class Charts extends ManagedSpriteComponentMC3D implements IStateModelAware {
		protected var _stateModel : StateModel;

		public function set stateModel(stateModel : StateModel) : void {
			_stateModel = stateModel;
		}

		public function Charts(id : String) {
			super(id);
		}

		override public function init(data : * = null) : void {
			super.init(data);

			var stateVO : StateVO = _context.getObject("vo." + name);
			if (stateVO.madUI) {
				var strList : String = stateVO.madUI.toXMLString();
				var resolver : IPropertyPlaceholderResolver = new PropertyPlaceholderResolver(PropertyPlaceholderConfigurerFactoryPostProcessor.PROPERTY_REGEXP, _properties, true);
				strList = resolver.resolvePropertyPlaceholders(strList);

				UIe.create(this, new XML(strList), _width, _height);
			}

			_didInit();
		}
		
		override public function render() : void {
			super.render();
			UI.layout(_width, _height);
		}

		override public function destroy() : void {
			super.destroy();
		}
	}
}
