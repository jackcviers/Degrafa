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
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.IGeometryComposition;
	import flash.geom.Matrix;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	
	[Exclude(name="focalPointRatio", kind="property")]
	[Bindable(event="propertyChange")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("LinearGradientFill.png")]
	
	/**
	* The linear gradient fill class lets you specify a gradient fill.
	* 
	* @see mx.graphics.LinearGradient 
	* @see http://samples.degrafa.com/LinearGradientFill/LinearGradientFill.html	 
	**/
	public class LinearGradientFill extends GradientFillBase implements IGraphicsFill {
		
		public function LinearGradientFill(){
			super();
			super.gradientType = "linear";
			
		}
		
		/**
		* The focalPointRatio property is not valide for a LinearGradientFill and 
		* will be ignored.
		**/
		override public function get focalPointRatio():Number{return 0;}
		override public function set focalPointRatio(value:Number):void{}	
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the gradient rectangle. If not specified 
		* a default value of 0 is used.
		**/
		public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		public function set x(value:Number):void{
			if(_x != value){
				
				var oldValue:Number=_x;
				
				_x = value;
				
				//call local helper to dispatch event	
				initChange("x",oldValue,_x,this);
				
			}
		}
		
		
		private var _y:Number;
		/**
		* The y-axis coordinate of the upper left point of the gradient rectangle. If not specified 
		* a default value of 0 is used.
		**/
		public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		public function set y(value:Number):void{
			if(_y != value){
				
				var oldValue:Number=_y;
								
				_y = value;
				
				//call local helper to dispatch event	
				initChange("y",oldValue,_y,this);
				
			}
		}
		
						
		private var _width:Number;
		/**
		* The width to be used for the gradient rectangle.
		**/
		public function get width():Number{
			if(!_width){return 0;}
			return _width;
		}
		public function set width(value:Number):void{
			if(_width != value){
				
				var oldValue:Number=_width;
				
				_width = value;
				
				//call local helper to dispatch event	
				initChange("width",oldValue,_width,this);
			}
		}
		
		
		private var _height:Number;
		/**
		* The height to be used for the gradient rectangle.
		**/
		public function get height():Number{
			if(!_height){return 0;}
			return _height;
		}
		public function set height(value:Number):void{
			if(_height != value){
				
				var oldValue:Number=_height;
				
				_height = value;
				
				//call local helper to dispatch event	
				initChange("height",oldValue,_height,this);
			
			}
		}
		
		
			
		/**
		* Ends the fill for the graphics context.
		* 
		* @param graphics The current context being drawn to.
		**/
		override public function end(graphics:Graphics):void
		{
			super.end(graphics);
		}
		
		
		
		/**
		* Begins the fill for the graphics context.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		override public function begin(graphics:Graphics, rc:Rectangle):void {
			if (_x && _y && _width && _height) {
				if (_coordType == "relative") super.begin(graphics, new Rectangle(rc.x + x, rc.y + y, width, height));
				else if (_coordType == "ratio") super.begin(graphics, new Rectangle(rc.x + x * rc.width, rc.y + y * rc.height, width * rc.width, height * rc.height));
				else super.begin(graphics, new Rectangle(x, y, width, height));
			}
			else if (_width && _height) {
				if (_coordType == "relative") super.begin(graphics, new Rectangle(rc.x , rc.y , width, height));
				else if (_coordType == "ratio") super.begin(graphics, new Rectangle(rc.x, rc.y , width * rc.width, height * rc.height));
				else super.begin(graphics, new Rectangle(0, 0, width, height));
			}
			else{
				super.begin(graphics,rc);
			}
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:LinearGradientFill):void{
			
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_width){_width = value.width;}
			if (!_height){_height = value.height;}
			if (!_spreadMethod){_spreadMethod = value.spreadMethod;}
			if (!_angle){_angle = value.angle;}
			if (!_blendMode){_blendMode = value.blendMode;}
			if (!_interpolationMethod){_interpolationMethod = value.interpolationMethod;}
			if (!_spreadMethod){_spreadMethod = value.spreadMethod;}
		
			if (!_gradientStops && value.gradientStops.length!=0){gradientStops = value.gradientStops};
		
		}
		
	}
}