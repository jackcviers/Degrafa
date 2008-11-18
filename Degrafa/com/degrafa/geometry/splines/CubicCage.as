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
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net) and 
// ported by the Degrafa team.
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.splines{
	 
	import flash.display.Graphics;
  	import flash.display.Shape;
	
	/**
	* Helper class used by various spline Geometry.
	**/
  	public class CubicCage{
  		
    	// properties
    	public var P0X:Number;
    	public var P1X:Number;
    	public var P2X:Number;
    	public var P3X:Number;
    	public var P0Y:Number;
    	public var P1Y:Number;
    	public var P2Y:Number;
    	public var P3Y:Number;

    	public function CubicCage(){
      		init();
    	}
  
	    public function init():void{
	    	P0X = 0;
	      	P1X = 0;
	      	P2X = 0;
	      	P3X = 0;
	      	P0Y = 0;
	      	P1Y = 0;
	      	P2Y = 0;
	      	P3Y = 0;
	    }

    	public function draw(_s:Shape, _c:Number):void{
    		var g:Graphics = _s.graphics;
      		g.lineStyle(0, _c, 100);
      		g.moveTo(P0X, P0Y);
      		g.lineTo(P1X, P1Y);
      		g.lineTo(P2X, P2Y);
      		g.lineTo(P3X, P3Y);
    	}
	}
}