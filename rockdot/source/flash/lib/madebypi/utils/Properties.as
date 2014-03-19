/*
Copyright (c) 2009 Mike Almond, MadeByPi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package madebypi.utils {
	
	/**
	 * @author Mike Almond - MadeByPi	 * @version 1.0	 *
	 * @author Simon Schmid (contact(at)sschmid.com)
	 * some optimizations
	 * @version 1.1
	 * 
	 * Container for properties with replaceable numerical tokens - {1}, {2}, {3},... {n}
	 */
	
	public class Properties {
		
		private var _props:Array;
		
		public function Properties(properties:Array = null) {
			_props = properties;
			if (_props == null) _props = [];
		}
		
		/**
		 * Get a property String
		 * @param	name	Name of the property to retrive
		 * @param	...args	Replace any tokens {n} with these values
		 * @return
		 */
		public function getProperty(name:String, ...args:*):String {
			var n		:int 	= _props.length;
			var m		:int 	= args.length;
			var value	:String = null;
			
			while (--n > -1) {
				if (String(_props[n].name) == name) {
					value = String(_props[n].value);
					// replace any numerical tokens in the property with values passed in via the args parameter
					while (--m > -1) value = value.split("{" + (m + 1) + "}").join(args[m]);
					break;
				}
			}
			
			if (value != null && (value == "" || value.length == 0)) value = null;
			return value ? value : "{" + name + "}";
		}
		
		public function setProperty(name:String, value:String):void {
			var i:int = getPropertyIndex(name);
			if(i == -1){
				_props.push( { name:name, value:value } );
			} else {
				_props[i] = { name:name, value:value };
			}
		}
		
		public function removeProperty(name:String):void {
			var i:int = getPropertyIndex(name);
			if (i != -1) _props.splice(i, 1);
		}
		
		private function getPropertyIndex(name:String):int{
			var n:int = _props.length;
			while (--n > -1) {
				if (String(_props[n].name) == name) return n;
			}
			return -1;
		}
	}
}