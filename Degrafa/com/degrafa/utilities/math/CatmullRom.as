////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009 The Degrafa Team : http://www.Degrafa.com/team
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
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// Ported to Degrafa with permission of author
//
// CatmullRom.as - Generate cubic Catmull-Rom spline that interpolates a set of data points.  
//
// Reference:  www.algorithmist.net/arclen1.html
//
// Programmed by Jim Armstrong
//
// Note:  Class defaults to auto-tangent, uniform parameterization. This class is structured more for
// clarity than performance.
//

package com.degrafa.utilities.math
{ 
  import com.degrafa.geometry.splines.IPlottableSpline;
  import com.degrafa.geometry.splines.SplineTypeEnum;
  
  public class CatmullRom implements IPlottableSpline 
  {
    public static const AUTO:String       = "auto";
    public static const EXPLICIT:String   = "explicit";
    public static const UNIFORM:String    = "uniform";
    public static const ARC_LENGTH:String = "arclength";
    public static const FIRST:String      = "first";
    public static const LAST:String       = "last";
    
    // core
    protected var __x:Array;                // x-coordinates
    protected var __y:Array;                // y-coordinates
    protected var __theKnots:Array;         // holder for original user-specified control points
    protected var __tangent:String;         // endpoint (implicit tangent) specification
    protected var __coef:Array;             // coefficients for each segment
    protected var __t:Number;               // current t-value
    protected var __s:Number;               // current arc-length
    protected var __xHold:Number;           // holder for rightmost x-coordinate control point
    protected var __yHold:Number;           // holder for rightmost y-coordinate of control point
    protected var __index:Number;           // current index into coefficient array
    protected var __localParam:Number;      // local (segment-based) parameter
    protected var __knots:Number;           // knot count
    protected var __prevIndex:Number;       // previous index reference
    protected var __isClosed:Boolean;       // true is spline is automatically closed
    
    protected var __invalidate:Boolean;     // true if current coefficients are invalid

/**
* CatmullRom() - Construct a new Catmull-Rom spline
*
* @return Nothing
*
* @since 1.0
*
*/
    public function CatmullRom()
    {
      __x        = new Array();
      __y        = new Array();
      __theKnots = new Array();
      __coef     = new Array();

      __x.push(0);
      __y.push(0);

      __tangent    = AUTO;
      __t          = -1;
      __s          = -1;
      __prevIndex  = -1;
      __xHold      = 0;
      __yHold      = 0;
      __knots      = 0;
      __isClosed   = false;
      __invalidate = true;
    }
    
    public function get type():String { return SplineTypeEnum.PARAMETRIC; }
    public function eval(_x:Number):Number { return 0; }
    public function derivative(_x:Number):Number { return 0; }
    
    // tbd complete implementation; following are for purposes of filling out the interface
    public function getCoef(_segment:uint):Object
    {
      var c:Cubic = __coef[_segment];
      if( c == null )
        return null;
      
      var myObj:Object = new Object();
      var o:Object     = c.getCoef(0);
      myObj.c0X        = o.X;
      myObj.c0Y        = o.Y;
      
      o         = c.getCoef(1);
      myObj.c1X = o.X;
      myObj.c1Y = o.Y;
      
      o         = c.getCoef(2);
      myObj.c2X = o.X;
      myObj.c2Y = o.Y;
      
      o         = c.getCoef(3);
      myObj.c3X = o.X;
      myObj.c3Y = o.Y;
      
      return myObj;
    }
    
    public function get knots():Array
    {
      return __theKnots;
    }
    
    // return initial or terminal control point, outside user-specified knots
    public function getControlPoint(_i:uint):Object
    {
      if( _i == 0 )
        return {X:__x[0], Y:__y[0]};
      else
      	return {X:__x[__knots+1], Y:__y[__knots+1]};
    }
    
    public function set tangent(_s:String):void
    {
      if( _s == AUTO || _s == EXPLICIT )
        __tangent = _s;

      __invalidate = true;
    }
    
    public function set closed(_b:Boolean):void 
    { 
      __isClosed = _b; 
      addControlPoint(__x[1], __y[1]);
      __closedSplineEndpoints();
    }
    
/**
* addControlPoint - Add a control point
*
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
*
* @return Nothing Adds the specified interpolation or control points to the spline.  No error checking is made on arguments.
*
* @since 1.0
*
*/
    public function addControlPoint( _xCoord:Number, _yCoord:Number ):void
    {
      __knots++;
      __x[__knots] = _xCoord;
      __y[__knots] = _yCoord;

      __theKnots[__knots-1] = {X:_xCoord, Y:_yCoord};

      
      __invalidate = true;
    }

/**
* setOuterPoint - Add control point outside the knot range
*
* @param _flag:String   - indicate which extreme to place point - FIRST (modify first control point) or LAST (last control point)
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
*
* @return Nothing Sets one of the outer control points before the first or after last knot to influence out- and in-tangent at the first/last knots.
*
* @since 1.0
*
*/
    public function setOuterPoint( _flag:String, _xCoord:Number, _yCoord:Number ):void
    {
      if( _flag == FIRST )
      {
        __x[0] = _xCoord;
        __y[0] = _yCoord;
      }
      else
      {
        __xHold = _xCoord;
        __yHold = _yCoord;
      }
    }

/**
* reset - Remove all control points and initialize spline for new control point entry
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
      __coef.splice(0);

      __x.push(0);
      __y.push(0);

      __knots      = 0;
      __prevIndex  = -1;
      __t          = -1;
      __s          = -1;
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

      return 0.5*__coef[__index].getX(__localParam);
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
    
      return 0.5*__coef[__index].getXPrime(__localParam);
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
    
      return 0.5*__coef[__index].getY(__localParam);
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
    
      return 0.5*__coef[__index].getYPrime(__localParam);
    }

/**
* tAtKnot - Return t-value at a particular knot index
*
* @param _k:Number - Knot index, starting at zero
*
* @return Number: t-value corresponding to knot at index _k, provided k is in-range.  Returns -1 otherwise.  Currently works only for uniform parameterization.
*
* @since 1.0
*
*/
    public function tAtKnot(_k:Number):Number
    {
      if( _k < 0 || _k > __knots-1 )
        return -1;

      var t:Number = 0;
      
      if( _k == 0 )
        t = 0;
      else if( _k == (__knots-1) )
        t = 1;
      else
        t = Number(_k)/Number((__knots-1));
      
      return t;
    }

    // compute polynomical coefficients
    protected function __computeCoef():void
    { 
      // fill out endpoints based on user selection
      if( __tangent == AUTO )
        __computeEndpoints();
      else
      {
        __x[__knots+1] = __xHold;
        __y[__knots+1] = __yHold;
      }

      // loop over segments
      for( var i:uint=1; i<__knots; ++i )
      {
      	var c:Cubic = __coef[i];
        if( c == null )
          c = new Cubic();
        else
          c.reset();

        c.addCoef( 2.0*__x[i], 2.0*__y[i] );
        
        c.addCoef( __x[i+1] - __x[i-1], __y[i+1] - __y[i-1] );

        c.addCoef( 2.0*__x[i-1] - 5.0*__x[i] + 4.0*__x[i+1] - __x[i+2], 2.0*__y[i-1] - 5.0*__y[i] + 4.0*__y[i+1] - __y[i+2] );

        c.addCoef(  -__x[i-1] + 3.0*__x[i] - 3.0*__x[i+1] + __x[i+2],  -__y[i-1] + 3.0*__y[i] - 3.0*__y[i+1] + __y[i+2] );

        __coef[i] = c;
      }

      __invalidate = false;
      __parameterize();
    }

    // parameterize spline - this should be overriden by any extending class to support arc-length, chord-length, or other specific parameterization
    protected function __parameterize():void
    {
     
    }
    
    // base class only supports uniform parameterization
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

    // compute current segment and local parameter value
    protected function __segment():void
    {
      // the trivial case -- one segment
      if( __knots == 2 )
      {
        __index      = 1;
        __localParam = __t;
      }
      else 
      {
        if( __t == 0 )
        {
          __index = 1;
          __localParam = 0;
        }
        else if( __t == 1.0 )
        {
          __index      = __knots-1;
          __localParam = 1.0;
        }
        else
        {
          var N1:Number  = __knots-1;
          var N1t:Number = N1*__t;
          var f:Number   = Math.floor(N1t);
          __index        = Math.min(f+1, N1);
          __localParam   = N1t - f;
        }
      }
    }

    // compute endpoints at extremes of knot sequence - simple reflection about endpoints (compensating for closed spline)
    protected function __computeEndpoints():void
    {
      if( !__isClosed )
      {
        // simple reflection
        __x[0] = 2.0*__x[1] - __x[2];
        __y[0] = 2.0*__y[1] - __y[2];

        __x[__knots+1] = 2.0*__x[__knots] - __x[__knots-1];
        __y[__knots+1] = 2.0*__y[__knots] - __y[__knots-1];
      }
    }
    
    protected function __closedSplineEndpoints():void
    {   
      var x1:Number  = __x[1];
      var y1:Number  = __y[1];
      var dX1:Number = __x[2] - x1;
      var dY1:Number = __y[2] - y1;
      var dX2:Number = __x[__knots-1] - x1;
      var dY2:Number = __y[__knots-1] - y1;
      var d1:Number  = Math.sqrt(dX1*dX1 + dY1*dY1);
      var d2:Number  = Math.sqrt(dX2*dX2 + dY2*dY2);
      dX1 /= d1;
      dY1 /= d1;
      dX2 /= d2;
      dY2 /= d2;
      
      __x[0]         = x1 + d1*dX2;
      __y[0]         = y1 + d1*dY2;
      __x[__knots+1] = x1 + d2*dX1;
      __y[__knots+1] = y1 + d2*dY1;
    }
  }
}