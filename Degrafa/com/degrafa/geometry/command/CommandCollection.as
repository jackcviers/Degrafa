package com.degrafa.geometry.command
{
	import com.degrafa.core.collections.DegrafaCollection;

	public class CommandCollection extends DegrafaCollection
	{
		public function CommandCollection(array:Array=null)
		{
			super(CommandStackItem, array, true, false);
		}
		
	}
}