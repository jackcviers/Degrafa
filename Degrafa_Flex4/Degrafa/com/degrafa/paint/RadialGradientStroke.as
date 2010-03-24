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
	
	import com.degrafa.core.ITransformablePaint;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
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
		
		
		private var _radiusy:Number;
		private var _radius:Number;
		private var _ellipse:Boolean;
		/**
		* The radius of the gradient stroke, for a circular radial gradient, otherwise it represents the x radius of an elliptical radial gradient. If not specified a default value of 0 
		* is used.
		**/
		public function get radius():Number{
			if(!_radius){return 0;}
			return _radius;
		}
		public function set radius(value:Number):void{
			if(_radius != value){
				var oldValue:Number=_radius;
				
				_radiusy = _radius = value;
				_ellipse = false;
				//call local helper to dispatch event	
				initChange("radius",oldValue,_radius,this);
			}
		}
		/**
		* The x radius of the gradient stroke, before any rotation is applied, for an elliptical radial gradient. If not specified a default value of 0 
		* is used.
		**/
		public function get radiusX():Number{
			if(!_radius){return 0;}
			return _radius;
		}
		public function set radiusX(value:Number):void
		{
			if(_radius != value){
				var oldValue:Number=_radius;
				
				_radius = value;
				_ellipse = (_radius!=_radiusy);
				//call local helper to dispatch event	
				initChange("radiusX",oldValue,_radius,this);
			}
		}
		/**
		* The y radius of the gradient stroke, before any rotation is applied, for an elliptical radial gradient. If not specified a default value of 0 
		* is used.
		**/
		public function get radiusY():Number{
			if(!_radiusy){return 0;}
			return _radiusy;
		}
		public function set radiusY(value:Number):void
		{
			if(_radiusy != value){
				var oldValue:Number=_radiusy;
				
				_radiusy = value;
				_ellipse = (_radius!=_radiusy);
				//call local helper to dispatch event	
				initChange("radiusY",oldValue,_radiusy,this);
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
		override public function apply(graphics:Graphics, rc:Rectangle):void {
			var forceCircle:Number;
			if (_cx && _cy && _radius) {
				if (_coordType == "relative") super.apply(graphics, new Rectangle(rc.x + cx-radiusX, rc.y + cy-radiusY, radiusX*2, radiusY*2));
				else if (_coordType == "ratio") {
					forceCircle = _ellipse? NaN:Math.sqrt(rc.width * rc.width + rc.height * rc.height) / Math.SQRT2;
					super.apply(graphics, new Rectangle(rc.x + (cx * rc.width)-radiusX*(_ellipse?rc.width:forceCircle), rc.y + (cy * rc.height)-radiusY*(_ellipse?rc.height:forceCircle), radiusX *2* ((_ellipse? rc.width:forceCircle)), radiusY*2 * (_ellipse? rc.height:(_ellipse? rc.width:forceCircle))));
				}
				else super.apply(graphics,new Rectangle(cx-radiusX,cy-radiusY,radiusX*2,radiusY*2));
			}
			else if (_radius) {
			if (_coordType == "relative") super.apply(graphics, new Rectangle(rc.x -radiusX, rc.y -radiusY, radiusX*2, radiusY*2));
				else if (_coordType == "ratio") {
					forceCircle = _ellipse? NaN:Math.sqrt(rc.width * rc.width + rc.height * rc.height) / Math.SQRT2;
					super.apply(graphics, new Rectangle(rc.x -radiusX * (_ellipse? rc.width:forceCircle), rc.y -radiusY * (_ellipse? rc.height:forceCircle), radiusX * 2 * (_ellipse? rc.width:forceCircle), radiusY*2 * (_ellipse? rc.height:forceCircle ))); 
				}
				else super.apply(graphics,new Rectangle(0,0,radiusX*2,radiusY*2));
			}
			else {
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
			if (!_radius && !value.radiusY){_radius = value.radius; }
			if (!_radiusy) { _radiusy = value.radiusY; _ellipse = (_radiusy != _radius); }
			if (!_caps){_caps = value.caps;}
			if (!_joints){_joints = value.joints;}
			if (!_miterLimit){_miterLimit = value.miterLimit;}
			if (!_pixelHinting){_pixelHinting = value.pixelHinting;}
			if (!_scaleMode){_scaleMode = value.scaleMode;}
			if (!_weight) {_weight = value.weight;}
			
			if (!_angle){_angle = value.angle;}
			if (!_interpolationMethod){_interpolationMethod = value.interpolationMethod;}
			if (!_focalPointRatio){_focalPointRatio = value.focalPointRatio}
		
			if (!_gradientStops && value.gradientStops.length != 0) { gradientStops = value.gradientStops };
			if (!_degrafaScaling) {_degrafaScaling = value.degrafaScaling?1:-1}
		
		}
		
		
	}
}