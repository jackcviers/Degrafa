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
	
	[IconFile("TranslateTransform.png")]
	
	[Exclude(name="centerX", kind="property")]
	[Exclude(name="centerY", kind="property")]
	[Exclude(name="registrationPoint", kind="property")]
	
	
	[Bindable] 
	/**
	* TranslateTransform translates an object in the two-dimensional space. The amount in 
	* pixels for translating the object is specified through the x and 
	* y properties. 
	**/
	public class TranslateTransform extends TransformBase implements ITransform{
		

		public function TranslateTransform(){
			super();
			//set registration Point topLeft. Its irrelevant to Translate, but does need to be defined 
		}
		
		//setting these has no effect on TranslateTransform
	//	override public function get centerX():Number{return NaN;}
		override public function set centerX(value:Number):void{}
	//	override public function get centerY():Number{return NaN;}
		override public function set centerY(value:Number):void{}
	//	override public function get registrationPoint():String{return "topLeft";}
		override public function set registrationPoint(value:String):void{}
		
		

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