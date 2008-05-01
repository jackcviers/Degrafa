package com.degrafa.decorators
{
	import com.degrafa.geometry.command.*;
	
	public class CurveDecorator implements IDrawDecorator
	{
		public function CurveDecorator()
		{
		}

		public function execute(stack:CommandStack):void
		{
			var item:CommandStackItem;
			var cursor:CommandCursor = new CommandCursor(stack.cmdSource);
			
			while(cursor.moveNextCommand(CommandStackItem.CURVE_TO))
	   		{
	   			var dc:CommandStackItem = new CommandStackItem(CommandStackItem.DELEGATE_TO);
	   			dc.delegate = curveDelegate;
	   			cursor.insert(dc);
	   			cursor.moveNext();
        	}
		}
		
		public function curveDelegate(stack:CommandStack):void
		{
			var cursor:CommandCursor = new CommandCursor(stack.cmdSource);
			cursor.currentIndex = stack.cursor.currentIndex;
			
			var cmd:CommandStackItem = cursor.nextCommand(CommandStackItem.CURVE_TO);
			
			cmd.cx *= 1.5;
			cmd.cy *= 1.5;
		}
	}
}