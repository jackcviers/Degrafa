package com.degrafa.states{

	import com.degrafa.geometry.Geometry;
	
	public interface IOverride{
		function initialize():void
		function apply(parent:Geometry):void;
		function remove(parent:Geometry):void;
	}
	
}
