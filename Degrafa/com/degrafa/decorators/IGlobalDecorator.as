package com.degrafa.decorators
{
	import com.degrafa.geometry.Geometry;
	
	public interface IGlobalDecorator
	{
		function execute(parent:Geometry):void
		function cleanup():void
	}
}