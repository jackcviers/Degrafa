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
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("LinearGradientStroke.png")]
	
	[Exclude(name="focalPointRatio", kind="property")]
	[Bindable(event="propertyChange")]
	
	/**
	* The linear gradient stroke class lets you specify a gradient filled stroke.
	* 
	* @see mx.graphics.LinearGradientStroke 
	* @see http://samples.degrafa.com/LinearGradientStroke/LinearGradientStroke.html
	**/
	public class LinearGradientStroke extends GradientStrokeBase {
		
		public function LinearGradientStroke(){
			super();
			super.gradientType = "linear";
		}
		
		/**
		* The focalPointRatio property is not valide for a LinearGradientStroke 
		* and will be ignored.
		**/
		override public function get focalPointRatio():Number{return 0;}
		override public function set focalPointRatio(value:Number):void{}
		
		private var _x:Number;
		/**
		* The x-axis coordinate of the upper left point of the grtadient rectangle. If not specified 
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
		* The y-axis coordinate of the upper left point of the grtadient rectangle. If not specified 
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
		* The width to be used for the grtadient rectangle.
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
		* The height to be used for the grtadient rectangle.
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
 		* Applies the properties to the specified Graphics object.
 		* 
 		* @see mx.graphics.LinearGradientStroke
 		* 
 		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for stroke bounds. 
 		**/
		override public function apply(graphics:Graphics,rc:Rectangle):void{
			
			if (_x && _y && _width && _height) {
				if (_coordType == "relative") super.apply(graphics, new Rectangle(rc.x + x, rc.y + y, width, height));
				else if (_coordType == "ratio") super.apply(graphics, new Rectangle(rc.x + x * rc.width, rc.y + y * rc.height, width * rc.width, height * rc.height));
				else super.apply(graphics, new Rectangle(x, y, width, height));
			}
			else if (_width && _height) {
				if (_coordType == "relative") super.apply(graphics, new Rectangle(rc.x , rc.y , width, height));
				else if (_coordType == "ratio") super.apply(graphics, new Rectangle(rc.x, rc.y , width * rc.width, height * rc.height));
				else super.apply(graphics, new Rectangle(0, 0, width, height));
			}
			else{
				super.apply(graphics,rc);
			}
			
		}
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:LinearGradientStroke):void{
			
			if (!_x){_x = value.x;}
			if (!_y){_y = value.y;}
			if (!_width){_width = value.width;}
			if (!_height){_height = value.height;}
			if (!_caps){_caps = value.caps;}
			if (!_joints){_joints = value.joints;}
			if (!_miterLimit){_miterLimit = value.miterLimit;}
			if (!_pixelHinting){_pixelHinting = value.pixelHinting;}
			if (!_scaleMode){_scaleMode = value.scaleMode;}
			if (!_weight) {_weight = value.weight;}
			if (!_angle){_angle = value.angle;}
			if (!_interpolationMethod){_interpolationMethod = value.interpolationMethod;}
			if (!_gradientStops && value.gradientStops.length!=0){gradientStops = value.gradientStops};
		
		}
		
	}
}