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
	import flash.net.registerClassAlias;
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("RadialGradientStroke.png")]
	
	[Bindable(event="propertyChange")]
	
	/**
	* The radial gradient stroke class lets you specify a gradient stroke that 
	* radiates out from the center of a graphical element.
	* 
	* @see mx.graphics.RadialGradient 
	* @see http://samples.degrafa.com/RadialGradientStroke/RadialGradientStroke.html
	**/
	public class RadialGradientStroke extends GradientStrokeBase {
		
		public function RadialGradientStroke(){
			super();
			super.gradientType = "radial";
			
			registerClassAlias("com.degrafa.paint.RadialGradientStroke", RadialGradientStroke);
			
		}
		
		private var _cx:Number;
		/**
		* The x-axis coordinate of the center of the gradient rectangle. If not specified 
		* a default value of 0 is used.
		**/
		public function get cx():Number{
			if(!_cx){return 0;}
			return _cx;
		}
		public function set cx(value:Number):void{
			if(_cx != value){
				
				var oldValue:Number=_cx;
				
				_cx = value;
				
				//call local helper to dispatch event	
				initChange("cx",oldValue,_cx,this);
				
			}
		}
		
		
		private var _cy:Number;
		/**
		* The y-axis coordinate of the center of the gradient rectangle. If not specified 
		* a default value of 0 is used.
		**/
		public function get cy():Number{
			if(!_cy){return 0;}
			return _cy;
		}
		public function set cy(value:Number):void{
			if(_cy != value){
				
				var oldValue:Number=_cy;
				
				_cy = value;
				
				//call local helper to dispatch event	
				initChange("cy",oldValue,_cy,this);
				
			}
		}
		
		
		private var _radius:Number;
		/**
		* The radius of the gradient fill. If not specified a default value of 0 
		* is used.
		**/
		public function get radius():Number{
			if(!_radius){return 0;}
			return _radius;
		}
		public function set radius(value:Number):void{
			if(_radius != value){
				
				var oldValue:Number=_radius;
				
				_radius = value;
				
				//call local helper to dispatch event	
				initChange("radius",oldValue,_radius,this);
				
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
			
			if(_cx && _cy && _radius){
				super.apply(graphics,new Rectangle(cx-radius,cy-radius,radius*2,radius*2));
			}
			else if (_radius){
				super.apply(graphics,new Rectangle(0,0,radius*2,radius*2));
			}
			else{
				super.apply(graphics,rc);
			}
			
		}
	
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:RadialGradientStroke):void{
			
			if (!_cx){_cx = value.cx;}
			if (!_cy){_cy = value.cy;}
			if (!_radius){_radius = value.radius;}
			if (!_caps){_caps = value.caps;}
			if (!_joints){_joints = value.joints;}
			if (!_miterLimit){_miterLimit = value.miterLimit;}
			if (!_pixelHinting){_pixelHinting = value.pixelHinting;}
			if (!_scaleMode){_scaleMode = value.scaleMode;}
			if (!_weight) {_weight = value.weight;}
			
			if (!_angle){_angle = value.angle;}
			if (!_interpolationMethod){_interpolationMethod = value.interpolationMethod;}
			if (!_focalPointRatio){_focalPointRatio = value.focalPointRatio}
		
			if (!_gradientStops && value.gradientStops.length!=0){gradientStops = value.gradientStops};
		
		}
		
		
	}
}