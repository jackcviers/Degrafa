////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 The Degrafa Team : http://www.Degrafa.com/team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////

package com.degrafa.core.utils{
	import com.degrafa.paint.palette.PaletteEntry;
	
	
	/**
	* A helper utility class for color conversion.
	**/
	public class ColorUtil{
		
		/**
		* Resolves the color value passed to a valid hex value.
		**/
		public static function resolveColor(value:Object, none:uint = 0):uint {
			if (value is uint) {
				//CHANGE: do not attempt to identify shorthand hex notation from a uint value
				//this will break some previous code examples with shorthand notation, but needs to be fixed
				//there is no way to discriminate with certainty if the value is uint when checked
	
				/*LEGACY TRACE WARNING CODE*/
			/* 	 if (value.toString(16).length==3){
					trace('WARNING:  #000'+value.toString(16) +' not assumed to be #'+value.toString(16)+'! If your color definitions contain shorthand hex notation(e.g. #FFF for white) this will no longer be supported/interpreted as shorthand in this and future versions of Degrafa. Please adjust your mxml source code to not assume shorthand hex notation or use older versions of Degrafa. This trace messaage will be removed for version 1 of Degrafa onwards')
					 //return parseColorNotation(value.toString(16));		
				} */

					return value as uint;
				}
 
			else if(value is String){
				return resolveColorFromString(value as String, none);
			} 
			else if(value is PaletteEntry){
				return resolveColor(PaletteEntry(value).value, none);
			}
			else{
				//always return black if not valid or no color found
				return 0x000000;
			}
		}
		
		private static function resolveColorFromString(value:String, none:uint = 0):uint {
			// todo: evaluate for functions?
			if(value.search(",")==3) { // rgb assumption
				//check and see if it is a percent list or a numeric list
				if (value.search("%")!=-1) {
					return resolveColorFromRGBPercent(value as String);	
				} else {
					return resolveColorFromRGB(value as String);	
				}
			} else if(value.search(",")==4) { // cmyk assumption
				return resolveColorFromCMYK(value as String);	
			}
			var color:uint = 0;
			if(String(value).charAt(0)=="#" || String(value).substr(0,2)=="0x") {
				value = value.replace("#", "");
				//shorthand  e.g #FDF expands to #FFDDFF
				if (value.length == 3) color = parseColorNotation(value);
				else color = parseInt(value, 16);
			} else { color = parseInt(String(value), 10); }
			if(isNaN(color) || color==0) {
				color = resolveColorFromKey(value as String, none);
			}
			return color;
		}
		
		/**
		* Converts Color Keys to color values. If the specified color key is not 
		* supported then black is used.
		**/
		public static function resolveColorFromKey(value:String, none:uint = 0):uint {
			var colorKey:String = value.toUpperCase();
			if(ColorKeys[colorKey] != null){
				return uint(ColorKeys[colorKey]);
			} else {
				return none;
			}
		}
		
		/**
		* Allows an comma-separated list of 4 numerical
		* values that represent cmyk and are then converted to 
		* a decimal color value.
		**/
		/**
		* Conversion from CMYK to RGB values.
		**/   
		public static function resolveColorFromCMYK(value:String):uint {   
			var tempColors:Array = value.split(",");
			
			var cyan:int = (0xFF * tempColors[0])/100;         
			var magenta:int = (0xFF * tempColors[1])/100;         
			var yellow:int = (0xFF * tempColors[2])/100;         
			var key:int = (0xFF * tempColors[3])/100;              
			
			var red:int = int(decColorToHex(Math.round((0xFF-cyan)*(0xFF-key)/0xFF)));         
			var green:int = int(decColorToHex(Math.round((0xFF-magenta)*(0xFF-key)/0xFF)));         
			var blue:int = int(decColorToHex(Math.round((0xFF-yellow)*(0xFF-key)/0xFF)));          
		
			return resolveColorFromRGB(red +","+ green +","+blue);
					
		}
				
		/**
		* Allows an comma-separated list of three numerical or 
		* percent values that are then converted to a hex value. 
		**/
		
		/**
		* Converts an RGB percentage comma separated list 
		* to a decimal color value. Expected order is R,G,B.
		**/
		public static function resolveColorFromRGBPercent(value:String):uint {
			
			//Note: Should be verified for rounding differences
			//depending on the industry norms
						
			var tempColors:Array = value.replace(/%/g,"").split(",");
								
			//convert as a percentage of 0 to 255 before the bitwise op
			return uint((int(Math.round(tempColors[0]/100*255))<<16) | (int(Math.round(tempColors[1]/100*255))<< 8) | int(Math.round(tempColors[2]/100*255)));
			
		}
		
		/**
		* Converts an RGB numeric comma separated list
		* to a decimal color value. Expected order R,G,B.
		**/
		public static function resolveColorFromRGB(value:String):Number{
			
			var tempColors:Array = value.split(",");
			return uint((int(tempColors[0])<<16) | (int(tempColors[1])<< 8) | int(tempColors[2]));
			
		}
		
		/**
		* Converts a HEX color value to an RGB value object.
		**/
		public static function hexToRgb(hex:Number):Object{
			var red:Number = hex>>16;        
			var greenBlue:Number = hex-(red<<16);        
			var green:Number = greenBlue>>8;        
			var blue:Number = greenBlue-(green<<8);        
			return({red:red, green:green, blue:blue})
		}
		
		/**
		* Converts a decimal color to a hex value.
		**/
		public static function decColorToHex(color:uint,prefix:String="0x"):String{
			
			var hexVal:String =   ("00000" + color.toString(16).toUpperCase()).substr( -6);
			return prefix + hexVal;
						
		}
		
		/**
		* Take a short color notation and convert it to a full color.
		* Repeats each value once so that #FB0 expands to #FFBB00 
		**/
		public static function parseColorNotation(color:String):uint
		{
			//dev note:extra check here for #, although it's already removed when requested from inside resolveColorFromString method above
			color = color.replace("#", ""); 
			color = '0x'+color.charAt(0) + color.charAt(0) + color.charAt(1) + color.charAt(1) + color.charAt(2) + color.charAt(2);
			return uint(color);				
		}
		
	}
}