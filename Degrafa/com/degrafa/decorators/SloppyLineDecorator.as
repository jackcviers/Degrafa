package com.degrafa.decorators{
	
	import flash.display.Graphics;
	
	/**
	* Randomly perturbs the line and curve segments
 	* that make up a Geometry.
 	**/
	public class SloppyLineDecorator extends RenderDecoratorBase{
	
		public function SloppyLineDecorator(){
			super();
		}
		
		private var _sloppiness:int=20;
		
		//override in sub classes.
		override public function moveTo(x:Number,y:Number,graphics:Graphics):void {
			graphics.moveTo(perturb(x),perturb(y));
		}
		override public function lineTo(x:Number,y:Number,graphics:Graphics):void {
			graphics.lineTo(perturb(x),perturb(y));
		}
		override public function curveTo(cx:Number, cy:Number, x:Number, y:Number,graphics:Graphics):void {
			graphics.curveTo(perturb(cx),perturb(cy),perturb(x),perturb(y));
		}
		
		 		
	 	private function perturb(value:Number):Number{
		    return  value += ((Math.random()*2-1.0)*_sloppiness);
		}
	}
}