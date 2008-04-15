package com.degrafa.geometry.command
{
	import flash.display.Graphics;

	public class CurveToLineDecorator implements IDecorator
	{
		public function CurveToLineDecorator()
		{
			super();
		}
		
		public function execute(stack:CommandStack):void
		{
			var item:CommandStackItem;
			var cursor:CommandCursor = new CommandCursor(stack.cmdSource);
			
			while(cursor.moveNextCommand(CommandStackItem.CURVE_TO))
	   		{
	   			var dc:CommandStackItem = new CommandStackItem(CommandStackItem.DELEGATE_TO);
	   			dc.delegate = curveLineDelegate;
	   			cursor.insert(dc);
	   			cursor.moveNext();
        	}
		}
		
		public function curveLineDelegate(stack:CommandStack,graphics:Graphics):void
		{
			var cursor:CommandCursor = new CommandCursor(stack.cmdSource);
			
			if(cursor.moveNextCommand(CommandStackItem.CURVE_TO))
   			{
   				cursor.current.type = CommandStackItem.LINE_TO;
   			}
		}
	}
}