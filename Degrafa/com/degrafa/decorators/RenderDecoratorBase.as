package com.degrafa.decorators{
	
	import flash.display.Graphics;
	
	public class RenderDecoratorBase extends DecoratorBase implements IRenderDecorator{
		public function RenderDecoratorBase(){
			super();
		}
		
		//override in sub classes.
		public function moveTo(x:Number,y:Number,graphics:Graphics):void {}
		public function lineTo(x:Number,y:Number,graphics:Graphics):void {}
		public function curveTo(cx:Number, cy:Number, x:Number, y:Number,graphics:Graphics):void {}
				
		
	}
}