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
	import com.degrafa.core.collections.GradientStopsCollection;
	import com.degrafa.core.ITransformablePaint;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.IGeometryComposition;
	import com.degrafa.transform.ITransform;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import mx.events.PropertyChangeEvent;
	
	[DefaultProperty("gradientStops")]
	
	[Bindable(event="propertyChange")]
	/**
	* The gradient fill class lets you specify a gradient fill. 
	* This is the base class for other gradient fill types.
	* 
	* @see http://degrafa.com/samples/LinearGradientFill.html	  
	**/
	public class GradientFillBase extends DegrafaObject implements ITransformablePaint{
					
		//these are setup in processEntries
		protected var _colors:Array = [];
		protected var _ratios:Array = [];
		protected var _alphas:Array = [];
		
		//**************************************
		// Public Properties
		//**************************************
		
		protected var _gradientStops:GradientStopsCollection;
	    [Inspectable(category="General", arrayType="com.degrafa.paint.GradientStop")]
	    [ArrayElementType("com.degrafa.paint.GradientStop")]
	    /**
		* A array of gradient stops that describe this gradient.
		**/
		public function get gradientStops():Array{
			initGradientStopsCollection();
			return _gradientStops.items;
		}
		public function set gradientStops(value:Array):void{
			initGradientStopsCollection();
			_gradientStops.items = value;
		}
		
		/**
		* Access to the Degrafa gradient stop collection object for this gradient.
		**/
		public function get gradientStopsCollection():GradientStopsCollection{
			initGradientStopsCollection();
			return _gradientStops;
		}
		
		/**
		* Initialize the gradient stop collection by creating it and adding an event listener.
		**/
		private function initGradientStopsCollection():void{
			if(!_gradientStops){
				_gradientStops = new GradientStopsCollection();
				
				//add a listener to the collection
				if(enableEvents){
					_gradientStops.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		/**
		* Principle event handler for any property changes to a 
		* gradient stop or it's child objects.
		**/
		private function propertyChangeHandler(event:PropertyChangeEvent):void{
			dispatchEvent(event);
		}
		
		protected var _angle:Number;
		[Inspectable(category="General")]
		/**
		* The angle that defines a transition across the context.
		* 
		* @see mx.graphics.LinearGradient 
		**/
		public function get angle():Number{
			if(!_angle){return 0;}
			return _angle;
		}
		public function set angle(value:Number):void{
			if(_angle != value){
				var oldValue:Number=_angle;
				_angle = value;
				//call local helper to dispatch event	
				initChange("angle",oldValue,_angle,this);
			}
			
		}
		
		protected var _interpolationMethod:String;
		[Inspectable(category="General", enumeration="rgb,linearRGB", defaultValue="rgb")]
		/**
		* A value from the InterpolationMethod class that specifies which interpolation method to use.
		* 
		* @see mx.graphics.LinearGradient 
		**/
		public function get interpolationMethod():String{
			if(!_interpolationMethod){return "rgb";}
			return _interpolationMethod;
		}
		public function set interpolationMethod(value:String):void{			
			if(_interpolationMethod != value){
				var oldValue:String=_interpolationMethod;
				_interpolationMethod = value;
				//call local helper to dispatch event	
				initChange("interpolationMethod",oldValue,_interpolationMethod,this);
			}
		}
		
		protected var _spreadMethod:String;
		[Inspectable(category="General", enumeration="pad,reflect,repeat", defaultValue="pad")]
		/**
		* A value from the SpreadMethod class that specifies which spread method to use.
		* 
		* @see mx.graphics.LinearGradient 
		**/
		public function get spreadMethod():String {
			if(!_spreadMethod){return "pad";}
			return _spreadMethod;
		}
		public function set spreadMethod(value:String):void{			
			if(_spreadMethod != value){
				var oldValue:String=_spreadMethod;
				_spreadMethod = value;
				//call local helper to dispatch event	
				initChange("spreadMethod",oldValue,_spreadMethod,this);
			}
		}
		
		//**************************************
		// IBlend Implementation
		//**************************************
		protected var _blendMode:String;
		public function get blendMode():String { 
			if(!_blendMode){return null;}
			return _blendMode; 
		}
		public function set blendMode(value:String):void {
			if(_blendMode != value) {
				initChange("blendMode", _blendMode, _blendMode = value, this);
			}
		}
				
		protected var _gradientType:String;		
		[Inspectable(category="General", enumeration="linear,radial", defaultValue="linear")]
		/**
		* Sets the type of gradient to be applied.
		**/
		public function get gradientType():String{
			if(!_gradientType){return "linear";}
			return _gradientType;
		}
		public function set gradientType(value:String):void{
			if(_gradientType != value){
				var oldValue:String=_gradientType;
			
				_gradientType = value;
			
				//call local helper to dispatch event	
				initChange("gradientType",oldValue,_gradientType,this);
			}
			
		}
		
		protected var _focalPointRatio:Number;
		[Inspectable(category="General")]
		/**
		* Sets the location of the start of a radial fill.
		* 
		* @see mx.graphics.RadialGradient 
		**/
		public function get focalPointRatio():Number{
			if(!_focalPointRatio){return 0;}
			return _focalPointRatio;
		}
		public function set focalPointRatio(value:Number):void{			
			if(_focalPointRatio != value){
				var oldValue:Number=_focalPointRatio;
			
				_focalPointRatio = value;
			
				//call local helper to dispatch event	
				initChange("focalPointRatio",oldValue,_focalPointRatio,this);
			}
			
		}
	
		protected var _coordType:String = "absolute";
		/**
		* Coordinate type to be used for fill bounds, either absolute, or relative to target bounds, or as a ratio to target bounds.
		**/
		[Inspectable(category="General", enumeration="absolute,relative,ratio", defaultValue="absolute")]
		public function set coordinateType(value:String):void
		{
			if (value!=_coordType) 
			{
				//call local helper to dispatch event	
				initChange("coordinateType",_coordType,_coordType = value,this);
			}
		}
		public function get coordinateType():String{
			return _coordType;
		}
		
		
		//reference to the requesting geometry
		protected var _requester:IGeometryComposition;
		public function set requester(value:IGeometryComposition):void
		{
			_requester = value;
		}
		
		private var _lastRect:Rectangle;
		/**
		 * Provides access to the last rectangle that was relevant for this fill.
		 */
		public function get lastRectangle():Rectangle {
			return _lastRect.clone();
		}
		private var _lastContext:Graphics;
		private var _lastArgs:Array = [];
		/**
		 * Provide access to the lastArgs array
		 */
		public function get lastArgs():Array {
			return _lastArgs;
		}
		
		/**
		 * Provides quick access to a cached function for restarting the last used fill either in the last used context, or, if a context is provided as an argument,
		 * then to an alternate context. If no last used context is available then this will do nothing;
		 */
		public function get restartFunction():Function {
			var copy:Array = _lastArgs.concat();
			var last:Graphics = _lastContext;
		if (!_lastContext) {
			
			return function(alternate:Graphics = null):void { 
				//if (alternate) alternate.beginGradientFill(alternate, copy);
			}
			}
		else {
			return function(alternate:Graphics = null):void {
					if (alternate) alternate.beginGradientFill.apply(alternate, copy);
					else last.beginGradientFill.apply(last,copy);
				}
			}
		}
		/**
		* Begins the fill for the graphics context.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds.  
		**/
		public function begin(graphics:Graphics, rc:Rectangle):void{
			var matrix:Matrix;

			//ensure that all defaults are in fact set these are temp until fully tested
			if(!_angle){_angle=0;}
			if(!_focalPointRatio){_focalPointRatio=0;}
			if(!_spreadMethod){_spreadMethod="pad";}
			if(!_interpolationMethod){_interpolationMethod="rgb";}
			matrix=new Matrix();			
			if (rc)
			{				
				
				matrix.createGradientBox(rc.width, rc.height,
				(_angle/180)*Math.PI, rc.x, rc.y);
				var xp:Number = (angle % 90)/90;
				var yp:Number = 1 - xp;
				processEntries(rc.width * xp + rc.height * yp);
				
			}
			//handle layout transforms 
			if (_requester && (_requester as Geometry).hasLayout) {
					var geom:Geometry = _requester as Geometry;
					if (geom._layoutMatrix) matrix.concat( geom._layoutMatrix);
				}
			
			if (_transform && ! _transform.isIdentity) {
					var regPoint:Point;
					var tempmat:Matrix = new Matrix();
					regPoint = _transform.getRegPointForRectangle(rc);
					tempmat.translate(-regPoint.x,-regPoint.y);
					tempmat.concat(_transform.transformMatrix);
					tempmat.translate( regPoint.x,regPoint.y);
					matrix.concat(tempmat);
				}
				
			var transformRequest:ITransform;
			if (_requester && ((transformRequest  = (_requester as Geometry).transform) || (_requester as Geometry).transformContext)) {
				if (transformRequest) matrix.concat(transformRequest.getTransformFor(_requester));
				else matrix.concat((_requester as Geometry).transformContext);
				//remove the requester reference
				_requester = null;
			}
			_lastArgs.length = 0;
			_lastArgs[0] = gradientType;
			_lastArgs[1] = _colors;
			_lastArgs[2] = _alphas;
			_lastArgs[3] = _ratios;
			_lastArgs[4] = matrix;
			_lastArgs[5] = spreadMethod;
			_lastArgs[6] = interpolationMethod;
			_lastArgs[7] = focalPointRatio;
			_lastContext = graphics;
			_lastRect = rc;
			graphics.beginGradientFill(gradientType,_colors,_alphas,_ratios,matrix,spreadMethod,interpolationMethod,focalPointRatio);
					
		}
		
		/**
		* Ends the fill for the graphics context.
		* 
		* @param graphics The current context being drawn to.
		**/
		public function end(graphics:Graphics):void{
			graphics.endFill();
		}
		
		protected var _transform:ITransform;
		/**
		* Defines the transform object that will be used for 
		* altering this gradientfill object.
		**/
		public function get transform():ITransform{
			return _transform;
		}
		public function set transform(value:ITransform):void{
			
			if(_transform != value){
			
				var oldValue:Object=_transform;
			
				if(_transform){
					if(_transform.hasEventManager){
						_transform.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
					}
				}
								
				_transform = value;
				
				if(enableEvents){	
					_transform.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler,false,0,true);
				}
				//call local helper to dispatch event
				initChange("transform",oldValue,_transform,this);
			}
			
		}
		
		
		
		/**
		* Process the gradient stops 
		**/
		protected function processEntries(length:Number):void{
			_colors = [];
			_ratios = [];
			_alphas = [];
			
			if (!_gradientStops || _gradientStops.items.length == 0){return;}
			
			var ratioConvert:Number = 255;
			
			var i:int;
			
			var n:int = _gradientStops.items.length;
			for (i = 0; i < n; i++) {
				var e:GradientStop = _gradientStops.items[i];
				_colors.push(e.color);
				_alphas.push(e.alpha);
				if(e.measure != null && e.measure.value >= 0) {
					var ratio:Number = e.measure.relativeTo(length)/length;
					_ratios.push(Math.min(ratio, 1) * ratioConvert);
				} else {
					_ratios.push(NaN);
				}
			}
			
			if (isNaN(_ratios[0]))
				_ratios[0] = 0;
				
			if (isNaN(_ratios[n - 1]))
				_ratios[n - 1] = 255;
			
			i = 1;
			
			while (true) {
				while (i < n && !isNaN(_ratios[i])) {
					i++;
				}
				
				if (i == n)
					break;
				
				var start:int = i - 1;
				
				while (i < n && isNaN(_ratios[i])) {
					i++;
				}
				
				var br:Number = _ratios[start];
				var tr:Number = _ratios[i];
				
				for (var j:int = 1; j < i - start; j++) {
					_ratios[j] = br + j * (tr - br) / (i - start);
				}
			}
		}
		
	}
}