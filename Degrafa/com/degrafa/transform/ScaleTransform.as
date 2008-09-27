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
	import com.degrafa.transform.ITransform;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("ScaleTransform.png")]
	
	[Bindable]
	/**
	* ScaleTransform scales an object along the x-axis (scaleX) and y-axis (scaleY). 
	* The transformation scales the x-axis and y-axis values relative to the 
	* registration point defined in registration point or centerX and centerY respectivly.
	**/
	public class ScaleTransform extends TransformBase implements ITransform{
		

		
		public function ScaleTransform(){
			super();
		}
		
	

		private var uniform:Boolean = false;
		
		public function set scale(value:Number):void
		{
			if (_scaleX != value || _scaleY != value)
			{
				_scaleX = _scaleY = value;
				invalidated = true;
			}
			uniform = true;
		}
	
		public function get scale():Number
		{
			if (uniform) return _scaleX;
			return NaN;
		}
		
		public function set scaleX( value:Number):void
		{
			if (value != _scaleX)
			 {
				 _scaleX = value;
				 invalidated = true;
			}
			uniform = false;
		}
		
		public function set scaleY( value:Number):void
		{
			if (value != _scaleY)
			 {
				 _scaleY = value;
				 invalidated = true;
			}
			uniform = false;
		}
		
		
	}
}