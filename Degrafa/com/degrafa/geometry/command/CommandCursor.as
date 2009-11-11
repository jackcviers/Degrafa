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
package com.degrafa.geometry.command
{
	import com.degrafa.core.collections.DegrafaCursor;

	public class CommandCursor extends DegrafaCursor
	{
		public function CommandCursor(source:Array)
		{
			super(source);
		}
		
		public function nextCommand(type:int):CommandStackItem
		{
			var tempIndex:int = currentIndex;
			var found:Object;
			
			while(moveNext())
			{
				if(current.type == type)
				{
					found = current;
					break;
				}
			}
			
			currentIndex = tempIndex;
			return CommandStackItem(found);
		}
		
		public function previousCommand(type:String):CommandStackItem
		{
			var tempIndex:int = currentIndex;
			var found:Object;
			
			while(movePrevious())
			{
				if(current.type == type)
				{
					found = current;
					break;
				}
			}
			
			currentIndex = tempIndex;
			return CommandStackItem(found);
		}
		
		public function moveNextCommand(type:int):Boolean
		{
			while(moveNext())
			{
				if(current.type == type)
					return true;
			}
			return false;
		}
		
		public function movePreviousCommand(type:int):Boolean
		{
			while(movePrevious())
			{
				if(current.type == type)
					return true;
			}
			return false;
		}
	}
}