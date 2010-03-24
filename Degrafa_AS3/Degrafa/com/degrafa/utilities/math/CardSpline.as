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
// CardSpline.as - Generate Cardinal Spline, interpolating a set of data points with tension parameter. 
//
// Reference:  http://www.algorithmist.net/media/catmullrom.pdf (for derivation of basis matrix)
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
  
  public class CardSpline extends CatmullRom implements IPlottableSpline 
  {
    protected var __tension:Number;  // tension value
    protected var __a:Number;        // measure of amount to which spline is influenced by tangents at each join
    
/**
 * CardSpline() - Construct a new cardinal spline
 *
 * @return Nothing
 *
 * @since 1.0
 *
 */
    public function CardSpline()
    {
      super();
      
      tension = 0;
    }
    
    public function set tension(_t:Number):void
    {
      // tension is allowed outside [0,1], but should be limited for practical reasons
      __tension = _t
      __a       = 0.5*(1-__tension);
    }
    
/**
 * @inheritDoc
 *
 */
    override public function getX(_t:Number):Number
    {
      if( __knots < 2 )
        return ( (__knots==1) ? __x[1] : 0 );
    
      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);

      return __coef[__index].getX(__localParam);
    }

/**
 * @inheritDoc
 *
 */
    override public function getXPrime(_t:Number):Number
    {
      if( __knots < 2 )
        return 0;

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return __coef[__index].getXPrime(__localParam);
    }

/**
 * 
 * @inheritDoc
 *
 */
    override public function getY(_t:Number):Number
    {
      if( __knots < 2 )
        return ( (__knots==1) ? __y[1] : 0 );

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return __coef[__index].getY(__localParam);
    }

/**
 * @inheritDoc
 *
 */
    override public function getYPrime(_t:Number):Number
    {
      if( __knots < 2 )
        return 0;

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return __coef[__index].getYPrime(__localParam);
    }

    
    // compute polynomical coefficients
    override protected function __computeCoef():void
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

        c.addCoef( __x[i], __y[i] );
        
        c.addCoef( __a*(__x[i+1] - __x[i-1]), __a*(__y[i+1] - __y[i-1]) );

        c.addCoef( 2.0*__a*__x[i-1] + (__a-3.0)*__x[i] + (3.0 - 2.0*__a)*__x[i+1] - __a*__x[i+2],  2.0*__a*__y[i-1] + (__a-3.0)*__y[i] + (3.0 - 2.0*__a)*__y[i+1] - __a*__y[i+2] );

        c.addCoef(  -__a*__x[i-1] + (2.0-__a)*__x[i] + (__a - 2.0)*__x[i+1] + __a*__x[i+2],   -__a*__y[i-1] + (2.0-__a)*__y[i] + (__a - 2.0)*__y[i+1] + __a*__y[i+2] );

        __coef[i] = c;
      }

      __invalidate = false;
      __parameterize();
    }
  }
}