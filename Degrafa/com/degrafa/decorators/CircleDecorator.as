package com.degrafa.decorators
{
	import com.degrafa.core.*;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.command.*;
	import com.degrafa.paint.SolidFill;

	public class CircleDecorator implements IDrawDecorator
	{
		public var radius:int = 25;
		public var fill:SolidFill = new SolidFill("blue");
		
		public function CircleDecorator()
		{
			super();
		}
		
		public function execute(stack:CommandStack):void
		{
			var cursor:CommandCursor = new CommandCursor(stack.cmdSource);
			
			while(cursor.moveNextCommand(CommandStackItem.LINE_TO))
	   		{
	   			var dc:CommandStackItem = new CommandStackItem(CommandStackItem.DELEGATE_TO);
	   			dc.delegate = addCircle;
	   			cursor.insert(dc);
	   			cursor.moveNext();
        	}
        	
        	cursor.moveFirst();
        	
        	while(cursor.moveNextCommand(CommandStackItem.CURVE_TO))
	   		{
	   			dc = new CommandStackItem(CommandStackItem.DELEGATE_TO);
	   			dc.delegate = addCircle;
	   			cursor.insert(dc);
	   			cursor.moveNext();
        	}
		}
		
		public function addCircle(stack:CommandStack):void
		{
			stack.owner.geometryCollection.suppressEventProcessing = true;
			var circle:Circle = new Circle(stack.pointer.x,stack.pointer.y,radius);
			circle.fill = IGraphicsFill(fill);
			stack.owner.geometryCollection.addItem(circle);
		}
	}
}