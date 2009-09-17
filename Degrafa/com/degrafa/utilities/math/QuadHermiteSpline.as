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
// Programmed by: Jim Armstrong
//
// This software is derived from source containing the following copyright notice
//
// copyright (c) 2008, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
//

package com.degrafa.utilities.math
{ 
  import com.degrafa.geometry.splines.IPlottableSpline;
  import com.degrafa.geometry.splines.SplineTypeEnum;
  
  public class QuadHermiteSpline implements IPlottableSpline
  {
    // core
    protected var __quads:Array;            // collection of quad hermite curves for individual segments of the spline
    protected var __x:Array;                // x-coordinates of knot sequence
    protected var __y:Array;                // y-coordinates of knot sequence
    protected var __knots:int;              // current knot count
    protected var __t:Number;               // current t-value
    protected var __index:Number;           // current index into coefficient array
    protected var __localParam:Number;      // local (segment-based) parameter
    protected var __tX:Number;              // x-coordinate of start tangent
    protected var __tY:Number;              // y-coordinate of start tangent
    protected var __invalidate:Boolean;     // true if current coefficients are invalid

/**
 * <code>QuadHermiteSpline()</code> Construct a new QuadHermiteSpline instance.
 *
 * @return Nothing.  A Quadratic Hermite spline is interpolates a sequence of knots but requires an initial start tangent from the first knot.  This
 * tangent influences the overall shape of the spline.  Choices are 1) Natural Quadratic Spline - zero tangent, 2) User-selected tangent, 3) Auto-selected tangent.
 * The user-selected method should be chosen when the knot sequence is statically defined and known in advance.  Automatic selection is useful when the knot
 * sequence is determined at runtime.  Default is automatic.  Call the <code>startTangent</code> method to assign tangent coordinates.
 *
 * @since 1.0
 *
 */
    public function QuadHermiteSpline()
    {
      __quads = [];
      __x     = [];
      __y     = [];
      
      __invalidate = true;
      __tX         = NaN;
      __tY         = NaN;
      __knots      = 0;
      __t          = -1;
      __index      = 0;
      __localParam = 0;
    }
    
    public function get type():String { return SplineTypeEnum.PARAMETRIC; }
    public function eval(_x:Number):Number { return 0; }
    public function derivative(_x:Number):Number { return 0; }
    public function getCoef(_segment:uint):Object { return __quads[_segment].getCoef(); }

/**
 * <code>[get] knotCount</code> Access number of knots.
 *
 * @param _t:Number - x-coordinate of knot to add
 * @param _y:Number - y-coordinate of knot to add
 *
 * @return int Current knot count
 *
 * @since 1.0
 *
 */
    public function get knotCount():int { return __knots; }

/**
 * <code>[get] knots</code> Access knots collection.
 *
 * @return Array Knot collection; i-th Array element is an Object with x-coordinate of the i-th knot in the 'X' property and y-coordinate in the 'Y' property
 *
 * @since 1.0
 *
 */
    public function get knots():Array
    {
      var knotArr:Array = new Array();
      for( var i:uint=0; i<__knots; ++i )
        knotArr.push({X:__x[i], Y:__y[i]});

      return knotArr;
    }
    
/**
 * <code>startTangent</code> Assign start tangent coordinates.
 *
 * @param _x:Number x-coordinate of start tangent in same coordinate space as control points
 * @param _y:Number y-coordinate of start tangent in same coordinate space as control points
 * 
 * @return Nothing Call this method to override the default automatic start tangent and assign a specific tangent.
 *
 * @since 1.0
 *
 */
    public function startTangent(_x:Number, _y:Number):void
    {
      if( !isNaN(_x) && !isNaN(_y) )
      {
        __tX = _x;
        __tY = _y;
        
        __invalidate = true;
      }
    }

/**
 * <code>addControlPoint</code> Add a knot or control point.  
 *
 * @param _t:Number - x-coordinate of knot
 * @param _y:Number - y-coordinate of knot
 *
 * @return Nothing
 *
 * @since 1.0
 *
 */
    public function addControlPoint(_xKnot:Number, _yKnot:Number):void
    {

      if( !isNaN(_xKnot) && !isNaN(_yKnot) )
      {
        __invalidate = true;

        __x[__knots]   = _xKnot;
        __y[__knots++] = _yKnot;
      }
    }
    
/**
 * <code>moveControlPoint</code> Move knot at the specified index within its interval
 *
 * @param _indx:uint    - index of knot to replace
 * @param _xKnot:Number - new x-coordinate
 * @param _yKnot:Number - new y-coordinate
 *
 * @return Nothing - There is no testing to see if the move causes any intervals to overlap
 *
 * @since 1.0
 *
 */
    public function moveControlPoint(_indx:uint, _xKnot:Number, _yKnot:Number):void
    {
      if( _indx < 0 || _indx >= __knots )
      {
        return;
      }

      if( isNaN(_xKnot) || isNaN(_yKnot) )
      {
        return;
      }

      __x[_indx]   = _xKnot;
      __y[_indx]   = _yKnot;
      __invalidate = true;
    }
    
/**
 * reset - Remove all control points and initialize spline for new control point entry (tangents are set to automatic, so call startTangent() to override and
 * manually specify a start tangent)
 *
 * @return Nothing
 *
 * @since 1.0
 *
 */
    public function reset():void
    {
      __x.splice(0);
      __y.splice(0);
      __quads.splice(0);

      __knots      = 0;
      __tX         = NaN;
      __tY         = NaN;
      __t          = -1;
      __invalidate = true;
    }
    
/**
 * getX - Return x-coordinate for a given t
 *
 * @param _t:Number - parameter value in [0,1]
 *
 * @return Number Value of Catmull-Rom spline, provided input is in [0,1], C(0) or C(1).  If knot count is below 2, return 0.
 *
 * @since 1.0
 *
 */
    public function getX(_t:Number):Number
    {
      if( __knots < 2 )
        return ( (__knots==1) ? __x[1] : 0 );
    
      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);

      return __quads[__index].getX(__localParam);
    }

/**
 * getXPrime - Return dx/dt for a given t
 *
 * @param _t:Number - parameter value in [0,1]
 *
 * @return Number: Value of dx/dt, provided input is in [0,1].
 *
 * @since 1.0
 *
 */
    public function getXPrime(_t:Number):Number
    {
      if( __knots < 2 )
        return 0;

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return __quads[__index].getXPrime(__localParam);
    }

/**
 * getY - Return y-coordinate for a given t
 *
 * @param _t:Number - parameter value in [0,1]
 *
 * @return Number: Value of Catmull-Rom spline, provided input is in [0,1], C(0) or C(1).
 *
 * @since 1.0
 *
 */
    public function getY(_t:Number):Number
    {
      if( __knots < 2 )
        return ( (__knots==1) ? __y[1] : 0 );

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return __quads[__index].getY(__localParam);
    }

/**
 * getYPrime - Return dy/dt for a given t
 *
 * @param _t:Number - parameter value in [0,1]
 *
 * @return Number Value of dy/dt, provided input is in [0,1].
 *
 * @since 1.0
 *
 */
    public function getYPrime(_t:Number):Number
    {
      if( __knots < 2 )
        return 0;

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return __quads[__index].getYPrime(__localParam);
    }

    
   
    protected function __setParam(_t:Number):void
    {
      var t:Number = (_t<0) ? 0 : _t;
      t            = (t>1)  ? 1 : t;

      if( t != __t )
      {
        __t = t;
        __segment();
      }
    }
    
    protected function __computeCoef():void
    { 
      if( isNaN(__tX) && isNaN(__tY) )
        __computeEndpoints();
      
      // currently, all segments are recomputed from scratch any time something changes; may make more efficient in the future if this is used
      // for games or other application requiring frequent redraws with modified data
      __quads.length = 0;
      
      // loop over segments
      var tx:Number = __tX;
      var ty:Number = __tY;
      for( var i:uint=0; i<__knots-1; ++i )
      {
        var p0X:Number = __x[i];
        var p0Y:Number = __y[i];
        var p1X:Number = __x[i+1];
        var p1Y:Number = __y[i+1];
        
      	 var q:QuadraticHermiteCurve = new QuadraticHermiteCurve(p0X, p0Y, p1X, p1Y, tx, ty);
      	 
      	 // add to the collective and compute start tangent for next segment
      	 __quads[i] = q;
      	 
      	 var dx:Number   = tx - p0X;
        var dy:Number   = ty - p0Y;
        var e1X:Number  = 2*p1X - p0X;
        var e1Y:Number  = 2*p1Y - p0Y;
        var endX:Number = e1X - dx;
        var endY:Number = e1Y - dy;
          
        dx = endX - p0X;
        dy = endY - p0Y;
        tx = p1X + dx;
        ty = p1Y + dy;
      }

      __invalidate = false;
    }

    protected function __segment():void
    {
	    	// the trivial case -- one segment
	     if( __knots == 2 )
	     {
	      	__index = 0;
	     }
	     else 
	     {
	       if( __t == 0 )
	       {
	         __index      = 0;
	         __localParam = 0;
	       }
	       else if( __t == 1.0 )
	       {
	         __index      = __knots-2;
	         __localParam = 1.0;
	       }
	       else
	       {
	         var N1:Number = __knots-1;
	         var N1t:Number = N1*__t;
	         var f:Number = Math.floor(N1t);
	         __index = Math.min(f+1, N1)-1;
	         __localParam = N1t - f;
	      	}
	     }
	   }
	   
	   protected function __computeEndpoints():void
	   {
	     var p0X:Number = __x[0];
	     var p0Y:Number = __y[0];
	     var p1X:Number = __x[1];
	     var p1Y:Number = __y[1];
	     var p2X:Number = __x[2];
	     var p2Y:Number = __y[2];
	     var nx:Number  = p1X - p0X;
      var ny:Number  = p1Y - p0Y;
      var d:Number   = Math.sqrt(nx*nx + ny*ny);
      nx            /= d;
      ny            /= d;
        
      var px:Number = p2X - p0X;
      var py:Number = p2Y - p0Y;
      var w:Number  = nx*px + ny*py;
      
      __tX = 2*p0X - p2X + 2*w*nx;
      __tY = 2*p0Y - p2Y + 2*w*ny;
	   }
  }
}