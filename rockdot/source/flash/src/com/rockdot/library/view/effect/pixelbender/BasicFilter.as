package com.rockdot.library.view.effect.pixelbender {
	import com.greensock.TweenLite;
	import com.rockdot.plugin.screen.displaylist.view.ISpriteComponent;

	import flash.display.Shader;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;




	/**
	 * @author nilsdoehring
	 */
	public class BasicFilter extends ShaderFilter {
		
		//the file that contains the binary bytes of the PixelBender filter
		[Embed("testfilter.pbj", mimeType="application/octet-stream")]
		private var Filter:Class;		

		private var _shader:Shader;

		public function BasicFilter(value:Number = 50)
		{
			//initialize the ShaderFilter with the PixelBender filter we
			//embedded
			_shader = new Shader(new Filter() as ByteArray);

			//set the default value
			this.value = value;
			super(_shader);
		}

		//This filter only has one value, named value
		public function get value():Number
		{
			return _shader.data.amount.value[0];
		}

		public function set value(value:Number):void
		{
			//not that pixel bender filters take an array of values, even
			//though we only have one in our example
			_shader.data.amount.value = [value];
		}
		
		public function applyFilter(effectType : String, member : ISpriteComponent, duration : Number, callback : Function = null) : void {
			
			member.filters = [this];
			
			if(callback != null){
				TweenLite.delayedCall(0.1, callback);
			}
			
		}
		
		
	}
}
