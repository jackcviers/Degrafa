package com.degrafa.decorators
{
	import com.degrafa.geometry.command.CommandStack;
	
	public interface IDrawDecorator
	{
		function execute(stack:CommandStack):void;
	}
}