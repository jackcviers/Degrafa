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
	
	[Bindable]
	/**
	* SkewTransform defines a two-dimensional skew that stretches the coordinate space 
	* in a non-uniform manner. The skewX and skewY define the skew angle. 
	* The transformation skews the x-axis and y-axis values relative to the 
	* registration point defined in registration point or centerX and centerY respectivly.
	**/
	public class SkewTransform extends Transform{
		
		private var currentSkewAngleX:Number;
		private var currentSkewAngleY:Number;
				
		public function SkewTransform(){
			super();
		}
		
		private var _skewAngleX:Number=0;
		public function get skewAngleX():Number{
			return _skewAngleX;
		}
		
		public function set skewAngleX(value:Number):void{
			if(_skewAngleX != value){
				currentSkewAngleX = ((value-_skewAngleX)/180)* Math.PI;
				_skewAngleX = value;
				invalidated = true;
			}
			else{
				currentSkewAngleX = NaN;
			}
		}
			
		private var _skewAngleY:Number=0;
		public function get skewAngleY():Number{
			return _skewAngleY;
		}
		
		public function set skewAngleY(value:Number):void{
			if(_skewAngleY != value){
				currentSkewAngleY = ((value-_skewAngleY)/180)* Math.PI;
				_skewAngleY = value;
				invalidated = true;
			}
			else{
				currentSkewAngleY = NaN;
			}
		}
		
		override public function preCalculateMatrix(value:IGeometryComposition):Matrix{
			
			if(!invalidated && !currentSkewAngleX && !currentSkewAngleY){return transformMatrix;}
			
			if(currentSkewAngleX){
				transformMatrix.c = currentSkewAngleX;
				currentSkewAngleX = NaN;
			}
			else{
				transformMatrix.c =0;
			}
		
			if(currentSkewAngleY){
				transformMatrix.b = currentSkewAngleY;
				currentSkewAngleY = NaN;
			}
			else{
				transformMatrix.b =0;
			}
			
			return 	transformMatrix;
		}
		
		override public function apply(value:IGeometryComposition):void{
			
			preCalculateMatrix(value);
									
			super.apply(value);
		}
		
	}
}