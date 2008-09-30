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
	
	import com.degrafa.transform.TransformBase

	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("RotateTransform.png")]
	
	[Bindable]
	/**
	* RotateTransform rotates an object in the two-dimensional plane by specifying an angle 
	* and a registration point defined in registration point or centerX and centerY respectivly.
	**/
	public class RotateTransform extends TransformBase  implements ITransform{
		
		
		public function RotateTransform() {
			super();
	
		}
		
		/**
		* The angle of rotation in degrees that the RotateTransform will apply to its target Geometry when rendered. Center of rotation
		* is determined by the registrationPoint (if set) or centerX and centerY property values if no registrationPoint is
		* set.
		**/
		public function set angle(value:Number):void
		{ 
			if (value != _angle)
			 {
				 _angle = value;
				
				 invalidated = true;
			}
		}
		
	}
		

}