package com.jvm.utils {

	/**
	 * @author oliver.mueller
	 * 
	 * @version 1.1 - Simon Schmid
	 * 
	 */
	public class ColorConversion {
		public static function hsv2rgb(hue : Number, saturation : Number, amount : Number) : int {
			var r : Number, g : Number, b : Number, i : Number, f : Number, p : Number, q : Number, t : Number;
			hue %= 360;
			if(amount == 0)
				return 0;
				
			saturation /= 100;
			amount /= 100;
			hue /= 60;
			i = Math.floor(hue);
			f = hue - i;
			p = amount * (1 - saturation);
			q = amount * (1 - (saturation * f));
			t = amount * (1 - (saturation * (1 - f)));
			if (i == 0) {
				r = amount; 
				g = t; 
				b = p;
			}
			else if (i == 1) {
				r = q; 
				g = amount; 
				b = p;
			}
			else if (i == 2) {
				r = p; 
				g = amount; 
				b = t;
			}
			else if (i == 3) {
				r = p; 
				g = q; 
				b = amount;
			}
			else if (i == 4) {
				r = t; 
				g = p; 
				b = amount;
			}
			else if (i == 5) {
				r = amount; 
				g = p; 
				b = q;
			}
			r = Math.floor(r * 255);
			g = Math.floor(g * 255);
			b = Math.floor(b * 255);
//			return ({r:red, g:grn, b:blu});
			return (r << 16 | g << 8 | b);
		}

		
		public static function rgb2hsv(r : Number, g : Number, b : Number) : Object {
			var x : Number, amount : Number, f : Number, i : Number, hue : Number, saturation : Number;
			r /= 255;
			g /= 255;
			b /= 255;
			x = Math.min(Math.min(r, g), b);
			amount = Math.max(Math.max(r, g), b);
			if (x == amount) {
				return({h:undefined, s:0, v:amount * 100});
			}
			f = (r == x) ? g - b : ((g == x) ? b - r : r - g);
			i = (r == x) ? 3 : ((g == x) ? 5 : 1);
			hue = Math.floor((i - f / (amount - x)) * 60) % 360;
			saturation = Math.floor(((amount - x) / amount) * 100);
			amount = Math.floor(amount * 100);
			return({h:hue, s:saturation, v:amount});
		}
	}
}
