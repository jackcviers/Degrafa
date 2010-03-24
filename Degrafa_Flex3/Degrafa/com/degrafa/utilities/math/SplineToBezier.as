//
// SplineToBezier.as - This utility approximates a spline curve with a sequence of quadratic Beziers that can be inserted into the
// Degrafa command stack.  Instead of trying to minimize the total number of quads, the code produces an integral number of quads
// between knots.  This provides some utility for charting applications, allowing the construction of vertical 'strips' of a chart
// with a modest number of lines/curves.
//
// This code is derived from source bearing the following copyright notice
//
// copyright (c) 2005, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// Programmed by Jim Armstrong, (http://algorithmist.wordpress.com)
// Ported to Degrafa with full consent of author
//
/**
 * @version 1.1
 */
 
package com.degrafa.utilities.math
{
  import com.degrafa.geometry.splines.IPlottableSpline;
  import com.degrafa.geometry.splines.SplineTypeEnum;
  import com.degrafa.geometry.splines.QuadData;
  import com.degrafa.utilities.math.Gauss;
  
  public class SplineToBezier
  {
    private static const ONE_THIRD:Number = 1/3;
    private static const ZERO_TOL:Number  = 0.00000001;
    private static const LARGE:Number     = 1/ZERO_TOL;
    
    private var __count:uint;                // counts the number of knots in the spline
    private var __knots:Array;               // knot collection for the spline
    private var __mySpline:IPlottableSpline; // reference to current plottable spline for numerical integration
    private var __integral:Gauss;            // numerical integration by gaussian quadrature
    
    public function SplineToBezier()
    {
      __count = 0;
      
      __knots = new Array();
      
      __mySpline = null;
      
      __integral = new Gauss();
    }

/**
* <code>convert</code> Convert a plottable spline (one that implements the IPlottableSpline interface) to a sequence of quadratic Bezier curves,
* returning the raw information needed to construct the quadratic curves.
*
* @param _spline:IPlottableSpline Plottable Spline
* @param _tol:Number tolerance value for relative error (five percent is used for default, which is pretty tight)
* @default 0.05 
*
* @return Array a collection of two <code>Arrays</code>, the first off which is the <code>QuadData</code> instances describing the sequence of quadratic 
* Bezier curves that approximate the plottable spline.  The spline is approximated over the entire span of knots.  The second array contains a list of
* indices into the first array corresponding to the quadratic curves beginning at each segment.  For example, the second spline segment (index 1) is
* from knot 1 to knot 2.  Suppose the first array is named <code>quads</code>.  The second array is named </code>segments</code>.  The sequence of quad. 
* Beziers approximating that segment of the spline range from quads[segments[1]] to quads[segments[2]-1].  This allows the specific set of quad. Beziers
* spanning a specific knot set to be identified and used for highlighting those sections or creating new shapes based on that data.
*
* @since 1.0
*
*/
    public function convert(_spline:IPlottableSpline, _tol:Number=0.05):Array
    {
      if( _spline == null )
      {
        return [];
      }
       
      // access the knot collection
      __knots = _spline.knots;
      if( __knots.length == 0 )
      {
        return [];
      }
      
      if( _spline.type == SplineTypeEnum.CARTESIAN )
      {
        return __cartesianToBezier(_spline, _tol);
      }
      else
      {
        return __parametricToBezier(_spline, _tol);
      }
    }
    
    private function __cartesianToBezier(_spline:IPlottableSpline, _tol:Number):Array
    {
      if( _spline == null )
      {
        return [];
      }
      
      __mySpline         = _spline;
      var tol:Number     = Math.max(0.001,Math.abs(_tol));
      var quads:Array    = new Array();
      var segments:Array = new Array();
      __count            = __knots.length;
      
      if( __count == 1 )
      {
        var o:Object = __knots[0];
        return [ [new QuadData(o.X,o.Y,o.X,o.Y,o.X,o.Y)], [0] ] ;
      }
      
      if( __count == 2 )
      {
        o             = __knots[0];
        var x1:Number = o.X;
        var y1:Number = o.Y;
        
        o             = __knots[1];
        var x2:Number = o.X;
        var y2:Number = o.Y;
        
        return [ [new QuadData(x1, y1, 0.5*(x1+x2), 0.5*(y1+y2), x2, y2)], [0] ];
      }
      
      var q:Array    = new Array();
      var indx:Array = [0];
      
      // process each segment, producing an integral number of quads between each knot.
      for( var i:uint=0; i<__count-1; ++i )
      {
        var qSegment:Array = __subdivideCartesian(_spline, i, tol);
        indx[i+1]          = indx[i] + qSegment.length;
        
        q                  = q.concat(qSegment);
      }
      
      return [q, indx];
    }
    
    private function __parametricToBezier(_spline:IPlottableSpline, _tol:Number):Array
    {
      if( _spline == null )
      {
        return [];
      }
      
      // may merge paths for the special cases in the future
      __mySpline         = _spline;
      var tol:Number     = Math.max(0.001,Math.abs(_tol));
      var quads:Array    = new Array();
      var segments:Array = new Array();
      __count            = __knots.length;
      
      if( __count == 1 )
      {
        var o:Object = __knots[0];
        return [ [new QuadData(o.X,o.Y,o.X,o.Y,o.X,o.Y)], [0] ] ;
      }
      
      if( __count == 2 )
      {
        o             = __knots[0];
        var x1:Number = o.X;
        var y1:Number = o.Y;
        
        o             = __knots[1];
        var x2:Number = o.X;
        var y2:Number = o.Y;
        
        return [ [new QuadData(x1, y1, 0.5*(x1+x2), 0.5*(y1+y2), x2, y2)], [0] ];
      }
      
      var q:Array    = new Array();
      var indx:Array = [0];
      
      // process each segment, producing an integral number of quads between each knot.
      for( var i:uint=0; i<__count-1; ++i )
      {
        var qSegment:Array = __subdivideParametric(_spline, i, tol);
        indx[i+1]          = indx[i] + qSegment.length;
        
        q                  = q.concat(qSegment);
      }
      
      return [q, indx];
    }
    
    private function __subdivideCartesian(_spline:IPlottableSpline, _segment:uint, _tol:Number):Array
    {
      // first pass, check for an inflection point to subdivide - as we're dealing predominantly with cubic polynomials in between knots, there
      // will be at most two.  Return the one farthest from an endpoint as the parameter to subdivide the curve.  May modify to include stationary 
      // points in the future, if easy to compute. 
      var x1:Number = __inflect(_spline, _segment);
      if ( x1 == -1 )
      {
        x1 = 0.5*(__knots[_segment].X + __knots[_segment+1].X);
      }
      
      var q:Array          = new Array();
      var complete:Array   = new Array();
      var limit:uint       = 4;
      var finished:Boolean = false;
      
      // always begin with one subdivision - two quads; this often provides a tight enough fit without any further recursion
      var o:Object  = __knots[_segment];
      var x0:Number = o.X;
      var y0:Number = o.Y;
      
      var y1:Number = _spline.eval(x1); 
      
      // slope at each endpoint
      var m1:Number = _spline.derivative(x0);
      var m2:Number = _spline.derivative(x1);
      o             = __intersect(x0, y0, m1, x1, y1, m2);
       
      var quad:QuadData = new QuadData(x0, y0, o.px, o.py, x1, y1);
      q[0]              = quad;
      complete[0]       = false;
      
      o             = __knots[_segment+1];
      var x2:Number = o.X;
      var y2:Number = o.Y;
      m1            = m2;
      m2            = _spline.derivative(x2);
      o             = __intersect(x1, y1, m1, x2, y2, m2);
       
      quad = new QuadData(x1, y1, o.px, o.py, x2, y2);
      q[1]        = quad;
      complete[1] = false;
      
      // this approach could be implemented recursively, but I think it's more difficult to understand and recursive calls are usually computationally inefficient
      while( !finished )
      {
        // check each quad segment vs. closeness metric unless it's already completed
        for( var i:uint=0; i<q.length; ++i )
        {
          if( !complete[i] )
          {
            quad          = q[i];
            var d:Number  = __compare(quad, _spline);
            
            if( Math.abs(d) > _tol )
            {
              // subdivide
              var newX:Number = 0.5*(quad.x0 + quad.x1);
              var newY:Number = _spline.eval(newX);
              
              // slope at each new endpoint
              m1 = _spline.derivative(quad.x0);
              m2 = _spline.derivative(newX);
              o  = __intersect(quad.x0, quad.y0, m1, newX, newY, m2);
       
              var q1:QuadData = new QuadData(x0, y0, o.px, o.py, newX, newY);
              
              // replace existing quad
              q[i]        = q1;
              complete[i] = false;
      
              m1 = m2;
              m2 = _spline.derivative(quad.x1);
              o  = __intersect(newX, newY, m1, quad.x1, quad.y1, m2);
       
              var q2:QuadData = new QuadData(newX, newY, o.px, o.py, quad.x1, quad.y1);
              
              // add to the collective
              q.splice(i+1, 0, q2);
              complete.splice(i+1, 0, false);
              
              if( q.length >= limit )
              {
                return q;
              }
            }
            else
            {
              complete[i] = true; // finished with this one
            }   
          }
        }
        
        // are we finished - this is the simple and straightforward way to do it
        finished = true;
        for( var j:uint=0; j<complete.length; ++j )
        {
          finished = finished && complete[j];
        }
      }
      
      return q;
    }
    
    private function __subdivideParametric(_spline:IPlottableSpline, _segment:uint, _tol:Number):Array
    { 
      // in the future, this will test for inflection or stationary points, provided they are easy to compute.  For first version, use straight
      // midpoint subdivision.  Base spline is always uniform parameterized, which is used to compute t-at-knot.
      var n:Number  = __knots.length-1;
      var t0:Number = _segment/n;
      var t2:Number = (_segment+1)/n;
      var t1:Number = 0.5*(t0+t2);
      
      var t:Array = [t0, t1, t2];
      
      var q:Array          = new Array();
      var complete:Array   = new Array();
      var limit:uint       = 4;
      var finished:Boolean = false;
      
      // always begin with one subdivision - two quads; this often provides a tight enough fit without any further recursion
      var o:Object  = __knots[_segment];
      var x0:Number = o.X;
      var y0:Number = o.Y;
      var x1:Number = _spline.getX(t1);
      var y1:Number = _spline.getY(t1); 
      
      // slope at each endpoint
      var m1:Number = __getParametricDerivative(_spline, t0);
      var m2:Number = __getParametricDerivative(_spline, t1);
      o             = __intersect(x0, y0, m1, x1, y1, m2);
       
      var quad:QuadData = new QuadData(x0, y0, o.px, o.py, x1, y1);
      q[0]              = quad;
      complete[0]       = false;
      
      o             = __knots[_segment+1];
      var x2:Number = o.X;
      var y2:Number = o.Y;
      m1            = m2;
      m2            = __getParametricDerivative(_spline, t2);
      o             = __intersect(x1, y1, m1, x2, y2, m2);
      
      quad = new QuadData(x1, y1, o.px, o.py, x2, y2);
      q[1]        = quad;
      complete[1] = false;
      
      // this approach could be implemented recursively, but I think it's more difficult to understand and recursive calls are usually computationally inefficient
      while( !finished )
      {
        // check each quad segment vs. closeness metric unless it's already completed
        for( var i:uint=0; i<q.length; ++i )
        {
          if( !complete[i] )
          {
            quad          = q[i];
            var d:Number  = __compare(quad, _spline, t[i], t[i+1]);
            
            if( Math.abs(d) > _tol )
            {
              // subdivide
              t0              = t[i];
              t2              = t[i+1];
              t1              = 0.5*(t0 + t2);
              
              var newX:Number = _spline.getX(t1);
              var newY:Number = _spline.getY(t1);
              
              // slope at each new endpoint
              m1 = __getParametricDerivative(_spline, t0);
              m2 = __getParametricDerivative(_spline, t1);
              o  = __intersect(quad.x0, quad.y0, m1, newX, newY, m2);
       
              var q1:QuadData = new QuadData(x0, y0, o.px, o.py, newX, newY);
              
              // replace existing quad
              q[i]        = q1;
              complete[i] = false;
              
              t.splice(i+1, 0, t1);
      
              m1 = m2;
              m2 = __getParametricDerivative(_spline, t2);
              o  = __intersect(newX, newY, m1, quad.x1, quad.y1, m2);
       
              var q2:QuadData = new QuadData(newX, newY, o.px, o.py, quad.x1, quad.y1);
              
              // add to the collective
              q.splice(i+1, 0, q2);
              complete.splice(i+1, 0, false);
              
              if( q.length >= limit )
              {
                return q;
              }
            }
            else
            {
              complete[i] = true; // finished with this one
            }   
          }
        }
        
        // are we finished - this is the simple and straightforward way to do it
        finished = true;
        for( var j:uint=0; j<complete.length; ++j )
        {
          finished = finished && complete[j];
        }
      }
      
      return q;
    }
    
    private function __getParametricDerivative(_spline:IPlottableSpline, _t:Number):Number
    {
      // chain rule to the rescue :)
      var dy:Number = _spline.getYPrime(_t);
      var dx:Number = _spline.getXPrime(_t);
      if( Math.abs(dx) < ZERO_TOL )
      {
        return LARGE;
      }
      
      return dy/dx;
    }
    
    // compare the quad. Bezier approximation to the spline over an interval
    private function __compare(_quad:QuadData, _spline:IPlottableSpline, _t1:Number=0, _t2:Number=0):Number
    {
      // choosing two points on completely different types of curves that are 'comparable' in a meaningful way is difficult.  Given that two
      // of the three degrees of freedom in the quad. Bezier are taken by preserving slope at interpolation points, use total arc length of
      // the two curves as a measure of closeness.
      
      if( _spline.type == SplineTypeEnum.CARTESIAN )
      {
        // note that this method requires three unique points for the quad. Bezier. (i.e. no degenerate case where two control points coincide).
        // threre are also some numerical issues with this estimate that may occasionally cause it to incorrectly compute arc length.  So, in some
        // (pretty rare) cases, a couple extra quads may be produced.
      
        // Bezier arc length
        var ax:Number = _quad.x0 - 2*_quad.cx + _quad.x1;
        var ay:Number = _quad.y0 - 2*_quad.cy + _quad.y1;
        var bx:Number = 2*_quad.cx - 2*_quad.x0;
        var by:Number = 2*_quad.cy - 2*_quad.y0;
       
        var a:Number = 4*(ax*ax + ay*ay);
        var b:Number = 4*(ax*bx + ay*by);
        var c:Number = bx*bx + by*by;
       
        var abc:Number = 2*Math.sqrt(a+b+c);
        var a2:Number  = Math.sqrt(a);
        var a32:Number = 2*a*a2;
        var c2:Number  = 2*Math.sqrt(c);
        var ba:Number  = b/a2;

        var quadLength:Number = (a32*abc + a2*b*(abc-c2) + (4*c*a-b*b)*Math.log((2*a2+ba+abc)/(ba+c2)))/(4*a32);
        var sLength:Number = __integral.eval(__cartesianIntegrand, _quad.x0, _quad.x1, 5);
        return Math.abs(sLength-quadLength)/sLength;
      }
      else
      {
        // It's tempting to think that we could look at the difference between the quad. Bezier at t=0.5 and the parametric curve value at (t1+t2)/2, but 
        // there is no theory that guarantees these values are comparable, except if both curves were arc-length parameterized.  Some parametric curves
        // (especially complex shapes with lots of knots) bring out numerical issues with the closed-form solution of the elliptical integral for arc
        // length of the quad. Bezier, so we're going to kick it old school for a while until I have time to integrate a better approach.
        var s1:Number  = 0;
        var s2:Number  = 0;
        var x0:Number  = _quad.x0;
        var y0:Number  = _quad.y0;
        var c1X:Number = 2.0*(_quad.cx-_quad.x0);
        var c1Y:Number = 2.0*(_quad.cy-_quad.y0);
        var c2X:Number = x0-2.0*_quad.cx+_quad.x1;
        var c2Y:Number = y0-2.0*_quad.cy+_quad.y1;
        
        var bX:Number     = x0;
        var bY:Number     = y0;
        var myX:Number    = x0;
        var myY:Number    = y0;
        var deltaT:Number = (_t2-_t1)*0.02;
        var myT:Number    = _t1;
        
        for( var t:Number=0.05; t<1; t+=0.02 )
        {
          var t2:Number = t*t;
          var bX1:Number  = x0 + t*(c1X + t*c2X);
          var bY1:Number  = y0 + t*(c1Y + t*c2Y);
          var dX:Number   = bX1 - bX;
          var dY:Number   = bY1 - bY;
          
          s1 += Math.sqrt(dX*dX + dY*dY);
          bX  = bX1;
          bY  = bY1;
          
          myT            += deltaT;
          var newX:Number = _spline.getX(myT);
          var newY:Number = _spline.getY(myT);
          dX              = newX - myX;
          dY              = newY - myY;
          s2             += Math.sqrt(dX*dX + dY*dY);
          
          myX = newX;
          myY = newY;
        }
        
        dX = _quad.x1 - bX;
        dY = _quad.y1 - bY;
        dX = bX1 - bX;
        dY = bY1 - bY;
          
        s1 += Math.sqrt(dX*dX + dY*dY);
        
        dX  = _quad.x1 - myX;
        dY  = _quad.y1 - myY;
        s2 += Math.sqrt(dX*dX + dY*dY);
        
        return( Math.abs(s1-s2)/s1 );
      }
    }
    
    // compute inflection points for the cubic curve in between spline knots (return -1 if no inflection points exist) - there is an implicit
    // assumption of dealing exclusively with cubic splines.  this method will be fully implemented in a future release.
    private function __inflect(_spline:IPlottableSpline, _segment:uint):Number
    {
      // extract the polynomial coefficients for this segment
      var o:Object   = _spline.getCoef(_segment);
      if( o == null )
      {
        return -1;
      }
      
      var p0X:Number = o.p0X;
      var p0Y:Number = o.p0Y;
      var p1X:Number = o.p1X;
      var p1Y:Number = o.p1Y;
      var p2X:Number = o.p2X;
      var p2Y:Number = o.p2Y;
      var p3X:Number = o.p3X;
      var p3Y:Number = o.p3Y;
      
      var t:Number = 0.5;
      if( _spline.type == SplineTypeEnum.CARTESIAN )
      {
        t = 0.5*(__knots[_segment].X + __knots[_segment+1].X);
      }
      
      // this is a placeholder - will be fully implemented in a future release
      return t;
    }
    
    // compute intersection of line with slope m1 through p0 and line with slope m2 through p2
    private function __intersect(_p0X:Number, _p0Y:Number, _m1:Number, _p2X:Number, _p2Y:Number, _m2:Number):Object
    {
      var px:Number = 0;
      var py:Number = 0;
      
      if( Math.abs(_m1) >= LARGE )
      {
        px  = _p0X;
        py  = (Math.abs(_m2) >= LARGE) ? (_p0Y + 3*(_p0Y-_p0X)) : (_m2*(_p0X-_p2X)+_p2Y);
      }
      else if( Math.abs(_m2) >= LARGE )
      {
        px = _p2X;
        py = (Math.abs(_m1) >= LARGE) ? (_p2Y + 3*(_p2Y-_p0X)) : (_m1*(_p2X-_p0X)+_p0Y);
      }
      else
      { 
        if( Math.abs(_m1-_m2) <= 0.05 )
        {
          // lines nearly parallel, meaning no intersection or the difference in slope is sufficiently small that the intersection will be well outside
          // where we would like a control point to be positioned.  This is subject to some future tweaking :)
          px = 0.5*(_p0X+_p2X);
          py = 0.5*(_p0Y+_p2Y);
        }
        else
        {
          var b1:Number = _p0Y - _m1*_p0X;
          var b2:Number = _p2Y - _m2*_p2X;
          px            = (b2-b1)/(_m1-_m2);
          py            = _m1*px + b1;
          
          if( __mySpline.type == SplineTypeEnum.CARTESIAN && (px >= _p2X || px <= _p0X) )
          {
            px = 0.5*(_p0X+_p2X);
            py = 0.5*(_p0Y+_p2Y);
          }
          
          // quad must have unique control points
          if( (Math.abs(px-_p0X) < 0.0000001 && Math.abs(py-_p0Y) < 0.0000001) || 
              (Math.abs(px-_p2X) < 0.0000001 && Math.abs(py-_p2Y) < 0.0000001) )
          {
            px += 1;
            py += 1;
          }
        }
      }
      
      return {px:px, py:py}
    }
    
    // arc-length integrand for spline in cartesian form
    private function __cartesianIntegrand(_x:Number):Number
    {
      var d:Number = __mySpline.derivative(_x);
      
      return Math.sqrt( 1 + d*d );
    }
    
   
  }
}