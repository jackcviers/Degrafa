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
	import com.degrafa.transform.ITransform

	

	[DefaultProperty("data")]	
	[Bindable]
	public class Transform extends TransformBase implements ITransform{
	
		
		/**
		 * A general purpose Transform. When used in isolation (i.e. not as part of a TransformGroup),
		 * settings used on this object will generate transform results similar to results from the 
		 * Flash IDE property settings for editing properties on objects on the flash Stage.
		 */
		public function Transform(){
			super();
		}
		
		
		public function set angle(value:Number):void
		{
			if (value != _angle)
			 {
				 _angle = value;
				 invalidated = true;
			}
		}
		public function set skewX(value:Number):void 
		{
			if (value != _skewX)
			 {
				 _skewX = value;
				 invalidated = true;
			}
		}
		public function set skewY(value:Number):void 
		{	
			if (value != _skewY)
			 {
				 _skewY = value;
				 invalidated = true;
			}
		}
		public function set scaleX( value:Number):void
		{
			if (value != _scaleX)
			 {
				 _scaleX = value;
				 invalidated = true;
			}
		}
		public function set scaleY( value:Number):void
		{
			if (value != _scaleY)
			 {
				 _scaleY = value;
				 invalidated = true;
			}
		}

		public function set x(value:Number):void
		{
			if (value != _tx)
			 {
				 _tx = value;
				 invalidated = true;
			}
		}
		
		public function set y(value:Number):void
		{
			if (value != _ty)
			 {
				 _ty = value;
				 invalidated = true;
			}
		}
	}
}