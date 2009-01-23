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
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry
{	
	 import com.degrafa.IGeometry;
	 import com.degrafa.geometry.utilities.GeometryUtils;
	
	 import flash.display.Graphics;
	 import flash.geom.Rectangle;
	 import flash.geom.Point;
     
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("QuadraticBezier.png")]

	[Bindable]	
	/**
 	*  The AdvancedQuadraticBezier element draws a quadratic Bézier using the specified 
 	* start point, end point and control point and contains several additional methods
 	* that are useful in advanced applications.
 	*  
 	*  
 	**/	
	 public class AdvancedQuadraticBezier extends QuadraticBezier
	 {
		  // bezier polynomial coefficients
    private var _c0X:Number;
    private var _c0Y:Number;
    private var _c1X:Number;
    private var _c1Y:Number;
    private var _c2X:Number;
    private var _c2Y:Number;
  
		/**
	 	* Constructor.
	 	*  
	 	* <p>The advanced quadratic Bézier constructor accepts 6 optional arguments that define it's 
	 	* start, end and controls points.</p>
	 	* 
	 	* @param x0 A number indicating the starting x-axis coordinate.
	 	* @param y0 A number indicating the starting y-axis coordinate.
	 	* @param cx A number indicating the control x-axis coordinate. 
	 	* @param cy A number indicating the control y-axis coordinate.
	 	* @param x1 A number indicating the ending x-axis coordinate.
	 	* @param y1 A number indicating the ending y-axis coordinate. 
	 	*/		
		  public function AdvancedQuadraticBezier(x0:Number=NaN,y0:Number=NaN,cx:Number=NaN,cy:Number=NaN,x1:Number=NaN,y1:Number=NaN)
		  {
			   super();
			
			   this.x0 = x0;
			   this.y0 = y0;
			   this.cx = cx;
			   this.cy = cy;
			   this.x1 = x1;
			   this.y1 = y1;
		  }
				
		/**
		* @inheritDoc 
		**/
		  override public function preDraw():void
		  {
		    // i should just call super.preDraw() then add the new stuff, but this reminds me what is going on under the hood :)
			   if( invalidated )
			   {
				    commandStack.length=0;
				
				    commandStack.resetBounds();
				
				    commandStack.addMoveTo(x0,y0);
				    commandStack.addCurveTo(cx,cy,x1,y1);
				
				    if( close )
					     commandStack.addLineTo(x0,y0);	
				
				    getBezierCoef();
				    invalidated = false;
			   }
		  }
  
/**
* interpolate
*
* <p>Compute control points so that quadratic Bezier passes through three points at the specified parameter value.
*
* @param _points:Array - array of three <code>Point</code> references, representing the coordinates of the interpolation points.
*
* @return Number the parameter value in [0,1] at which the Bezier curve passes through the second control point (determined by a chord-length parameterization).
* A negative value is returned if less than three interpolation points are provided.
*
*/
    public function interpolate(points:Array):Number
    {
      // compute t-value using chord-length parameterization
      if( points.length < 3 )
      {
        return -1;
      }
      
      var p0:Point  = points[0];
      var p1:Point  = points[1];
      var p2:Point  = points[2];
      var dX:Number = p1.x - p0.x;
      var dY:Number = p1.y - p0.y;
      var d1:Number = Math.sqrt(dX*dX + dY*dY);
      var d:Number  = d1;

      dX = p2.x - p1.x;
      dY = p2.y - p1.y;
      d += Math.sqrt(dX*dX + dY*dY);

      var t:Number = d1/d;

      var t1:Number    = 1.0-t;
      var tSq:Number   = t*t;
      var denom:Number = 2.0*t*t1;

      x0 = p0.x;
      y0 = p0.y;

      cx = (p1.x - t1*t1*p0.x - tSq*p2.x)/denom;
      cy = (p1.y - t1*t1*p0.y - tSq*p2.y)/denom;

      x1 = p2.x;
      y1 = p2.y;

      getBezierCoef();
      return t;
    }
    
/**
* tAtMinX
* 
* <p>Find t-parameter at which the x-coordinate is a minimum.</p>
*
* @return Number Parameter value in [0,1] at which the qudratic Bezier curve's x-coordinate is a minimum
*
* @since 1.0
*
*/
    public function tAtMinX():Number
    {
      var denom:Number = (x0 - 2*cx + x1);
      var tStar:Number = 0;
      if( Math.abs(denom) > 0.0000001 )
        tStar = (x0 - cx)/denom;
      
      var t:Number    = 0;
      var minX:Number = x0;
     
      if( x1 < minX )
      {
        t    = 1;
        minX = x1;  
      }
      
      if( tStar > 0 && tStar < 1 )
      {
        if( pointAt(tStar).x < minX )
        {
          t = tStar;  
        }  
      }
      
      return t;
    }
    
/**
* tAtMaxX
*
* <p>Find t-parameter at which the x-coordinate is a maximum.</p>
*
* @return Number Parameter value in [0,1] at which the quadratic Bezier curve's x-coordinate is a maximum.
*
*/
    public function tAtMaxX():Number
    {
      var denom:Number = (x0 - 2*cx + x1);
      var tStar:Number = 0;
      if( Math.abs(denom) > 0.0000001 )
        tStar = (x0 - cx)/denom;
        
      var t:Number     = 0;
      var maxX:Number  = x0;
     
      if( x1 > maxX )
      {
        t    = 1;
        maxX = x1;  
      }
      
      if( tStar > 0 && tStar < 1 )
      {
        if( pointAt(tStar).x > maxX )
        {
          t = tStar;  
        }  
      }
      
      return t;
    }
    
/**
* tAtMinY
*
* <p>Find t-parameter at which the y-coordinate is a minimum.</p<>
*
* @return Number - Parameter value in [0,1] at which the quadratic Bezier curve's y-coordinate is a minimum.
*
*/
    public function tAtMinY():Number
    {
      var denom:Number = (y0 - 2*cy + y1);
      var tStar:Number = 0;
      if( Math.abs(denom) > 0.0000001 )
        tStar = (y0 - cy)/denom;
        
      var t:Number     = 0;
      var minY:Number  = y0;
     
      if( y1 < minY )
      {
        t    = 1;
        minY = y1;  
      }
      
      if( tStar > 0 && tStar < 1 )
      {
        if( pointAt(tStar).y < minY )
        {
          t = tStar;  
        }  
      }
      
      return t;
    }
    
/**
* tAtMaxY
*
* <p>Find t-parameter at which the y-coordinate is a maximum.</p>
*
* @return Number Parameter value in [0,1] at which the quadratic Bezier curve's y-coordinate is a maximum.
*
*/
    public function tAtMaxY():Number
    {
      var denom:Number = (y0 - 2*cy + y1);
      var tStar:Number = 0;
      if( Math.abs(denom) > 0.0000001 )
        tStar = (y0 - cy)/denom;
        
      var t:Number    = 0;
      var maxY:Number = y0;
     
      if( y1 > maxY )
      {
        t    = 1;
        maxY = y1;  
      }
      
      if( tStar > 0 && tStar < 1 )
      {
        if( pointAt(tStar).y > maxY )
        {
          t = tStar;  
        }  
      }
      
      return t;
    }
    
/**
* yAtX
*
* <p>Return the set of y-coordinates corresponding to the input x-coordinate.</p>
*
* @param _x:Number x-coordinate at which the desired y-coordinates are desired
*
* @return Array set of (t,y)-coordinates at the input x-coordinate provided that the x-coordinate is inside the range
* covered by the quadratic Bezier in [0,1]; that is there must exist t in [0,1] such that Bx(t) = _x.  If the input
* x-coordinate is not inside the range covered by the Bezier curve, the returned array is empty.  Otherwise, the
* array contains either one or two y-coordinates.  There are issues with curves that are exactly or nearly (for
* numerical purposes) vertical in which there could theoretically be an infinite number of y-coordinates for a single
* x-coordinate.  This method does not work in such cases, although compensation might be added in the future.
*
* <p>Each array element is a reference to an <code>Object</code> whose 't' parameter represents the Bezier t parameter.  The
* <code>Object</code> 'y' property is the corresponding y-value.  The returned (t,y) coordinates may be used by the caller
* to determine which of two returned y-coordinates might be preferred over the other.</p>
*
*/
    public function yAtX(_x:Number):Array
    {
      if( isNaN(_x) )
      {
        return [];
      }
      
      // check bounds
      var xMax:Number = pointAt(tAtMaxX()).x;
      var xMin:Number = pointAt(tAtMinX()).x;
      
      if( _x < xMin || _x > xMax )
      {
        return [];
      }
      
      // the necessary y-coordinates are the intersection of the curve with the line x = _x.  The curve is generated in the
      // form c0 + c1*t + c2*t^2, so the intersection satisfies the equation Bx(t) = _x or Bx(t) - _x = 0, or c0x-_x + c1x*t + c2x*t^2 = 0,
      // which is quadratic in t.  I wonder what formula can be used to solve that ????
      getBezierCoef();
        
      // this is written out in individual steps for clarity
      var c:Number = _c0X - _x;
      var b:Number = _c1X;
      var a:Number = _c2X;
      
      var d:Number = b*b - 4*a*c;
      if( d < 0 )
      {
        return [];
      }
      
      d             = Math.sqrt(d);
      a             = 1/(a + a);
      var t0:Number = (d-b)*a;
      var t1:Number = (-b-d)*a;
      
      var result:Array = new Array();
      if( t0 <= 1 )
        result.push( {t:t0, y:pointAt(t0).y} );
        
      if( t1 >= 0 && t1 <=1 )
        result.push( {t:t1, y:pointAt(t1).y} );
        
      return result;
    }

/**
* join
*
* <p>Given the current <code>AdvancedQuadraticBezier</code> and an arbitrary point, return a new <code>AdvancedQuadraticBezier</code> instance so that the new quadratic
* Bezier interpolates the input point and matches tangent with the current quadratic Bezier at its origin.  In other words, given the current (x0,y0), (cx,cy), and (x1,y1),
* return a new <code>AdvancedQuadraticBezier</code> with parameters (w0,u0), (zx,zy), and (w1,u1) so that w0 = x1, u0 = y1, and the segment from (cx,cy) to (x1,y1) and
* (w0,u0) to (zx,zy) have the same slope.  This is one prelude to a more general quadratic spline.</p>
*
* @param _x:Number x-coordinate of final interpolation point of output quadratic Bezier.
* @param _y:Number y-coordinate of final interpolation point of output quadratic Bezier.
* @param _tension:uint - reserved for future use
*
* @return <code>AdvancedQuadraticBezier</code> reference to quadratic Bezier that can be considered an 'add on' curve to the current quadratic bezier with matching
* tangents at the join (x1,y1).  Note that the algorithm is not yet complete, so this method should be viewed as experimental.
*
*/
    public function join(_x:Number, _y:Number, _tension:uint=5):AdvancedQuadraticBezier
    {
      // tension parameter not yet implemented
      var deltaX:Number  = x1 - cx;
      var deltaX1:Number = _x - x1;
      var deltaY:Number  = y1 - cy;
      var m1:Number      = 0;
      var m2:Number      = 0;
      var pX:Number      = 0;
      var pY:Number      = 0;
      
      if( deltaX*deltaX1 >= 0 )
      {
        if( Math.abs(deltaX) <= 0.000000001 )
        {
          // m2 = 0
          pY = _y;
          pX = x1;
        }
        else if( Math.abs(deltaY) <= 0.000000001 )
        {
          // m2 = +inf
          pX = _x;
          pY = y1;
        }
        else
        {
          m1            = deltaY/deltaX;
          m2            = -1/m1;
          var b1:Number = y1 - m1*x1;
          var b2:Number = _y - m2*_x;
          pX            = (b2-b1)/(m1-m2);
          pY            = m1*pX + b1;
        }
      }
      else
      {
        // placeholder - this will be replaced by projection as sometimes the indication of direction is not accurate
        var m:Number = 4/3;
        pX           = cx + m*(x1-cx);
        pY           = cy + m*(y1-cy);
      }
      
      return new AdvancedQuadraticBezier(x1,y1,pX,pY,_x,_y);
    }

    // recompute polynomial coefficients
    private function getBezierCoef():void
    { 
				  _c0X = x0;
	     _c0Y = y0;

      _c1X = 2.0*(cx-x0);
      _c1Y = 2.0*(cy-y0);

      _c2X = x0-2.0*cx+x1;
      _c2Y = y0-2.0*cy+y1;
    }
  }
}