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
		
		public function previousCommand(type:int):CommandStackItem
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