package com.degrafa.geometry.command
{
	import com.degrafa.paint.SolidStroke;
	
	import flash.display.Graphics;
	
	public class StrokeDecorator implements IDecorator
	{
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
		
		public function changeLineStyle(stack:CommandStack,graphics:Graphics):void
		{
			var stroke:SolidStroke = new SolidStroke(uint(Math.random()*100000000000), (Math.random()*.5)+.5, 10+Math.random()*30);
			stroke.apply(graphics,null);
		}
	}
}