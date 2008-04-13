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
	* TranslateTransform translates an object in the two-dimensional space. The amount in 
	* pixels for translating the object is specified through the x and 
	* y properties. Translation is performed relative to the registration point 
	* defined via registration point or centerX and centerY respectivly.
	**/
	public class TranslateTransform extends Transform{
		
		public function TranslateTransform(){
			super();
		}
	
		private var _x:Number;
		/**
		* The value to transform along the x axis.
		**/
		public function get x():Number{
			return _x;
		}
		public function set x(value:Number):void{
			if(_x != value){
				var oldX:Number = (isNaN(_x))? 0:_x;
				_x = value;
				
				transformMatrix.tx = (isNaN(x)? 0:_x-oldX);
				transformMatrix.ty=0;
				invalidated = true;
			}
			
		}
		
		private var _y:Number;
		/**
		* The value to transform along the y axis.
		**/
		public function get y():Number{
			return _y;
		}
		public function set y(value:Number):void{
			if(_y != value){
				
				var oldY:Number = (isNaN(_y))? 0:_y;
				_y = value;
				
				transformMatrix.tx=0;
				transformMatrix.ty = (isNaN(y)? 0:_y-oldY);
				
				invalidated = true;
			}
		}
	
	}
	
}