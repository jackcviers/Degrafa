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
package com.decorations
{
	import com.degrafa.geometry.command.*;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.decorators.*
	
	public class StrokeDecorator implements IDrawDecorator
	{
		public var id:String;
		
		public function StrokeDecorator()
		{
		}

		public function execute(stack:CommandStack):void
		{
			var cursor:CommandCursor = new CommandCursor(stack.cmdSource);
			
			while(cursor.moveNextCommand(CommandStackItem.LINE_TO))
	   		{
	   			var dc:CommandStackItem = new CommandStackItem(CommandStackItem.DELEGATE_TO);
	   			dc.delegate = changeLineStyle;
	   			cursor.insert(dc);
	   			cursor.moveNext();
        	}
        	
        	cursor.moveFirst();
        	
        	while(cursor.moveNextCommand(CommandStackItem.CURVE_TO))
	   		{
	   			dc = new CommandStackItem(CommandStackItem.DELEGATE_TO);
	   			dc.delegate = changeLineStyle;
	   			cursor.insert(dc);
	   			cursor.moveNext();
        	}
		}
		
		public function changeLineStyle(stack:CommandStack):void
		{
			var stroke:SolidStroke = new SolidStroke(uint(Math.random()*100000000000), (Math.random()*.5)+.5, 10+Math.random()*30);
			//var stroke:SolidStroke = new SolidStroke("forestgreen", .8, 25);
			stroke.apply(stack.graphics,null);
		}
	}
}