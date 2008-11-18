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
package com.degrafa.decorators{
	
	import flash.display.Graphics;
	
	/**
	* RenderDecoratorBase is intended to be extended for complex decorations.
	* Decorations that use a render time type manipulation extend from this base 
	* class. Extensions of this class are expected to render the actual data to the 
	* graphics context passed and as such provides the nessesary proxy methods which 
	* can be overridden.
	**/
	public class RenderDecoratorBase extends DecoratorBase implements IRenderDecorator{
		public function RenderDecoratorBase(){
			super();
		}
		
		//override in sub classes.
		/**
		*  moveTo proxy method. The graphics property is the current context being rendered to.
		*  This method is expected to be overridden by subclasses.
		**/
		public function moveTo(x:Number,y:Number,graphics:Graphics):void {}
		
		/**
		*  lineTo proxy method. The graphics property is the current context being rendered to.
		*  This method is expected to be overridden by subclasses.
		**/
		public function lineTo(x:Number,y:Number,graphics:Graphics):void {}
		
		/**
		*  curveTo proxy method. The graphics property is the current context being rendered to.
		*  This method is expected to be overridden by subclasses. 
		**/
		public function curveTo(cx:Number, cy:Number, x:Number, y:Number,graphics:Graphics):void {}
		
	}
}