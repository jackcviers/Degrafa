package com.degrafa.decorators
{
	import flash.display.Graphics;
	
	public interface IRenderDecorator extends IDecorator{
		
		function moveTo(x:Number,y:Number,graphics:Graphics):void
		function lineTo(x:Number,y:Number,graphics:Graphics):void
		function curveTo(cx:Number, cy:Number, x:Number, y:Number,graphics:Graphics):void
	}
}