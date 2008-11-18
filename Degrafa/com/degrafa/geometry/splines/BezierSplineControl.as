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
	
	import com.degrafa.geometry.splines.math.*;
	import flash.display.Shape;
  
  	/**
	* Helper class used by various spline Geometry.
	**/
  	public class BezierSplineControl{
  		
	  	// properties
	  	public var CLOSED:Boolean;     // true if closed spline
	  	
	    // core
	    private var _bXNR:Number;     // bisector 'right' normal, x-coordinate
	    private var _bYNR:Number;     // bisector 'right' normal, y-coordinate
	    private var _bXNL:Number;     // bisector 'left' normal, x-coordinate
	    private var _bYNL:Number;     // bisector 'left' normal, y-coordinate
	    private var _pX:Number;       // reflected point, x-coordinate
	    private var _pY:Number;       // reflected point, y-coordinate
	
	    private var _dX1:Number;      // delta-x, first segment
	    private var _dY1:Number;      // delta-y, first segment
	    private var _dX2:Number;      // delta-x, second segment
	    private var _dY2:Number;      // delta-y, second segment
	    private var _d1:Number;       // first segment length
	    private var _d2:Number;       // second segment length
	    private var _tension:Number;  // tension parameter (1-5)
	    private var _uX:Number;       // unit vector, direction of bisector, x-coordinate
	    private var _uY:Number;       // unit vector, direction of bisector, y-coordinate
	    private var _dist:Number;     // distance measure from segment intersection, along direction of bisector
	
	    private var _cage:Array;      // CubicCage instances for each segment
	    private var _points:Array;    // knots
	    private var _numPoints:uint;  // number of knots
	    private var _tensionMap:Array // map user-specified tension value (1-5) into fraction of segment distance (0.1-0.4)
	
	    public function BezierSplineControl(){
	    	CLOSED = false;
      
      		_points = new Array();
	      	_cage = new Array();
	      	_tensionMap = new Array();
	
	      	_bXNR = 0;
	      	_bYNR = 0;
	      	_bXNL = 0;
	      	_bYNL = 0;
	      	_pX = 0;
	      	_pY = 0;
	
	      	_dX1 = 0;
	     	_dY1 = 0;
	      	_dX2 = 0;
	      	_dY2 = 0;
	      	_d1 = 0;
	      	_d2 = 0;
	
	      	_uX = 0;
	      	_uY = 0;
	      	_dist = 0;
	
	      	_tension = 1;
	      	_numPoints = 0;

	      	// These are arbitrary, so experiment and have fun.  Don't go over 0.5 or very bad things will
	      	// happen.  Do you know why?  Less than 0.1 is kind of useless as you might as well just connect
	      	// the knots with lines and be done with it :)  0.3 is pretty good 'middle' ground.  Low values
	      	// have low tension and the tension increases as the index increases.  Lower tension increases
	      	// the probability of 'ripples'.
	      	_tensionMap[0] = 0.4;
	      	_tensionMap[1] = 0.3;
	      	_tensionMap[2] = 0.25;
	      	_tensionMap[3] = 0.175;
	      	_tensionMap[4] = 0.1;
		}

		public function get tension():Number{ 
			return _tension; 
		}

	    public function set knots(_a:Array):void{
	    	// Sets reference only; does not copy knots.  Only needs to be set once, 
	      	//then construct() can be called after changes to the original knot set
	      	_points = _a;
	    }
	
	    public function set tension(_t:Number):void{
	    	var n:Number = Math.round(_t);
	      	if( n > 0 && n < 6 )
	        	_tension = _t-1;
	    }
	
		/**
		* @description 	Method: getCage(_i:Number) - draw the control cages
		*
		* @param _i:Number - Control-cage index (i-th segment, not i-th knot), zero based
		* @return Nothing
		*
		* @since 1.0
		*
		* Note:  No out-of-range checking, caveat receptor!
		*/
	    public function getCage(_i:Number):CubicCage{
	    	return _cage[_i];
	    }
	
		/**
		* @description 	Method: construct() - construct all control cages based on current knot set
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	    public function construct():void{
	    	var count:uint = _points.length-1;
	      	_numPoints    = _points.length;
	      
	      	if( count < 2 )
	        	return;      // safety valve
	
	      	for( var i:uint=0; i<count; ++i ){
	        	if( _cage[i] == undefined )
	          	_cage[i] = new CubicCage();
	      	}
	
		    // Hint:  How could you insert extra knots at each end (like Catmull-Rom splines) in a manner such that
		    // the bisector normal computations produced the same set of points as the reflection computations.
		    // It would be a bit quicker and you could compress the following code structure into one method.  It's
		    // also easier than you might think ... so think about it!
		    var t:Number = _tensionMap[_tension];
	
	      	// Exercise:  Consolidate some of the common computations among the following methods.
	
	      	if( CLOSED )
	        	_leftClosed(t);  // 'leftmost' cage, closed spline
	      	else
	        	_left(t);        // 'leftmost' cage, open spline (requires a reflection point)
	
	      	// 'middle' cages
	      	for( var j:uint=1; j<count-1; ++j )
	        	_cageCoef(j, t);
	
	      	if( CLOSED )
	        	_rightClosed(t);  // 'rightmost' cage, closed spline
	      	else
	        	_right(t);        // 'rightmost' cage, open splne (requires a reflection point)
		}
	
		/**
		* @description 	Method: draw(_s:Shape, _c:Number) - draw the control cages
		*
		* @param _s:Shape  - reference to Shape in which control cages are drawn
		* @param _c:Number - hex color code for lines
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	    public function draw(_s:Shape, _c:Number):void{
	    	for( var i:uint=0; i<_cage.length; ++i )
	        	_cage[i].draw(_s, _c);
	    }
	
	    // compute 'middle' control cages
	    private function _cageCoef(_i:uint, _t:Number):void{
	    	_getNormals(_i);
	      
	      	var coef:CubicCage = _cage[_i];
	      	coef.P0X = _points[_i].x;
	      	coef.P0Y = _points[_i].y;
	      	coef.P1X = _bXNL;
	      	coef.P1Y = _bYNL;
	
	      	if( _dist > Consts.ZERO_TOL ){
	        	if( _isClockWise(_points, _i) )
	          		_CW(_i, _t);
	        	else
	          		_CCW(_i, _t);
	      	}
	      	else{
	        	_bXNR = _points[_i].x + _t*_dX1;
	        	_bYNR = _points[_i].y + _t*_dY1;
	
	        	_bXNL = _points[_i].x + _t*_dX2;
	        	_bYNL = _points[_i].y + _t*_dY2;
	      	}
	
	      	coef.P2X = _bXNR;
	      	coef.P2Y = _bYNR;
	      	coef.P3X = _points[_i+1].x;
	      	coef.P3Y = _points[_i+1].y;
	    }
	    
	    private function _getNormals(_i:uint):void{
	    	_dX1 = _points[_i].x - _points[_i+1].x;
	      	_dY1 = _points[_i].y - _points[_i+1].y;
	      	_d1 = Math.sqrt(_dX1*_dX1 + _dY1*_dY1);
	      	_dX1 /= _d1;
	      	_dY1 /= _d1;
	
	      	_dX2 = _points[_i+2].x - _points[_i+1].x;
	      	_dY2 = _points[_i+2].y - _points[_i+1].y;
	      	_d2 = Math.sqrt(_dX2*_dX2 + _dY2*_dY2);
	      	_dX2 /= _d2;
	      	_dY2 /= _d2;
	
	      	_uX = _dX1 + _dX2;
	      	_uY = _dY1 + _dY2;
	      	_dist = Math.sqrt(_uX*_uX + _uY*_uY);
	      	_uX /= _dist; 
	      	_uY /= _dist;	
	    }
	
	    // 'leftmost' control cage, open spline
	    private function _left(_t:Number):void{
	    	_getNormals(0);
	
	      	if( _dist > Consts.ZERO_TOL ){
	        	if( _isClockWise(_points, 0) )
	          		_CW(0, _t);
	        	else
	          		_CCW(0, _t);
	
		        var mX:Number = 0.5*(_points[0].x + _points[1].x);
		        var mY:Number = 0.5*(_points[0].y + _points[1].y);
		        var pX:Number = _points[0].x - mX;
		        var pY:Number = _points[0].y - mY;
		
		        // normal at midpoint
		        var n:Number  = 2.0/_d1;
		        var nX:Number = -n*pY;
		        var nY:Number = n*pX;
		
		        // upper triangle of symmetric transform matrix
		        var a11:Number = nX*nX - nY*nY
		        var a12:Number = 2*nX*nY;
		        var a22:Number = nY*nY - nX*nX;
		
		        var dX:Number = _bXNR - mX;
		        var dY:Number = _bYNR - mY;
		
		        // coordinates of reflected vector
		        _pX = mX + a11*dX + a12*dY;
		        _pY = mY + a12*dX + a22*dY;
	      	}
	      	else{
		        _bXNR = _points[1].x + _t*_dX1;
		        _bYNR = _points[1].y + _t*_dY1;
		
		        _bXNL = _points[1].x + _t*_dX2;
		        _bYNL = _points[1].y + _t*_dY2;
		
		        _pX = _points[0].x + _t*_dX1;
		        _pY = _points[0].y + _t*_dY1;
	      	}
	          
	      	var coef:CubicCage = _cage[0];
	
	      	coef.P0X = _points[0].x;
	      	coef.P0Y = _points[0].y;
	      	coef.P1X = _pX;
	      	coef.P1Y = _pY;
	      	coef.P2X = _bXNR;
	      	coef.P2Y = _bYNR;
	      	coef.P3X = _points[1].x;
	      	coef.P3Y = _points[1].y;
		}
	
	    // 'leftmost' control cage, closed spline
	    private function _leftClosed(_t:Number):void{
	    	// point order is n-2, 0, 1 (as 0 and n-1 are the same knot in a closed spline).  Use 'right normal' to set first two control cage points
	      	var n2:uint = _numPoints-2;
	      
	      	// Exercise - modify the argument list for _getNormals() to work with the following computations
	      	_dX1  = _points[n2].x - _points[0].x;
	      	_dY1  = _points[n2].y - _points[0].y;
	      	_d1   = Math.sqrt(_dX1*_dX1 + _dY1*_dY1);
	      	_dX1 /= _d1;
	      	_dY1 /= _d1;
	
	      	_dX2  = _points[1].x - _points[0].x;
	      	_dY2  = _points[1].y - _points[0].y;
	      	_d2   = Math.sqrt(_dX2*_dX2 + _dY2*_dY2);
	      	_dX2 /= _d2;
	      	_dY2 /= _d2;
	
	      	_uX   = _dX1 + _dX2;
	      	_uY   = _dY1 + _dY2;
	      	_dist = Math.sqrt(_uX*_uX + _uY*_uY);
	      	_uX  /= _dist; 
	      	_uY  /= _dist;
	
			if( _dist > Consts.ZERO_TOL ){
				if( ((_points[1].y-_points[n2].y)*(_points[0].x-_points[n2].x) > (_points[0].y-_points[n2].y)*(_points[1].x-_points[n2].x))){
			       	var dt:Number = _t*_d2;
			       	_bXNL = _points[0].x + dt*_uY;
			       	_bYNL = _points[0].y - dt*_uX;
			    }
			    else{
			       	dt = _t*_d2;
			       	_bXNL = _points[0].x - dt*_uY;
			       	_bYNL = _points[0].y + dt*_uX;
			    }
			}
		    else{
		    	_bXNL = _points[0].x + _t*_dX1;
		        _bYNL = _points[0].y + _t*_dY1;
		    }
	      
	      	var coef:CubicCage = _cage[0];
	      	coef.P0X = _points[0].x;
	      	coef.P0Y = _points[0].y;
	      	coef.P1X = _bXNL;
	      	coef.P1Y = _bYNL;
	      
	      	// now, continue as before using the point order 0, 1, 2
	      	_getNormals(0);
	
			if( _dist > Consts.ZERO_TOL ){
				if( _isClockWise(_points, 0))
	        		_CW(0, _t);
	        	else
	          	_CCW(0, _t);
	      	}
	      	else{
	        	_bXNR = _points[1].x + _t*_dX1;
	        	_bYNR = _points[1].y + _t*_dY1;
	
	        	_bXNL = _points[1].x + _t*_dX2;
	        	_bYNL = _points[1].y + _t*_dY2;
	      	}
	      
	      	coef.P2X = _bXNR;
	      	coef.P2Y = _bYNR;
	      	coef.P3X = _points[1].x;
	      	coef.P3Y = _points[1].y;
	    }
	
	    // 'rightmost' control cage, open spline
	    private function _right(_t:Number):void{
	    	var count:Number = _points.length-1;
	      	if( _dist > Consts.ZERO_TOL ){ 
	        	var mX:Number = 0.5*(_points[count-1].x + _points[count].x);
	        	var mY:Number = 0.5*(_points[count-1].y + _points[count].y);
	        	var pX:Number = _points[count].x - mX;
	        	var pY:Number = _points[count].y - mY;
	
		        // normal at midpoint
		        var n:Number  = 2.0/_d2;
		        var nX:Number = -n*pY;
		        var nY:Number = n*pX;
		
		        // upper triangle of symmetric transform matrix
		        var a11:Number = nX*nX - nY*nY
		        var a12:Number = 2*nX*nY;
		        var a22:Number = nY*nY - nX*nX;
		
		        var dX:Number = _bXNL - mX;
		        var dY:Number = _bYNL - mY;
		
		        // coordinates of reflected vector
		        _pX = mX + a11*dX + a12*dY;
		        _pY = mY + a12*dX + a22*dY;
	      	}
	      	else{
	        	_pX = _points[count].x - _t*_dX2;
	        	_pY = _points[count].y - _t*_dY2;
	      	}
	
		    var coef:CubicCage = _cage[count-1];
		
		    coef.P0X = _points[count-1].x;
		    coef.P0Y = _points[count-1].y;
		    coef.P1X = _bXNL;
		    coef.P1Y = _bYNL;
		    coef.P2X = _pX;
		    coef.P2Y = _pY;
		    coef.P3X = _points[count].x;
		    coef.P3Y = _points[count].y;
	    }
	    
	    // 'rightmost' control cage, closed spline
	    private function _rightClosed(_t:Number):void{
	    	// no additional computations are required as the P2X, P2Y point is a reflection of the P1X, P1Y point from the very first control cage
	      	var count:Number = _numPoints-1;
	
	      	var c0:CubicCage   = _cage[0];
	      	var coef:CubicCage = _cage[count-1];
	
	      	coef.P0X = _points[count-1].x;
	      	coef.P0Y = _points[count-1].y;
	      	coef.P1X = _bXNL;
	      	coef.P1Y = _bYNL;
	      	coef.P2X = 2.0*_points[0].x - c0.P1X;
	      	coef.P2Y = 2.0*_points[0].y - c0.P1Y;
	      	coef.P3X = _points[count].x;           // knot number 'count' and knot number 0 should be the same for a closed spline
	      	coef.P3Y = _points[count].y;
	    }
	
	
	    // bisector normal computations, clockwise knot order
	    private function _CW(_i:int, _t:Number):void{
	    	var dt:Number = _t*_d1;
	
	      	_bXNR = _points[_i+1].x - dt*_uY;
	      	_bYNR = _points[_i+1].y + dt*_uX;
	
	      	dt = _t*_d2;
	      	_bXNL = _points[_i+1].x + dt*_uY;
	      	_bYNL = _points[_i+1].y - dt*_uX;
	    }
	
	    // bisector normal computations, counter-clockwise knot order
	    private function _CCW(_i:int, _t:Number):void{
	    	var dt:Number = _t*_d2;
	
	      	_bXNL = _points[_i+1].x - dt*_uY;
	      	_bYNL = _points[_i+1].y + dt*_uX;
	
	      	dt = _t*_d1;
	      	_bXNR = _points[_i+1].x + dt*_uY;
	      	_bYNR = _points[_i+1].y - dt*_uX;
	    }
	
	    // clockwise order for three-knot sequence?
	    private function _isClockWise(_pts:Array, _i:Number):Boolean{
	    	return ((_pts[_i+2].y-_pts[_i].y)*(_pts[_i+1].x-_pts[_i].x) > (_pts[_i+1].y-_pts[_i].y)*(_pts[_i+2].x-_pts[_i].x));
	    }
  	}
}