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
	import com.degrafa.core.IDegrafaObject;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	* ITransform is the base interface for transform.
	**/ 
	public interface ITransform extends IDegrafaObject{		
		function get data():String;
		function set data(value:String):void;
		function get isIdentity():Boolean;
		function get transformMatrix():Matrix;
		function getRegPoint(value:IGeometryComposition):Point;
		function getTransformFor(value:IGeometryComposition):Matrix;
		function getRegPointForRectangle(rectangle:Rectangle):Point
		function get registrationPoint():String;
		function set registrationPoint(value:String):void
		//getters are always available on all subclasses
		function get scaleX():Number;
		function get scaleY():Number;
		function get x():Number;
		function get y():Number;
		function get angle():Number;
		function get skewX():Number;
		function get skewY():Number;
		
	}
}