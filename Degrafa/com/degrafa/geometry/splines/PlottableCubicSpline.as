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
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// Reference: http://www.algorithmist.net/spline.html
//

package com.degrafa.geometry.splines
{
  import com.degrafa.utilities.math.CubicSpline;
  
  public class PlottableCubicSpline extends CubicSpline implements IPlottableSpline
  { 
/**
* <code>PlottableCubicSpline()</code> Construct a new Plottable Cubic Spline instance.
*
* @return nothing.
*
* @since 1.0
*
*/
    public function PlottableCubicSpline()
    {
      super();
    }

    // return type of spline - cartesian (y as a function of x) or parameteric (x and y as functions of t in [0,1])
    public function get type():String { return SplineTypeEnum.CARTESIAN; }
    
    // evaluate the first derivative of a cartesian spline at the specified x-coordinate
    public function derivative(_x:Number):Number
    {
      if( __knots == 0 )
        return NaN;
      else if( __knots == 1 )
        return __y[0];
     
      if( __invalidate )
        __computeZ();

      // determine interval
      var i:uint        = 0;
      __delta           = _x - __t[0];
      var delta2:Number = __t[1] - _x;
      for( var j:uint=__knots-2; j>=0; j-- )
      {
        if( _x >= __t[j] )
        {
          __delta = _x - __t[j];
          delta2  = __t[j+1] - _x;
          i = j;
          break;
        }
      }
 
      // this can be made more efficient - doing so is left as an exercise - see eq. [3] in the above reference
      var h:Number  = __h[i];
      var h2:Number = 1/(2.0*h);
      var h6:Number = h/6;
      
      var a:Number = __delta*__delta;
      var b:Number = delta2*delta2;
      var c:Number = __z[i+1]*h2*a;
      c           -= __z[i]*h2*b;
      c           += __hInv[i]*__y[i+1];
      c           -= __z[i+1]*h6;
      c           -= __y[i]*__hInv[i];
      c           += h6*__z[i];

      return c;
    }
    
    // these functions are not required for a cartesian spline and are provided to fully implement the interface
    public function getX(_t:Number):Number { return 0; }
    public function getY(_t:Number):Number { return 0; }
    
    // evaluate x'(t) and y'(t) of a parameteric spline at the specified parameter
    public function getXPrime(_t:Number):Number { return 0; }
    public function getYPrime(_t:Number):Number { return 0; }
    
    // for a parametric spline, return the cubic polynomial coefficients for a specified segment in an Object
    public function getCoef(_segment:uint):Object { return null; }
  }
}