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
	
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.geometry.command.CommandStack;
	
	
	/**
	* DecoratorBase is intended to be extended for basic decoration creation.
	* Decorations that use a delegate type manipulation extend from this base 
	* class.
	**/
	public class DecoratorBase extends DegrafaObject implements IDecorator{
		public function DecoratorBase():void{
			super();
		}
		
		//overridden in sub classes
		/**
		* Called during render setup and provides the opportunity to add 
		* item delegates or perform other initialization tasks. 
		* Decorators should use this to reset any tracking variables back to their
		* original state, as the same decorator may have been used previously
		* and there is no 'end' call at the completion of the rendering phase.
		* To be overridden in sub classes.
		**/
		public function initialize(stack:CommandStack):void{
			
			//walk the stack to add the delegates
			
		}
		
		//overridden in sub classes
		/**
		* Called at the end of the render phase for the current object.
		* Provides opportunity to perform any post-decoration tasks, including any cleanup/reset activities before next request.
		* To be overridden in sub classes.
		**/
		/**/
		public function end(stack:CommandStack):void{
			
			//perform any post-decoration tasks, including any reset activities before next request
			
		}
		
	}
}