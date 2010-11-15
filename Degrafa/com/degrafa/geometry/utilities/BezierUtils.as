//
// BezierUtils.as - A small collection of static utilities for use with single-segment Bezier curves
//
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
// version 1.2 added quad. bezier refinement as experimental method
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
////////////////////////////////////////////////////////////////////////////////

package com.degrafa.geometry.utilities
{
  import com.degrafa.geometry.QuadraticBezier;
  import com.degrafa.geometry.AdvancedQuadraticBezier;
  import com.degrafa.geometry.CubicBezier;
  import com.degrafa.geometry.Geometry;
  
  import flash.geom.Point;
  
  public class BezierUtils
  {
  	private static const MAX_DEPTH:uint = 64;                                 // maximum recursion depth
  	private static const EPSILON:Number = 1.0 * Math.pow(2, -MAX_DEPTH-1);    // flatness tolerance
  	
  	// pre-computed z(i,j)
  	private static const Z_CUBIC:Array = [1.0, 0.6, 0.3, 0.1, 0.4, 0.6, 0.6, 0.4, 0.1, 0.3, 0.6, 1.0];
  	private static const Z_QUAD:Array  = [1.0, 2/3, 1/3, 1/3, 2/3, 1.0];
  	
  	private var __dMinimum:Number; // minimum distance (cached for accessor)
  	
    public function BezierUtils()
    {
      __dMinimum = 0;
    }
    
/**
* minDistance():Number [get] access the minimum distance
*
* @return Number mimimum distance from specified point to point on the Bezier curve.  Call after <code>closestPointToBezier()</code>.
*
* @since 1.0
*
*/   
    public function get minDistance():Number { return __dMinimum; } 
    
 /**
   * quadArc auto-interpolates a quadratic arc through three points with a quadratic Bezier given only two endpoints and a multiplier of the distance between those points.
   * 
   * @param _po:Point First endpoint (first interpolation point)
   * @param _p2:Point Second endpoint (third interpolation point)
   * @param _alpha:Number Multiplier onto the distance between P0 and P2 to determine the middle interpolation point
   * @default 0.5
   * @param _ccw:Boolean true if the rotation direction from first to last endpoint is ccw; tends to direct the curve upwards if both points are roughly level
   * @default true
   * 
   * @return AdvancedQuadraticBezier refernce to AdvancedQuadraticBezier that interpolates the generated curve.
   *
   * @since 1.1
   *
   */  
    public static function quadArc(_p0:Point, _p2:Point, _alpha:Number=0.5, _isUpward:Boolean=true):AdvancedQuadraticBezier
    {
      var alpha:Number                   = Math.abs(_alpha);
      var bezier:AdvancedQuadraticBezier = new AdvancedQuadraticBezier();
      
      if( _p0 && _p2 )
      {
        var firstx:Number = _p0.x;
        var firsty:Number = _p0.y;
        var lastx:Number  = _p2.x;
        var lasty:Number  = _p2.y;
        var deltax:Number = lastx - firstx;
        var deltay:Number = lasty - firsty;
        var dist:Number   = Math.sqrt(deltax*deltax + deltay*deltay);
        
        var midpointx:Number = 0.5*(firstx + lastx);
        var midpointy:Number = 0.5*(firsty + lasty);
        
        var dx:Number = lastx - midpointx; 
        var dy:Number = lasty - midpointy;
        
        // R is the rotated vector
        if( _isUpward )
        {
          var rx:Number = midpointx + dy;
          var ry:Number = midpointy - dx;
        }
        else
        {
          rx = midpointx - dy;
          ry = midpointy + dx;
        }
        
        deltax        = rx - midpointx;
        deltay        = ry - midpointy;
        var d:Number  = Math.sqrt(deltax*deltax + deltay*deltay);
        var ux:Number = deltax / d;
        var uy:Number = deltay / d;
        
        var p1x:Number = midpointx + _alpha*dist*ux;
        var p1y:Number = midpointy + _alpha*dist*uy;
        
        bezier.interpolate( [_p0, new Point(p1x,p1y), _p2] );
      }
      
      return bezier;
    }
    
/**
 * Given control and anchor points for a quad Bezier and an x-coordinate between the initial and terminal control points, return the t-parameter(s) at the input x-coordinate
 * or -1 if no such parameter exists.
**/

    public static function tAtX(x0:Number, y0:Number, cx:Number, cy:Number, x1:Number, y1:Number, x:Number):Object
    {
      // quad. bezier coefficients
      var c0X:Number = x0;
      var c1X:Number = 2.0*(cx-x0);
      var c2X:Number = x0-2.0*cx+x1;

      var c:Number = c0X - x;
      var b:Number = c1X;
      var a:Number = c2X;
      
      var d:Number = b*b - 4*a*c;
      if( d < 0 )
      {
        return {t1:-1, t2:-1};
      }
      
      if( Math.abs(a) < 0.00000001 )
      {
        if( Math.abs(b) < 0.00000001 )
        {
          return {t1:-1, t2:-1};
        }
        else
        {
          return{t1:-c/b, t1:-1};
        }
      }
      
      d             = Math.sqrt(d);
      a             = 1/(a + a);
      var t0:Number = (d-b)*a;
      var t1:Number = (-b-d)*a;
      
      var result:Object = {t1:-1, t2:-1};
      if( t0 >= 0 && t0 <= 1 )
        result["t1"] = t0;
        
      if( t1 >= 0 && t1 <=1 )
      {
        if( t0 <= 0 && t0 <= 1 )
          result["t2"] = t1;
        else
          result["t1"] = t1;
      }
        
      return result;
    }
    
/**
* closestPointToBezier Find the closest point on a quadratic or cubic Bezier curve to an arbitrary point
*
* @param _curve:Geometry reference that must be a quadratic or cubic Bezier3
* @param _p:Point reference to <code>Point</code> to which the closest point on the Bezier curve is desired
*
* @return Number t-parameter of the closest point on the parametric curve.  Returns 0 if inputs are <code>null</code> or not a valid reference to a Bezier curve.
*
* This code is derived from the Graphic Gem, "Solving the Nearest-Point-On-Curve Problem", by P.J. Schneider, published in 'Graphic Gems', 
* A.S. Glassner, ed., Academic Press, Boston, 1990, pp. 607-611.
*
* @since 1.0
*
*/
    public function closestPointToBezier( _curve:Geometry, _p:Point ):Number
    {
      // Note - until issue is resolved with pointAt() for cubic Beziers, you should always used AdvancedCubicBezier for closest point to a cubic
      // Bezier when you need to visually identify the point in an application.
      if( _curve == null || _p == null )
      {
      	return 0;
      }
      
      // tbd - dispatch a warning event in this instance
      if( !(_curve is QuadraticBezier) && !(_curve is CubicBezier) )
      {
      	return 0;
      }
      
      // record distances from point to endpoints
      var p:Point       = _curve.pointAt(0);
      var deltaX:Number = p.x-_p.x;
      var deltaY:Number = p.y-_p.y;
      var d0:Number     = Math.sqrt(deltaX*deltaX + deltaY*deltaY);
      
      p             = _curve.pointAt(1);
      deltaX        = p.x-_p.x;
      deltaY        = p.y-_p.y;
      var d1:Number = Math.sqrt(deltaX*deltaX + deltaY*deltaY);
      
      var n:uint = (_curve is QuadraticBezier) ? 2 : 3;  // degree of input Bezier curve
      
      // array of control points
      var v:Array = new Array();
      if( n == 2 )
      {
        var quad:QuadraticBezier = _curve as QuadraticBezier;
        v[0]                     = new Point(quad.x0, quad.y0);
        v[1]                     = new Point(quad.cx, quad.cy);
        v[2]                     = new Point(quad.x1, quad.y1);
      }
      else
      {
        var cubic:CubicBezier = _curve as CubicBezier;
        v[0]                  = new Point(cubic.x0 , cubic.y0 );
        v[1]                  = new Point(cubic.cx , cubic.cy );
        v[2]                  = new Point(cubic.cx1, cubic.cy1);
        v[3]                  = new Point(cubic.x1 , cubic.y1 );
      }
      
      // instaead of power form, convert the function whose zeros are required to Bezier form
      var w:Array = toBezierForm(_p, v);
      
      // Find roots of the Bezier curve with control points stored in 'w' (algorithm is recursive, this is root depth of 0)
      var roots:Array = findRoots(w, 2*n-1, 0);
      
      // compare the candidate distances to the endpoints and declare a winner :)
      if( d0 < d1 )
      {
      	var tMinimum:Number = 0;
      	__dMinimum          = d0;
      }
      else
      {
      	tMinimum   = 1;
      	__dMinimum = d1;
      }
      
      // tbd - compare 2-norm squared
      for( var i:uint=0; i<roots.length; ++i )
      {
      	 var t:Number = roots[i];
      	 if( t >= 0 && t <= 1 )
      	 {
      	   p            = _curve.pointAt(t);
      	   deltaX       = p.x - _p.x;
      	   deltaY       = p.y - _p.y;
      	   var d:Number = Math.sqrt(deltaX*deltaX + deltaY*deltaY);
      	  
      	   if( d < __dMinimum )
      	   {
      	     tMinimum    = t;
      	     __dMinimum = d;
      	   }
      	 }
      }
      
      // tbd - alternate optima.
      return tMinimum;
    } 
    
    // compute control points of the polynomial resulting from the inner product of B(t)-P and B'(t), constructing the result as a Bezier
    // curve of order 2n-1, where n is the degree of B(t).
    private function toBezierForm(_p:Point, _v:Array):Array
    {
      var row:uint    = 0;  // row index
      var column:uint = 0;	// column index
      
      var c:Array = new Array();  // V(i) - P
      var d:Array = new Array();  // V(i+1) - V(i)
      var w:Array = new Array();  // control-points for Bezier curve whose zeros represent candidates for closest point to the input parametric curve
   
      var n:uint      = _v.length-1;    // degree of B(t)
      var degree:uint = 2*n-1;          // degree of B(t) . P
      
      var pX:Number = _p.x;
      var pY:Number = _p.y;
      
      for( var i:uint=0; i<=n; ++i )
      {
        var v:Point = _v[i];
        c[i]        = new Point(v.x - pX, v.y - pY);
      }
      
      var s:Number = Number(n);
      for( i=0; i<=n-1; ++i )
      {
      	v            = _v[i];
      	var v1:Point = _v[i+1];
      	d[i]         = new Point( s*(v1.x-v.x), s*(v1.y-v.y) );
      }
      
      var cd:Array = new Array();
      
      // inner product table
      for( row=0; row<=n-1; ++row )
      {
      	var di:Point  = d[row];
      	var dX:Number = di.x;
      	var dY:Number = di.y;
      	
      	for( var col:uint=0; col<=n; ++col )
      	{
      	  var k:uint = getLinearIndex(n+1, row, col);
      	  cd[k]      = dX*c[col].x + dY*c[col].y;
      	  k++;
      	}
      }
      
      // Bezier is uniform parameterized
      var dInv:Number = 1.0/Number(degree);
      for( i=0; i<=degree; ++i )
      {
      	w[i] = new Point(Number(i)*dInv, 0);
      }
      
      // reference to appropriate pre-computed coefficients
      var z:Array = n == 3 ? Z_CUBIC : Z_QUAD;
      
      // accumulate y-coords of the control points along the skew diagonal of the (n-1) x n matrix of c.d and z values
      var m:uint = n-1;
      for( k=0; k<=n+m; ++k ) 
      {
        var lb:uint = Math.max(0, k-m);
        var ub:uint = Math.min(k, n);
        for( i=lb; i<=ub; ++i) 
        {
          var j:uint     = k - i;
          var p:Point    = w[i+j];
          var index:uint = getLinearIndex(n+1, j, i);
          p.y           += cd[index]*z[index];
          w[i+j]         = p;
        }
      }
      
      return w;	
    }
    
    // convert 2D array indices in a k x n matrix to a linear index (this is an interim step ahead of a future implementation optimized for 1D array indexing)
    private function getLinearIndex(_n:uint, _row:uint, _col:uint):uint
    {
      // no range-checking; you break it ... you buy it!
      return _row*_n + _col;
    }
    
    // how many times does the Bezier curve cross the horizontal axis - the number of roots is less than or equal to this count
    private function crossingCount(_v:Array, _degree:uint):uint
    {
      var nCrossings:uint = 0;
      var sign:int        = _v[0].y < 0 ? -1 : 1;
      var oldSign:int     = sign;
      for( var i:int=1; i<=_degree; ++i) 
      {
        sign = _v[i].y < 0 ? -1 : 1;
        if( sign != oldSign ) 
          nCrossings++;
             
         oldSign = sign;
      }
      
      return nCrossings;
    }
    
    // is the control polygon for a Bezier curve suitably linear for subdivision to terminate?
    private function isControlPolygonLinear(_v:Array, _degree:uint):Boolean 
    {
      // Given array of control points, _v, find the distance from each interior control point to line connecting v[0] and v[degree]
    
      // implicit equation for line connecting first and last control points
      var a:Number = _v[0].y - _v[_degree].y;
      var b:Number = _v[_degree].x - _v[0].x;
      var c:Number = _v[0].x * _v[_degree].y - _v[_degree].x * _v[0].y;
    
      var abSquared:Number = a*a + b*b;
      var distance:Array   = new Array();       // Distances from control points to line
    
      for( var i:uint=1; i<_degree; ++i) 
      {
        // Compute distance from each of the points to that line
        distance[i] = a * _v[i].x + b * _v[i].y + c;
        if( distance[i] > 0.0 ) 
        {
          distance[i] = (distance[i] * distance[i]) / abSquared;
        }
        if( distance[i] < 0.0 ) 
        {
          distance[i] = -((distance[i] * distance[i]) / abSquared);
        }
      }
    
      // Find the largest distance
      var maxDistanceAbove:Number = 0.0;
      var maxDistanceBelow:Number = 0.0;
      for( i=1; i<_degree; ++i) 
      {
        if( distance[i] < 0.0 ) 
        {
          maxDistanceBelow = Math.min(maxDistanceBelow, distance[i]);
        }
        if( distance[i] > 0.0 ) 
        {
          maxDistanceAbove = Math.max(maxDistanceAbove, distance[i]);
        }
      }
    
      // Implicit equation for zero line
      var a1:Number = 0.0;
      var b1:Number = 1.0;
      var c1:Number = 0.0;
    
      // Implicit equation for "above" line
      var a2:Number = a;
      var b2:Number = b;
      var c2:Number = c + maxDistanceAbove;
    
      var det:Number  = a1*b2 - a2*b1;
      var dInv:Number = 1.0/det;
        
      var intercept1:Number = (b1*c2 - b2*c1)*dInv;
    
      //  Implicit equation for "below" line
      a2 = a;
      b2 = b;
      c2 = c + maxDistanceBelow;
        
      var intercept2:Number = (b1*c2 - b2*c1)*dInv;
    
      // Compute intercepts of bounding box
      var leftIntercept:Number  = Math.min(intercept1, intercept2);
      var rightIntercept:Number = Math.max(intercept1, intercept2);
    
      var error:Number = 0.5*(rightIntercept-leftIntercept);    
        
      return error < EPSILON;
    }
    
    // compute intersection of line segnet from first to last control point with horizontal axis
    private function computeXIntercept(_v:Array, _degree:uint):Number
    {
      var XNM:Number = _v[_degree].x - _v[0].x;
      var YNM:Number = _v[_degree].y - _v[0].y;
      var XMK:Number = _v[0].x;
      var YMK:Number = _v[0].y;
    
      var detInv:Number = - 1.0/YNM;
    
      return (XNM*YMK - YNM*XMK) * detInv;
    }
    
    // return roots in [0,1] of a polynomial in Bernstein-Bezier form
    private function findRoots(_w:Array, _degree:uint, _depth:uint):Array
    {  
      var t:Array = new Array(); // t-values of roots
      var m:uint  = 2*_degree-1;
      
      switch( crossingCount(_w, _degree) ) 
      {
        case 0: 
          return [];   
        break;
           
        case 1: 
          // Unique solution - stop recursion when the tree is deep enough (return 1 solution at midpoint)
          if( _depth >= MAX_DEPTH ) 
          {
            t[0] = 0.5*(_w[0].x + _w[m].x);
            return t;
          }
            
          if( isControlPolygonLinear(_w, _degree) ) 
          {
            t[0] = computeXIntercept(_w, _degree);
            return t;
          }
        break;
      }
 
      // Otherwise, solve recursively after subdividing control polygon
      var left:Array  = new Array();
      var right:Array = new Array();
       
      // child solutions
         
      subdivide(_w, 0.5, left, right);
      var leftT:Array  = findRoots(left,  _degree, _depth+1);
      var rightT:Array = findRoots(right, _degree, _depth+1);
     
      // Gather solutions together
      for( var i:uint= 0; i<leftT.length; ++i) 
        t[i] = leftT[i];
       
      for( i=0; i<rightT.length; ++i) 
        t[i+leftT.length] = rightT[i];
    
      return t;
    }
    
/**
* subdivide( _c:Array, _t:Number, _left:Array, _right:Array ) - deCasteljau subdivision of an arbitrary-order Bezier curve
*
* @param _c:Array array of control points for the Bezier curve
* @param _t:Number t-parameter at which the curve is subdivided (must be in (0,1) = no check at this point
* @param _left:Array reference to an array in which the control points, <code>Array</code> of <code>Point</code> references, of the left control cage after subdivision are stored
* @param _right:Array reference to an array in which the control points, <code>Array</code> of <code>Point</code> references, of the right control cage after subdivision are stored
* @return nothing 
*
* @since 1.0
*
*/
    public function subdivide( _c:Array, _t:Number, _left:Array, _right:Array ):void
    {
      var degree:uint = _c.length-1;
      var n:uint      = degree+1;
      var p:Array     = _c.slice();
      var t1:Number   = 1.0 - _t;
      
      for( var i:uint=1; i<=degree; ++i ) 
      {  
        for( var j:uint=0; j<=degree-i; ++j ) 
        {
          var vertex:Point = new Point();
          var ij:uint      = getLinearIndex(n, i, j);
          var im1j:uint    = getLinearIndex(n, i-1, j);
          var im1jp1:uint  = getLinearIndex(n, i-1, j+1);
          
          vertex.x = t1*p[im1j].x + _t*p[im1jp1].x;
          vertex.y = t1*p[im1j].y + _t*p[im1jp1].y;
          p[ij]    = vertex;
        }
      }
      
      for( j=0; j<=degree; ++j )
      {
      	 var index:uint = getLinearIndex(n, j, 0);
        _left[j]       = p[index];
      }
        
      for( j=0; j<=degree; ++j) 
      {
      	 index     = getLinearIndex(n, degree-j, j);
        _right[j] = p[index];
      }
    }
    
/**
 * quadRefine refines a quadratic Bezier curve in the interval [t1,t2], where t1 and t2 are in (0,1), t2 > t1
 * 
 * @param _q:AdvancedQuadraticBezier reference to quadratic Bezier curve to be refined
 * @param _t1:Number left point in refinement interval
 * @param _t2:Number right point in refinement interval
 * 
 * @return Object x0, y0, cx, cy, x1, and y1 properties are control points of quadratic bezier curve representing the segment of the original curve in [t1,t2]
 * returns a copy of the input quadratic bezier if input interval is invalid
 *
 * @since 1.2
 *
 */  
    public static function quadRefine(_q:AdvancedQuadraticBezier, _t1:Number, _t2:Number):Object
    {
      if( _t1 < 0 || _t2 > 1 || _t2 <= _t1 )
        return { x0:_q.x0, y0:_q.y0, cx:_q.cx, cy:_q.cy, x1:_q.x1, y1:_q.y1 };
      
      // four points defining two lines
      var p:Point = _q.pointAt(_t1);
      var x1:Number = p.x;
      var y1:Number = p.y;
      var x2:Number = (1-_t1)*_q.cx + _t1*_q.x1;
      var y2:Number = (1-_t1)*_q.cy + _t1*_q.y1;
      var x3:Number = (1-_t2)*_q.x0 + _t2*_q.cx;
      var y3:Number = (1-_t2)*_q.y0 + _t2*_q.cy;
      var x4:Number = (1-_t2)*_q.cx + _t2*_q.x1;
      var y4:Number = (1-_t2)*_q.cy + _t2*_q.y1;
      
      var o:Object = intersect(x1, y1, x2, y2, x3, y3, x4, y4);
      p            = _q.pointAt(_t2);
      
      return { x0:x1, y0:y1, cx:o.cx, cy:o.cy, x1:p.x, y1:p.y };
    }
    
    private static function intersect(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):Object
    {
      // tbd - haven't tested every path through this code yet - please feel free to do it for me so I can get back to the mundane
      // task of making a living while you score some bucks off my free code :)
      var deltaX1:Number = x2-x1;
      var deltaX2:Number = x4-x3;
      var d1Abs:Number   = Math.abs(deltaX1);
      var d2Abs:Number   = Math.abs(deltaX2);
      var m1:Number      = 0;
      var m2:Number      = 0;
      var pX:Number      = 0;
      var pY:Number      = 0;
      
      if( d1Abs <= 0.000001 )
      {
        pX = x1;
        m2   = (y3 - y4)/deltaX2;
        pY = (d2Abs <= 0.000001) ? (x1 + 3*(y1-x1)) : (m2*(x1-x4)+y4);
      }
      else if( d2Abs <= 0.000001 )
      {
        pX = x4;
        m1   = (y2 - y1)/deltaX1;
        pY = (d1Abs <= 0.000001) ? (x3 + 3*(x3-x4)) : (m1*(x4-x1)+y1);
      }
      else
      {
        m1 = (y2 - y1)/deltaX1;
        m2 = (y4 - y3)/deltaX2;
        
        if( Math.abs(m1) <= 0.000001 && Math.abs(m2) <= 0.000001 )
        {
          pX = 0.5*(x1 + x4);
          pY = 0.5*(y1 + y4);
        }
        else
        {
          var b1:Number = y1 - m1*x1;
          var b2:Number = y4 - m2*x4;
          pX            = (b2-b1)/(m1-m2);
          pY            = m1*pX + b1;
        }
      }
      
      return {cx:pX, cy:pY};
    }
  }
}