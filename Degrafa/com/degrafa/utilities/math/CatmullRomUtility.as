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
// CatmullRomUtility.as - Generate arc-length parameterized Catmull-Rom spline that interpolates a set of data points, suitable for use
// as a utility in keyframing, interpolation, and path animation, but not intended for general drawing.
//
// Reference:  www.algorithmist.net/arclen1.html
//
// Programmed by Jim Armstrong
//
// Note:  Class defaults to auto-tangent, uniform parameterization.  This class is meant to be used as a
// math utility for interpolation or path animation, not for drawing.  This class is structured more for
// clarity than performance.
//

package com.degrafa.utilities.math
{ 
  public class CatmullRomUtility extends CatmullRom
  {
    private static const ONE_THIRD:Number  = 1.0/3.0;
    private static const TWO_THIRDS:Number = 2.0/3.0;
    
    // Arc-length computation and parameterization
    protected var __param:String;           // parameterization method
    protected var __integral:Gauss;         // Gauss-Legendre integration class
    protected var __arcLength:Number;       // current arc length
    protected var __spline:CubicSpline;     // interpolate arc-length vs. t
    
/**
* CatmullRomUtility() - Construct a new Catmull-Rom spline
*
* @return Nothing
*
* @since 1.0
*
*/
    public function CatmullRomUtility()
    {
      super();
      
      __arcLength  = -1;
      __param      = ARC_LENGTH;
      
      __spline   = new CubicSpline();
      __integral = new Gauss();
    }

    protected function __integrand(_t:Number):Number
    {
      var x:Number = __coef[__index].getXPrime(_t);
      var y:Number = __coef[__index].getYPrime(_t);

      return Math.sqrt( x*x + y*y );
    }
    
    override public function reset():void
    {
      super.reset();
      __arcLength = -1;
    }
    
/**
* arcLength  Estimate arc-length of the entire curve by numerical integration
*
* @return Number: Estimate of total arc length of the spline over [0,1]
*
* @since 1.0
*
*/
    public function arcLength():Number
    {
      if ( __arcLength != -1 )
        return __arcLength;

      // compute the length of each segment and sum
      var len:Number = 0;
      if( __knots < 2 )
        return len;

      if( __invalidate )
        __computeCoef();

      for( var i:uint=1; i<__knots; ++i )
      {
        __index = i;
        len    += 0.5*__integral.eval( __integrand, 0, 1, 5 );
      }

      __arcLength = len;
      return len;
    }

/**
* arcLengthAt  Return arc-length of curve segment on [0,_t].
*
* @param _t:Number - parameter value to describe partial curve whose arc-length is desired
*
* @return Number: Estimate of arc length of curve segment from t=0 to t=_t.
*
* @since 1.0
*
*/
    public function arcLengthAt(_t:Number):Number
    {
      // compute the length of each segment and sum
      var len:Number = 0;
      if( __knots < 2 || _t == 0 )
        return len;

      if( __invalidate )
        __computeCoef();

      var t:Number = (_t<0) ? 0 : _t;
      t            = (t>1) ? 1 : t;

      // determine which segment corresponds to the input value and the local parameter for that segment
      var N1:Number     = __knots-1;
      var N1t:Number    = N1*t;
      var f:Number      = Math.floor(N1t);
      var maxSeg:Number = Math.min(f+1, N1);
      var param:Number  = N1t - f;

      // compute full curve length up to, but not including final segment
      for( var i:uint=1; i<maxSeg; ++i )
      {
        __index = i;
        len    += 0.5*__integral.eval( __integrand, 0, 1, 5 );
      }

      // add partial curve segment length, unless we're at a knot
      if( param != 0 )
      {
        __index = maxSeg;
        len    += 0.5*__integral.eval( __integrand, 0, param, 5 );
      }

      return len;
    }
    
    // parameterize spline
    override protected function __parameterize():void
    {
      // this is a bit innefficient, but will be made tighter in the future.  Place a spline knot at
      // each of the C-R knots and two knots in between.  If spline knots are already in place, then
      // this method was most likely called as a result of moving one or more C-R knots, so regenerate
      // the entire set of interpolation knots.
      if( __param == ARC_LENGTH )
      {
        if( __arcLength == -1 )
          var len:Number = arcLength();

        var normalize:Number = 1.0/__arcLength;

        if( __spline.knotCount > 0 )
          __spline.deleteAllKnots();

        // x-coordinate of spline knot is normalized arc-length, y-coordinate is t-value for uniform parameterization
        __spline.addControlPoint(0.0, 0.0);
        var prevT:Number    = 0;
        var knotsInv:Number = 1.0/Number(__knots-1);
        
        for( var i:uint=1; i<__knots-1; i++ )
        {
          // get t-value at this knot for uniform parameterization
          var t:Number  = Number(i)*knotsInv;
          var t1:Number = prevT + ONE_THIRD*(t-prevT);
          var l:Number  = arcLengthAt(t1)*normalize;
          __spline.addControlPoint(l,t1);

          var t2:Number = prevT + TWO_THIRDS*(t-prevT);
          l             = arcLengthAt(t2)*normalize;
          __spline.addControlPoint(l,t2);

          l = arcLengthAt(t)*normalize;
          __spline.addControlPoint(l,t);

          prevT = t;
        }

        t1 = prevT + ONE_THIRD*(1.0-prevT);
        l  = arcLengthAt(t1)*normalize;
        __spline.addControlPoint(l,t1);

        t2 = prevT + TWO_THIRDS*(1.0-prevT);
        l  = arcLengthAt(t2)*normalize;
        __spline.addControlPoint(l,t2);

        // last knot, t=1, normalized arc-length = 1
        __spline.addControlPoint(1.0, 1.0);
      }
    }
    
    // support optional arc-length parameterization
    override protected function __setParam(_t:Number):void
    {
      var t:Number = (_t<0) ? 0 : _t;
      t            = (t>1)  ? 1 : t;

      // if arc-length parameterization, approximate L^-1(s)
      if( __param == ARC_LENGTH )
      {
        if( t != __s )
        {
          __t = __spline.eval(t);
          __s = t;
          __segment();
        }
      }
      else
      {
        if( t != __t )
        {
          __t = t;
          __segment();
        }
      }
    }

  }
}