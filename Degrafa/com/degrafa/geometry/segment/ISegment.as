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
package com.degrafa.geometry.segment{
	
	import com.degrafa.core.IDegrafaObject;
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	import flash.geom.Point;
	
	/**
 	* Base interface for all Degrafa segment objects.
 	**/ 	
	public interface ISegment extends IDegrafaObject{
		
		function get data():String;
		function set data(value:String):void;
		
		function get segmentType():String;
		
		function get isShortSequence():Boolean;
		function set isShortSequence(value:Boolean):void;

		function get coordinateType():String;		
		function set coordinateType(value:String):void;
		
		function get commandStackItem():CommandStackItem		
		function set commandStackItem(value:CommandStackItem):void	
		
		function computeSegment(firstPoint:Point,lastPoint:Point,lastControlPoint:Point,commandStack:CommandStack):void
		
	}
}