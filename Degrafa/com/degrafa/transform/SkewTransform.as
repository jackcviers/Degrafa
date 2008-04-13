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
	* SkewTransform defines a two-dimensional skew that stretches the coordinate space 
	* in a non-uniform manner. The skewX and skewY define the skew angle. 
	* The transformation skews the x-axis and y-axis values relative to the 
	* registration point defined in registration point or centerX and centerY respectivly.
	**/
	public class SkewTransform extends Transform{
				
		public function SkewTransform(){
			super();
		}
		
		private var _skewX:Number=0;
		public function get skewX():Number{
			return _skewX;
		}
		
		public function set skewX(value:Number):void{
						
			var oldSkewX:Number = _skewX;
			_skewX = value;
															
			transformMatrix.c = Math.tan(_skewX-oldSkewX);
			transformMatrix.b =0;
			
			invalidated = true;
		}
			
		private var _skewY:Number=0;
		public function get skewY():Number{
			return _skewY;
		}
		
		public function set skewY(value:Number):void{
			var oldSkewY:Number = _skewY;
			_skewY = value;
												
			transformMatrix.b =Math.tan(_skewY-oldSkewY);
			transformMatrix.c = 0;
			
			invalidated = true;
		}
		
	}
}