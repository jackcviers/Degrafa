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

	import com.degrafa.transform.TransformBase;
	import flash.geom.Matrix;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("MatrixTransform.png")]
	
	[Bindable]
	/**
	* Matrix Transform creates an affine matrix transformation to manipulate the object in the 
	* two dimensional space using custom transformations not provided by the 
	* other transform classes.
	* 
	*The MatrixTransform uses the regular flash Matrix properties a,b,c,d,tx and ty [reference to go here]
	**/
	public class MatrixTransform extends TransformBase {
		
		public function MatrixTransform(){
			super();
			//this object is never invalidated, as it is simply a wrapper for a flash Matrix
			invalidated = false;
		}
		
		
		public function get a():Number
		{
			return _transformMatrix.a;
		}
		
		public function set a(value:Number):void
		{
			_transformMatrix.a = value;
		}
		
		public function get b():Number
		{
			return _transformMatrix.b;
		}
		
		public function set b(value:Number):void
		{
			_transformMatrix.b = value;
		}
		
		public function get c():Number
		{
			return _transformMatrix.c;
		}
		
		public function set c(value:Number):void
		{
			_transformMatrix.c = value;
		}
		
		public function get d():Number
		{
			return _transformMatrix.d;
		}
		
		public function set d(value:Number):void
		{
			_transformMatrix.d = value;
		}
		
		public function get tx():Number
		{
			return _transformMatrix.tx;
		}
		
		public function set tx(value:Number):void
		{
			_transformMatrix.tx = value;
		}
		
		public function get ty():Number
		{
			return _transformMatrix.ty;
		}
		
		public function set ty(value:Number):void
		{
			_transformMatrix.ty = value;
		}
		
	}
}