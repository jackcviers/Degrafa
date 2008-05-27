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
package com.degrafa.paint{
	
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.utils.ColorUtil;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	
	[Bindable(event="propertyChange")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("SolidFill.png")]
	
	/**
	* Solid fill defines a fill color to be applied to a graphics contex.
	* @see http://samples.degrafa.com/SolidFill/SolidFill.html  
	**/
	public class SolidFill extends DegrafaObject implements IGraphicsFill{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The solid fill constructor accepts 2 optional arguments that define 
	 	* it's rendering color and alpha.</p>
	 	* 
	 	* @param color A unit or String value indicating the stroke color.
	 	* @param alpha A number indicating the alpha to be used for the fill.
	 	*/
		public function SolidFill(color:Object=null, alpha:Number=NaN){
			this.alpha = alpha;
			this.color = color;
			
			
		}
		
		protected var _alpha:Number;
		[Inspectable(category="General")]
		/**
 		* The transparency of a fill.
 		* 
 		* @see mx.graphics.Stroke
 		**/
		public function get alpha():Number{
			if(isNaN(_alpha)){return 1;}
			return _alpha;
		}
		public function set alpha(value:Number):void{
			if(_alpha != value){
				var oldValue:Number=_alpha;
			
				_alpha = value;
			
				//call local helper to dispatch event	
				initChange("alpha",oldValue,_alpha,this);
			}
		}
				
		protected var _color:Object;
		[Inspectable(category="General", format="Color",defaultValue="0x000000")]
		/**
 		 * The fill color.
 		 * This property accepts uint, hexadecimal (including shorthand), 
 		 * and color keys as well as comma seperated rgb or cmyk values.
 		 * 
 		**/
		public function get color():Object {
			if(!_color){return 0x000000;}
			return _color; 
		}
		public function set color(value:Object):void{
			value = ColorUtil.resolveColor(value);
			if(_color != value){ // value gets resolved first
				var oldValue:uint =_color as uint;
				_color= value as uint;
				//call local helper to dispatch event	
				initChange("color",oldValue,_color,this);
			}
		}
		
		protected var _colorFunction:Function;
		[Inspectable(category="General")]
		/**
		 * Function that sets the color of the fill. It is executed on
		 * every draw.
		 **/		
		public function get colorFunction():Function{
			return _colorFunction;
		}
		public function set colorFunction(value:Function):void{
			if(_colorFunction != value){ // value gets resolved first
				var oldValue:Function =_colorFunction as Function;
				_colorFunction= value as Function;
				//call local helper to dispatch event	
				initChange("colorFunction",oldValue,_colorFunction,this);
			}
		}
		
		/**
		* Begins the fill for the graphics context.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		public function begin(graphics:Graphics, rc:Rectangle):void{
			var tempColor:uint;
			// if no color function, use normal color var
			if(colorFunction!=null){
				tempColor = ColorUtil.resolveColor(colorFunction());
			}
			else{
				if(!_color){_color=0x000000;}
				tempColor = _color as uint;
			}
			//ensure that all defaults are in fact set these are temp until fully tested
			if(isNaN(_alpha)){_alpha=1;}
			
			graphics.beginFill(tempColor,alpha);						
		}
		
		/**
		* Ends the fill for the graphics context.
		* 
		* @param graphics The current context being drawn to.
		**/
		public function end(graphics:Graphics):void{
			graphics.endFill();
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:SolidFill):void{
			
			if (!_color){_color = uint(value.color);}
			if (isNaN(_alpha)){_alpha = value.alpha;}
		}
	}
}