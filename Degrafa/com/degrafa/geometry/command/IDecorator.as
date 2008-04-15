package com.degrafa.geometry.command
{
	import com.degrafa.core.collections.DegrafaCursor;
	import com.degrafa.geometry.Geometry;
	
	public interface IDecorator
	{
		function execute(stack:CommandStack):void;
	}
}