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
//

package com.degrafa.utilities.math
{ 
  public class CubicSpline
  {
    protected static const ONE_SIXTH:Number = 1.0/6.0;
    
    // read associated white paper for details on these variables
    protected var __t:Array;
    protected var __y:Array;
    protected var __u:Array;
    protected var __v:Array;
    protected var __h:Array;
    protected var __b:Array;
    protected var __z:Array;

    protected var __hInv:Array;             // precomputed h^-1 values
    protected var __delta:Number;           // current x-t(i)
    protected var __knots:Number;           // current knot count
    
    protected var __invalidate:Boolean;     // true if current coefficients are invalid

/**
* <code>CubicSpline()</code> Construct a new Cubic Spline instance.
*
* @return nothing. Note:  Although some attempt has been made to optimize operation count and complexity, this code is written more for clarity than Actionscript performance.
* <p>Important notes:<br><br> 1) Intervals must be non-overlapping.  Insertion preserves this constraint.<br>2) Knot insertion/deletion causes a complete regeneration of 
* coefficients. A future (faster) version will do this adaptively.<br><br>
* Reference:  http://www.algorithmist.net/spline.html.
*
* @since 1.0
*
*/
    public function CubicSpline()
    {
      __t    = new Array();
      __y    = new Array();
      __u    = new Array();
      __v    = new Array();
      __h    = new Array();
      __b    = new Array();
      __z    = new Array();
      __hInv = new Array();

      __invalidate = true;
      __delta      = 0.0;
      __knots      = 0;
    }

    // return knot count
    public function get knotCount():Number { return __knots; }

    // return array of Objects with X and Y properties containing knot coordinates
    public function get knots():Array
    {
      var knotArr:Array = new Array();
      for( var i:uint=0; i<__knots; ++i )
        knotArr.push({X:__t[i], Y:__y[i]});

      return knotArr;
    }

/**
* <code>addControlPoint</code> Add/Insert a knot in a manner that maintains non-overlapping intervals.  This method rearranges knot order, if necessary, to 
* maintain non-overlapping intervals.
*
* @param _xKNot:Number - x-coordinate of knot to add
* @param _yKnot:Number - y-coordinate of knot to add
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

        if( __t.length == 0 )
        {
          __t.push(_xKnot);
          __y.push(_yKnot);
          __knots++;
        }
        else
        {
          if ( _xKnot > __t[__knots-1] )
          {
            __t.push(_xKnot);
            __y.push(_yKnot);
            __knots++;
          }
          else if( _xKnot < __t[0] )
            __insert(_xKnot, _yKnot, 0);
          else
          {
            if( __knots > 1 )
            {
              for( var i:uint=0; i<__knots-1; ++i )
              {
                if( _xKnot > __t[i] && _xKnot < __t[i+1] )
                  __insert(_xKnot, _yKnot, i+1 );
              }
            }
          }
        }
      }
    }
    
    // insert knot at index
    protected function __insert(_xKnot:Number, _yKnot:Number, _indx:Number):void
    {
      for( var i:uint=__knots-1; i>=_indx; i-- )
      { 
        __t[i+1] = __t[i];
        __y[i+1] = __y[i];
      }
      
      __t[_indx] = _xKnot;
      __y[_indx] = _yKnot;
      __knots++;
    }

    // remove knot at index
    protected function __remove(_indx:Number):void
    {
      for( var i:uint=_indx; i<__knots; ++i)
      { 
        __t[i] = __t[i+1];
        __y[i] = __y[i+1];
      }
      
      __t.pop();
      __y.pop();
      __knots--;
    }

/**
* <code>removePointAt</code> Delete knot at the specified index
*
* @param _indx:uint - index of knot to delete
*
* @return Nothing
*
* @since 1.0
*
*/
    public function removePointAt(_indx:uint):void
    {
      if( _indx < 0 || _indx >= __knots )
      {
        return;
      }

      __remove(_indx);
      __invalidate = true;
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

      __t[_indx]   = _xKnot;
      __y[_indx]   = _yKnot;
      __invalidate = true;
    }
    
/**
* <code>deleteAllKnots</code> Delete all knots
*
* @return Nothing
*
* @since 1.0
*
*/
    public function deleteAllKnots():void
    {
      __t.splice(0);
      __y.splice(0);

      __knots      = 0;
      __invalidate = true;
    }

/**
* <code>removeKnotAtX</code> Delete knot at a given x-coordinate
*
* @param _xKnot:Number - x-coordinate of knot to delete
*
* @return Nothing
*
* @since 1.0
*
*/
    public function removeKnotAtX(_xKnot:Number):void
    {
      if( isNaN(_xKnot) )
      {
        return;
      }

      var i:int = -1;
      for( var j:int=0; j<__knots; ++j )
      {
        if( __t[j] == _xKnot )
        {
          i = j;
          break;
        }
      }

      if( i == -1 )
      {
        return;
      }
      else
      {
        __remove(i);
        __invalidate = true;
      }
    }

/**
* <code>eval</code> Evaluate spline at a given x-coordinate
*
* @param _xKnot:Number - x-coordinate to evaluate spline
*
* @return Number: - NaN if there are no knots
*                 - y[0] if there is only one knot
*                 - Spline value at the input x-coordinate, if there are two or more knots
*
* @since 1.0
*
*/
    public function eval(_xKnot:Number):Number
    {
      if( __knots == 0 )
        return NaN;
      else if( __knots == 1 )
        return __y[0];
      else
      {
        if( __invalidate )
          __computeZ();

        // determine interval
        var i:uint = 0;
        __delta    = _xKnot - __t[0];
        for( var j:uint=__knots-2; j>=0; j-- )
        {
          if( _xKnot >= __t[j] )
          {
            __delta = _xKnot - __t[j];
            i = j;
            break;
          }
        }

        var b:Number = (__y[i+1] - __y[i])*__hInv[i] - __h[i]*(__z[i+1] + 2.0*__z[i])*ONE_SIXTH;
        var q:Number = 0.5*__z[i] + __delta*(__z[i+1]-__z[i])*ONE_SIXTH*__hInv[i];
        var r:Number = b + __delta*q;
        var s:Number = __y[i] + __delta*r;

        return s;
      }
    }

    // compute z[i] based on current knots
    protected function __computeZ():void
    {
      // reference the white paper for details on this code

      // pre-generate h^-1 since the same quantity could be repeatedly calculated in eval()
      for( var i:uint=0; i<__knots-1; ++i )
      {
        __h[i]    = __t[i+1] - __t[i];
        __hInv[i] = 1.0/__h[i];
        __b[i]    = (__y[i+1] - __y[i])*__hInv[i];
      }

      // recurrence relations for u(i) and v(i) -- tridiagonal solver
      __u[1] = 2.0*(__h[0]+__h[1]);
      __v[1] = 6.0*(__b[1]-__b[0]);
   
      for( i=2; i<__knots-1; ++i )
      {
        __u[i] = 2.0*(__h[i]+__h[i-1]) - (__h[i-1]*__h[i-1])/__u[i-1];
        __v[i] = 6.0*(__b[i]-__b[i-1]) - (__h[i-1]*__v[i-1])/__u[i-1];
      }

      // compute z(i)
      __z[__knots-1] = 0.0;
      for( i=__knots-2; i>=1; i-- )
        __z[i] = (__v[i]-__h[i]*__z[i+1])/__u[i];

      __z[0] = 0.0;

      __invalidate = false;
    }
  }
}