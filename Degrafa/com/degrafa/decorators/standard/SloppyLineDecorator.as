////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 The Degrafa Team : http://www.Degrafa.com/team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//
////////////////////////////////////////////////////////////////////////////////
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