////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 Jason Hawryluk, Juan Sanchez, Andy McIntosh, Ben Stucki, 
// Pavan Podila, Sean Chatman, Greg Dove and Thomas Gonzalez.
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

package com.degrafa.transform{
	
	import com.degrafa.IGeometryComposition;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	[Bindable]
	/**
	* ScaleTransform scales an object along the x-axis (scaleX) and y-axis (scaleY). 
	* The transformation scales the x-axis and y-axis values relative to the 
	* registration point defined in registration point or centerX and centerY respectivly.
	**/
	public class ScaleTransform extends Transform{
		
		//store the previous matrix for inversion
		private var previousMatrix:Matrix;
		
		public function ScaleTransform(){
			super();
		}
		
		private var _scaleX:Number=1;
		public function get scaleX():Number{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void{
			
			//less than 0 is not allowed i think that .001 is finite enough
			if(value<0){value=.001};
			
			var oldScaleX:Number = _scaleX;
			_scaleX = value;
			var ratio:Number = value /oldScaleX;
						
			//store the old matrix before changes 
			previousMatrix =transformMatrix.clone();
			 
			transformMatrix.a *= ratio;
			
			invalidated = true;
			
		}
			
		private var _scaleY:Number=1;
		public function get scaleY():Number{
			return _scaleY;
		}
		public function set scaleY(value:Number):void{
		
			//less than 0 is not allowed i think that .001 is finite enough
			if(value<0){value=.001};
		
			var oldScaleY:Number = _scaleY;
			_scaleY = value;
						
			var ratio:Number = value /oldScaleY;
			
			//store the old matrix before changes 
			previousMatrix =transformMatrix.clone();
						
			transformMatrix.d *= ratio;
			
			invalidated = true;
			
		}
		
		override public function apply(value:IGeometryComposition):void{
			
			//invert the previous matrix and concat the results before application
			if(previousMatrix){
				previousMatrix.invert();
				transformMatrix.concat(previousMatrix);
			}
		
			super.apply(value);
			
		}
		
	}
}