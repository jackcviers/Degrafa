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

package com.degrafa.transform{
	
	import com.degrafa.IGeometryComposition;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	
	[Bindable]
	/**
	* ScaleTransform scales an object along the x-axis (scaleX) and y-axis (scaleY). 
	* The transformation scales the x-axis and y-axis values relative to the 
	* registration point defined in registration point or centerX and centerY respectivly.
	**/
	public class ScaleTransform extends Transform{
		
		private var currentScaleXRatio:Number;
		private var currentScaleYRatio:Number;
		
		public function ScaleTransform(){
			super();

		}
		
		private var _scaleX:Number=1;
		public function get scaleX():Number{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void{
			if(_scaleX != value){
				currentScaleXRatio = value/_scaleX;
				_scaleX = value;
				invalidated = true;
			}
			else{
				currentScaleXRatio = NaN;
			}
		}
		
		private var _scaleY:Number=1;
		public function get scaleY():Number{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void{
			if(_scaleY != value){
				currentScaleYRatio = value/_scaleY;
				_scaleY = value;
				invalidated = true;
			}
			else{
				currentScaleYRatio = NaN;
			}
		}
		
		override public function preCalculateMatrix(value:IGeometryComposition):Matrix{
			
			if(!invalidated && !currentScaleXRatio && !currentScaleYRatio){return transformMatrix;}
			
			//store the previous matrix for inversion
			var previousMatrix:Matrix=transformMatrix.clone();
			
			var trans:Point;
			if(registrationPoint){
				trans = getRegistrationPoint(value)
			}
			else{
				trans = new Point(centerX,centerY);
			}
				
			if(currentScaleXRatio){
				transformMatrix.a *= currentScaleXRatio;
				currentScaleXRatio = NaN;
			}
			
			if(currentScaleYRatio){
				transformMatrix.d *= currentScaleYRatio;
				currentScaleYRatio = NaN;
			}
			
			//invert the previous matrix and concat the results before application
			if(previousMatrix){
				previousMatrix.invert();
				transformMatrix.concat(previousMatrix);
			}
			
			return transformMatrix;
		}
		
		override public function apply(value:IGeometryComposition):void{
			
			preCalculateMatrix(value);
		
			super.apply(value);
			
		}
		
	}
}