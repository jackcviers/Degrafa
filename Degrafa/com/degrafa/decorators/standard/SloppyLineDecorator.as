package com.degrafa.decorators.standard{
	
	import com.degrafa.geometry.command.CommandStack;
	import flash.display.Graphics;
	import com.degrafa.decorators.RenderDecoratorBase;
	/**
	* Randomly perturbs the line and curve segments
 	* that make up a Geometry.
 	**/
	public class SloppyLineDecorator extends RenderDecoratorBase{
	
		public function SloppyLineDecorator(){
			super();
		}
		
		private var _sloppiness:int = 20;
		private var _startx:Number;
		private var _starty:Number;
		private var _penx:Number;
		private var _peny:Number;
		private var started:Boolean;
		private var _context:Graphics;
		
		override public function initialize(stack:CommandStack):void {
			started = false;
		}
		
		override public function end(stack:CommandStack):void {
			if (_penx == _startx && _peny == _starty) _context.lineTo(_startx, _starty);
		}
		
		//override in sub classes.
		override public function moveTo(x:Number, y:Number, graphics:Graphics):void {
			if (!started) { _startx = x; _starty = y ; _context = graphics; started = true }
			_penx = x; _peny = y;
			graphics.moveTo(_penx,_peny);
		}
		override public function lineTo(x:Number, y:Number, graphics:Graphics):void {
			if (!started) { _startx = 0; _starty = 0 ;  _context = graphics; started = true }
			_penx = x; _peny = y;
			graphics.lineTo(perturb(x),perturb(y));
		}
		override public function curveTo(cx:Number, cy:Number, x:Number, y:Number, graphics:Graphics):void {
			if (!started) { _startx = 0; _starty = 0 ;  _context = graphics; started = true }
			_penx = x; _peny = y;
			graphics.curveTo(perturb(cx),perturb(cy),perturb(x),perturb(y));
		}
		 		
	 	private function perturb(value:Number):Number{
		    return  value += ((Math.random()*2-1.0)*_sloppiness);
		}
	}
}