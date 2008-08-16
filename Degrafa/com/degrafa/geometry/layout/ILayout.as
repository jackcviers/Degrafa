package com.degrafa.geometry.layout
{
	import com.degrafa.core.IDegrafaObject;
	import flash.geom.Rectangle;
	
	public interface ILayout extends IDegrafaObject{
		function computeLayoutRectangle(childBounds:Rectangle,parentBounds:Rectangle):Rectangle;
		function get layoutRectangle():Rectangle;
	}
}