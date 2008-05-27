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
	import flash.net.registerClassAlias;

	
	[Exclude(name="centerX", kind="property")]
	[Exclude(name="centerY", kind="property")]
	[Exclude(name="registrationPoint", kind="property")]
	
	
	[Bindable] 
	/**
	* TranslateTransform translates an object in the two-dimensional space. The amount in 
	* pixels for translating the object is specified through the x and 
	* y properties. 
	**/
	public class TranslateTransform extends Transform{
		
		private var currentTranslateX:Number;
		private var currentTranslateY:Number;
		
		public function TranslateTransform(){
			super();
			
		}
		
		//setting these has no effect on TranslateTransform
		override public function get centerX():Number{return NaN;}
		override public function set centerX(value:Number):void{}
		override public function get centerY():Number{return NaN;}
		override public function set centerY(value:Number):void{}
		override public function get registrationPoint():String{return "topLeft";}
		override public function set registrationPoint(value:String):void{}
		
		
		private var _x:Number=0;
		/**
		* The value to transform along the x axis.
		**/
		public function get x():Number{
			return _x;
		}
		public function set x(value:Number):void{
			if(_x != value){
				currentTranslateX = value-_x;
				_x = value;
				invalidated = true;
			}
			else{
				currentTranslateX = NaN;
			}
		}
		
		private var _y:Number=0;
		/**
		* The value to transform along the y axis.
		**/
		public function get y():Number{
			return _y;
		}
		public function set y(value:Number):void{
			if(_y != value){
				currentTranslateY = value-_y;
				_y = value;
				invalidated = true;
			}
			else{
				currentTranslateY = NaN;
			}
		}
		
		override public function preCalculateMatrix(value:IGeometryComposition):Matrix{
			
			if(!invalidated && !currentTranslateX && !currentTranslateY){return transformMatrix;}
			
			if(currentTranslateX){
				transformMatrix.tx = currentTranslateX;
				currentTranslateX = NaN;
			}
			else{
				transformMatrix.tx =0;
			}
			
			if(currentTranslateY){
				transformMatrix.ty = currentTranslateY;
				currentTranslateY = NaN;
			}
			else{
				transformMatrix.ty =0;
			}
			
			return transformMatrix;
			
		}
		
		override public function apply(value:IGeometryComposition):void{
			
			preCalculateMatrix(value);
						
			super.apply(value);
			
		}
	
	}
	
}