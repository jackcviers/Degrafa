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

////////////////////////////////////////////////////////////////////////////////
// Algorithims translated from and/or based on prefuse ColorLib.java.
// Copyright (c) 2004-2006 Regents of the University of California.
// All rights reserved.
////////////////////////////////////////////////////////////////////////////////  
package com.degrafa.paint.palette{
	
	/**
	* Methods for processing color values and generating color palettes. 
	**/
	public class PaletteUtils{
		
		private static var baseScale:Number = 0.7;
		
		/**
	    * Get the color code for the given red, green, and blue values.
     	*/
	    public static function rgb(r:int, g:int, b:int):uint{
	        return rgba(r, g, b, 255);
	    }
		
		/**
		* Get the color code for the given hue, saturation, and brightness
		* values, translating from HSB color space to RGB color space.
		*/
		public static function hsb(h:Number, s:Number, b:Number):uint {
		    return HSBtoRGB(h,s,b);
		}

		/**
     	* Get the color code for the given hue, saturation, and brightness
     	* values, translating from HSB color space to RGB color space.
     	**/
		public static function hsba(h:Number, s:Number, b:Number, a:Number):uint {
        	return setAlpha(HSBtoRGB(h,s,b), (a*255+0.5) & 0xFF);
    	}

		/**
		* Get the color code for the given red, green, blue, and alpha values.
		*/
		public static function rgba(r:int, g:int, b:int, a:int=255):uint{
			return ((a & 0xFF) << 24) | ((r & 0xFF) << 16) |
				   ((g & 0xFF) <<  8) |  (b & 0xFF);
		}

		/**
		* Get the color code for the given red, green, blue, and alpha values as
     	* floating point numbers in the range 0-1.0.
		*/
	    public static function rgbaFloat(r:Number, g:Number, b:Number, a:Number):uint {
	        return ((((a*255+0.5)) & 0xFF) << 24) |
	               ((((r*255+0.5)) & 0xFF) << 16) | 
	               ((((g*255+0.5)) & 0xFF) <<  8) |
	               ((((b*255+0.5)) & 0xFF));
	    }
    
    	/**
	    * Interpolate between two color values by the given mixing proportion.
		*/
	    public static function interpolate(color1:uint,color2:uint,t:Number):uint {
	        var it:Number = 1-t;
	        return rgba(
	            Math.round(t*red(color2)   + it*red(color1)),
	            Math.round(t*green(color2) + it*green(color1)),
	            Math.round(t*blue(color2)  + it*blue(color1)),
	            Math.round(t*alpha(color2) + it*alpha(color1)));
	    }
    
	    /**
    	* Returns a color array of given size that ranges from one
     	* given color to the other.
		*/
  	    public static function getInterpolatedPalette(size:int,color1:uint, color2:uint):Array{
	        var colorMap:Array =[];
	        for(var i:int=0; i<size; i++ ) {
	        	var t:Number = (i/(size-1));
	            colorMap.push(interpolate(color1,color2,t));
	        }
	        return colorMap;
	    }
		
		/**
     	* Returns a color palette that uses a "cool", blue-heavy color scheme.
	    */
	    public static function getCoolPalette(size:int):Array{
	        var colorMap:Array =[];
	        for(var i:int=0; i<size; i++ ) {
	            var r:Number = i / Math.max(size-1,1.0);
	            colorMap.push(rgbaFloat(r,1-r,1.0,1.0));
	        }
	        return colorMap;
	    }
    
	    /**
     	* Returns a color palette that moves from black to red to yellow
     	* to white.
		*/
	    public static function getHotPalette(size:int):Array {
	        var colorMap:Array =[];
	        for (var i:int=0; i<size; i++) {
	            var n:int = (3*size)/8;
	            var r:Number = ( i<n ? ((i+1))/n : 1.0 );
	            var g:Number = ( i<n ? 0.0 : ( i<2*n ? ((i-n))/n : 1.0 ));
	            var b:Number = ( i<2*n ? 0.0 : ((i-2*n))/(size-2*n) );
	            
	            colorMap.push(rgbaFloat(r,g,b,1.0));
	            
	        }
	        return colorMap;
	    }
    
	    /**
    	* Returns a color palette of specified size that ranges from white to
     	* black through shades of gray.
		*/
	    public static function getGreyScalePalette(size:int):Array {
	        var colorMap:Array =[];
	        for (var i:int=0; i<size; i++) {
	            var g:int = Math.round(255*(0.2 + 0.6*i)/(size-1));
	            colorMap.push(Math.abs(grey(g)));
	        }
	        return colorMap;
	    }
	    
	     /**
	     * Returns a color palette of given size tries to provide colors
	     * appropriate as category labels. There are 12 basic color hues
	     * (red, orange, yellow, olive, green, cyan, blue, purple, magenta,
	     * and pink). If the size is greater than 12, these colors will be
	     * continually repeated, but with varying saturation levels.
	     * @param size the size of the color palette
	     * @param s1 the initial saturation to use
	     * @param s2 the final (most distant) saturation to use
	     * @param b the brightness value to use
	     * @param a the alpha value to use
	     */
	     public static function getCategoryPalette(size:int, 
	            s1:Number, s2:Number, b:Number,a:int):Array{
	            	
	        var colorMap:Array = new Array(size);
	        var s:Number = s1;
	        var j:int;
	        for (var i:int=0; i<size; i++ ) {
	            j = i % CATEGORY_HUES.length;
	            if (j == 0)
	                s = s1 + ((i)/size)*(s2-s1);
	                
	            colorMap.push(hsba(CATEGORY_HUES[j],s,b,a));
	            
	        }
	        return colorMap;
	     }
	     
	     /**
	     * Returns a color palette of given size that cycles through
	     * the hues of the HSB (Hue/Saturation/Brightness) color space.
	     * @param size the size of the color palette
	     * @param s the saturation value to use
	     * @param b the brightness value to use
	     * @return the color palette
	     */
	     public static function getHSBPalette(size:int, s:Number, b:Number):Array{
	        var colorMap:Array = new Array(size);
	        var h:Number;
	        for (var i:int=0; i<size; i++ ) {
	            h = (i)/(size-1);
	            colorMap.push(hsb(h,s,b));
	        }
	        return colorMap;
	    }
	    	    
	    /**
	    * Get the color code for the given grayscale value.
		*/
	    public static function grey(color:int):int {
	        return rgba(color, color, color, 255);
	    }
	    
	    /**
	    * Get the red component of the given color.
		*/
	    public static function red(color:int):int {
        	return (color>>16) & 0xFF;
   		}
        
        /**
	    * Get the green component of the given color.
   	 	*/
	    public static function green(color:int):int {
	        return (color>>8) & 0xFF;
	    }
	    
	    /**
	    * Get the blue component of the given color.
	    **/
 	    public static function blue(color:int):int {
	        return color & 0xFF;
	    }
	    
	    /**
     	* Get the alpha component of the given color.
     	**/
	    public static function alpha(color:int):int {
	        return (color>>24) & 0xFF;
	    }
				
		/**
	    * Set the alpha component of the given color.
	    */
	    public static function setAlpha(color:uint, alpha:Number):uint {
	        return rgba(red(color), green(color), blue(color), alpha);
	    }
	    
	    /**
		* Set the saturation of an input color.
		*/
		public static function saturate(color:uint, saturation:Number):uint{
		    var hsb:Object = RGBtoHSB(red(color), green(color), blue(color));
		    return hsb(hsb.h, saturation, hsb.b);
		}


		/**
	    * Get a darker shade of an input color.
     	*/
	    public static function darker(color:uint):uint {
	        return rgba(Math.max(0, (baseScale*red(color))),
	                    Math.max(0, (baseScale*green(color))),
	                    Math.max(0, (baseScale*blue(color))),
	                    alpha(color));
	    }
	
		/**
	    * Get a brighter shade of an input color.
	    */
	    public static function brighter(color:uint):uint {
	        var r:int = red(color);
	        var g:int = green(color);
	        var b:int = blue(color);
	        var i:int = (1.0/(1.0-baseScale));
	        
	        if ( r == 0 && g == 0 && b == 0) {
	           return rgba(i, i, i, alpha(color));
	        }
	        if ( r > 0 && r < i ) r = i;
	        if ( g > 0 && g < i ) g = i;
	        if ( b > 0 && b < i ) b = i;
	
	        return rgba(Math.min(255, (r/baseScale)),
	                    Math.min(255, (g/baseScale)),
	                    Math.min(255, (b/baseScale)),
	                    alpha(color));
	    }

		/**
	    * Get a desaturated shade of an input color.
	    */
	    public static function desaturate(color:uint):uint {
	        var a:int = color & 0xff000000;
	        var r:Number = ((color & 0xff0000) >> 16);
	        var g:Number = ((color & 0x00ff00) >> 8);
	        var b:Number = (color & 0x0000ff);
	
	        r *= 0.2125; // red band weight
	        g *= 0.7154; // green band weight
	        b *= 0.0721; // blue band weight
	
	        var gray:uint = Math.min(((r+g+b)),0xff) & 0xff;
	        return a | (gray << 16) | (gray << 8) | gray;
	    }

		

	  	/**
	    * Default palette of category hues.
	    */
	    public static var CATEGORY_HUES:Array = new Array(0, 1/12, 1/6, 1/3, 1/2, 7/12, 2/3, 5/6, 11/12);

		/**
		* Convert hsb color value to rgb.
		**/
		public static function HSBtoRGB(h:Number,s:Number,v:Number):uint{  
			var r:int;
			var g:int;
			var b:int;
			
			var h:Number = Math.round(h);
			var s:Number = Math.round(s*255/100);
			var v:Number = Math.round(v*255/100);
			
			if(s == 0) {
				r = g = b = v;
			} else {
				var t1:Number = v;	
				var t2:Number = (255-s)*v/255;	
				var t3:Number = (t1-t2)*(h%60)/60;
				if(h==360) h = 0;
				if(h<60) {r=t1;	b=t2;	g=t2+t3}
				else if(h<120) {g=t1;	b=t2;	r=t1-t3}
				else if(h<180) {g=t1;	r=t2;	b=t2+t3}
				else if(h<240) {b=t1;	r=t2;	g=t1-t3}
				else if(h<300) {b=t1;	g=t2;	r=t2+t3}
				else if(h<360) {r=t1;	g=t2;	b=t1-t3}
				else {r=0;	g=0;	b=0}
			}
			return rgb(r, g, b);
		}
		
		/**
		* Convert rbg color value to hsb.
		**/ 
		public static function RGBtoHSB(r:int,g:int,b:int):Object {  
			var hsb:Object = new Object();
			hsb.b = Math.max(Math.max(r,g),b);
			var min:int = Math.min(Math.min(r,g),b);
			
			hsb.s = (hsb.b <= 0) ? 0 : Math.round(100*(hsb.b - min)/hsb.b);
			hsb.b = Math.round((hsb.b /255)*100);
			hsb.h = 0;
			
			if((r==g) && (g==b))  hsb.h = 0;
			else if(r>=g && g>=b) hsb.h = 60*(g-b)/(r-b);
			else if(g>=r && r>=b) hsb.h = 60  + 60*(g-r)/(g-b);
			else if(g>=b && b>=r) hsb.h = 120 + 60*(b-r)/(g-r);
			else if(b>=g && g>=r) hsb.h = 180 + 60*(b-g)/(b-r);
			else if(b>=r && r>=g) hsb.h = 240 + 60*(r-g)/(b-g);
			else if(r>=b && b>=g) hsb.h = 300 + 60*(r-b)/(r-g);
			else hsb.h = 0;
			hsb.h = Math.round(hsb.h);
			return hsb;
		}
		
	}
}