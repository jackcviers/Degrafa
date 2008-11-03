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
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.utilities{
	

	import com.degrafa.geometry.command.CommandStack;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	* A helper utility class for various geometric calculations.
	**/
	public class GeometryUtils
	{
		//dividing by 2 is frequently required
		private static var half:Number = 0.5;
		/**
		* Calculates the barycenter of a quadratic bezier curve.
		*  
		* @param a A number indicating the start axis coordinate.
		* @param a A number indicating the control axis coordinate.
		* @param a A number indicating the end axis coordinate.
		* @param t A number indicating the accuracy.
		* 
		* @return The barycenter of the given points.  
		**/
		public static function barycenter(a:Number, b:Number, c:Number, t:Number):Number{ 
			return (1-t)*(1-t)*a + 2*(1-t)*t*b + t*t*c; 
		}
		
		/**
		* Calculates the perimeter of a quadratic bezier curve
		* 
		* @param x A number indicating the starting x-axis coordinate.
	 	* @param y A number indicating the starting y-axis coordinate.
	 	* @param cx A number indicating the control x-axis coordinate. 
	 	* @param cy A number indicating the control y-axis coordinate.
	 	* @param x1 A number indicating the ending x-axis coordinate.
	 	* @param y1 A number indicating the ending y-axis coordinate. 
		* 
		* @return The perimeter distance for the bezier curve.
		**/
		public static function perimeter(x:Number,y:Number,cx:Number,cy:Number,x1:Number,y1:Number):Number{ 
		   
		    var oldX:Number = x; 
		    var oldY:Number = y; 
		    var distance:Number = 0; 
		    var posx:Number;
		    var posy:Number;
		    var dx:Number;
		    var dy:Number;
		    var dist:Number;
		    
		    for(var i:Number=0;i<=1;i+=0.001){ 
		       	posx = barycenter(x,cx,x1,i); 
		       	posy = barycenter(y,cy,y1,i); 
		       	dx = Math.abs(posx - oldX); 
		       	dy = Math.abs(posy - oldY); 
		       	dist = Math.sqrt((dx*dx)+(dy*dy)); 
		       	distance+=dist; 
		       	oldX = posx; 
		    	oldY = posy; 
		    } 
		    
		    return distance; 
		} 
		
		/**
		* Returns a point on a quadratic bezier curve.
		**/
		public static function pointOnQuadraticCurve(t:Number, x:Number,y:Number,cx:Number,cy:Number,x1:Number,y1:Number):Object{
			var v:Number = t / 100;
			
			return {x:x + v*(2*(1-v)*(cx-x) + v*(x1 - x)),y:y + v*(2*(1-v)*(cy-y) + v*(y1 - y))};
		}
		
		//optimization:reuse a single Rectangle instance rather than creating new Rectangle instances for the bezierbounds calc
		private static var bezBoundsRect:Rectangle = new Rectangle();
		
		/**
		* Return the tight bounding rectangle for a bezier curve.
		* 
		* @param x A number indicating the starting x-axis coordinate.
	 	* @param y A number indicating the starting y-axis coordinate.
	 	* @param cx A number indicating the control x-axis coordinate. 
	 	* @param cy A number indicating the control y-axis coordinate.
	 	* @param x1 A number indicating the ending x-axis coordinate.
	 	* @param y1 A number indicating the ending y-axis coordinate. 
		* 
		* @return The bounds rectangle for the bezier curve.  
		**/
		public static function bezierBounds(x:Number,y:Number,cx:Number,cy:Number,x1:Number,y1:Number):Rectangle{
			
			
			var t: Number;
			
			if (x == cx && cx == x1)
			{
				//vertical line
				bezBoundsRect.x = x;
				bezBoundsRect.y = Math.min(y, y1);
				bezBoundsRect.width = 0.0001;
				bezBoundsRect.height = Math.abs(y1 - y);
				return bezBoundsRect;
			}
			if (y == cy && cy == y1)
			{
				//horizontal line
				bezBoundsRect.x = Math.min(x,x1);
				bezBoundsRect.y = y;
				bezBoundsRect.width = Math.abs(x1 - x);
				bezBoundsRect.height = 0.0001;
				return bezBoundsRect;
			}
			//-- yMin
			if( y > y1 ){	
				if( cy > y1 ){ 
					bezBoundsRect.y = y1;
				}
				else{
					t = -( cy - y ) / ( y1 - 2 * cy + y );
					bezBoundsRect.y=( 1 - t ) * ( 1 - t ) * y + 2 * t * ( 1 - t ) * cy + t * t * y1;
				}
			}
			else{
				if( cy > y ){
					bezBoundsRect.y = y;
				} 
				else{
					t = -( cy - y ) / ( y1 - 2 * cy + y );
					bezBoundsRect.y=( 1 - t ) * ( 1 - t ) * y + 2 * t * ( 1 - t ) * cy + t * t * y1;
				}
			}
			
			//-- yMax
			if( y > y1 ){	
				if( cy < y ){ 
					bezBoundsRect.bottom=y
				}
				else{
					t = -( cy - y ) / ( y1 - 2 * cy + y );
					bezBoundsRect.bottom=( 1 - t ) * ( 1 - t ) * y + 2 * t * ( 1 - t ) * cy + t * t * y1;
				}
			}
			else{
				if( y1 > cy ){
					bezBoundsRect.bottom = y1;
				} 
				else{
					t = -( cy - y ) / ( y1 - 2 * cy + y );
					bezBoundsRect.bottom =( 1 - t ) * ( 1 - t ) * y + 2 * t * ( 1 - t ) * cy + t * t * y1;
				}
			}
			
			//-- xMin
			if( x > x1 ){	
				if( cx > x1 ){
					bezBoundsRect.x = x1;
				} 
				else{
					t = -( cx - x ) / ( x1 - 2 * cx + x );
					bezBoundsRect.x = ( 1 - t ) * ( 1 - t ) * x + 2 * t * ( 1 - t ) * cx + t * t * x1;
				}
			}
			else{
				if( cx > x ){ 
					bezBoundsRect.x = x;
				}
				else{
					t = -( cx - x ) / ( x1 - 2 * cx + x );
					bezBoundsRect.x = ( 1 - t ) * ( 1 - t ) * x + 2 * t * ( 1 - t ) * cx + t * t * x1;
				}
			}
		
			//-- xMax
			if( x > x1 ){	
				if( cx < x ){ 
					bezBoundsRect.right = x;
				}
				else{
					t = -( cx - x ) / ( x1 - 2 * cx + x );
					bezBoundsRect.right =( 1 - t ) * ( 1 - t ) * x + 2 * t * ( 1 - t ) * cx + t * t * x1;
				}
			}
			else{
				if( cx < x1 ){ 
					bezBoundsRect.right = x1;
				}
				else{
					t = -( cx - x ) / ( x1 - 2 * cx + x );
					bezBoundsRect.right = ( 1 - t ) * ( 1 - t ) * x + 2 * t * ( 1 - t ) * cx + t * t * x1;
				}
			}
			return bezBoundsRect;
			
		}	

		/**
		* LineIntersects
		* Returns the point of intersection between two lines
		* @param p1, p2 (Point) line 1 point struct
		* @param p3, p4 (Point) line 2 point struct
		* @return Point (Point object of intersection)
		*/

		public static function lineIntersects (p1:Point, p2:Point, p3:Point, p4:Point):Point {
			var x1:Number = p1.x; 
			var y1:Number = p1.y;
			var x4:Number = p4.x; 
			var y4:Number = p4.y;
		    var dx1:Number = p2.x - x1;
		    var dx2:Number = p3.x - x4;
	
			var intersectPoint:Point = new Point()
		
			if (!(dx1 || dx2)){
				
				intersectPoint.x=0;
				intersectPoint.y=0;
			
			 	//return NaN;
			}
			
			var m1:Number = (p2.y - y1) / dx1;
			var m2:Number = (p3.y - y4) / dx2;
			
			if (!dx1){
				intersectPoint.x=x1;
				intersectPoint.y=m2 * (x1 - x4) + y4;
				return intersectPoint;
			} 
			else if (!dx2){
				intersectPoint.x=x4;
				intersectPoint.y=m1 * (x4 - x1) + y1;
				return intersectPoint;
			}
			
			var xInt:Number = (-m2 * x4 + y4 + m1 * x1 - y1) / (m1 - m2);
	   		var yInt:Number = m1 * (xInt - x1) + y1;
	   			
			intersectPoint.x=xInt;
			intersectPoint.y=yInt;
			
			return intersectPoint;
			
		}
		
		/**
		* MidPoint
		* Returns the midpoint Point of 2 Point structures
		* @param p1 Point Struc 1
		* @param p2 Point Struc 2
		* @return Point (the midpoint of the 2 points)
		*/
		public static function midPoint(p1:Point, p2:Point):Point{
			return new Point((p1.x + p2.x)*half,(p1.y + p2.y)*half);
		}
		
		
		
		/**
		* SplitBezier
		* Divides a cubic bezier curve into two cubic bezier curve definitions
		* 
		* @param p1 (Point) endpoint 1
		* @param c1 (Point) control point 1
		* @param c2 (Point)control point 2
		* @param p2 (Point) endpoint 2
		* @return Object (object with two cubic bezier definitions, b0 and b1) 
		*/
		public static function splitBezier(p1:Point, c1:Point, c2:Point, p2:Point):Object{	    						
		   
		    var p01:Point = midPoint(p1, c1);
		    var p12:Point = midPoint(c1, c2);
		    var p23:Point = midPoint(c2, p2);
		    var p02:Point = midPoint(p01, p12);
		    var p13:Point = midPoint(p12, p23);
		    var p03:Point = midPoint(p02, p13);
						
			return { b0:{p1:p1, c1:p01, c2:p02, p2:p03}, b1:{p1:p03, c1:p13, c2:p23, p2:p2} };
			
		}
	
		/**
		* Round a number a specified number of decimal places.
		* 
		* @param input The number to round.
		* @param input The number of deciaml points to round to.
		* 
		* @return The resulting rounded number.     
   		**/ 
		public static function roundTo(input:Number, digits:Number):Number{
			return Math.round(input*Math.pow(10, digits))/Math.pow(10, digits);
		}

		
		/**
		* Convert Degress to radius.
		* 
		* @param angle A angle value to convert.
		* 
		* @return The resulting number converted to a radius.     
   		**/  
		public static function degressToRadius(angle:Number):Number{
			return angle*(Math.PI/180);
		}
		
		/**
		* Convert radius to degrees.
		* 
		* @param angle A angle radius to convert.
		* 
		* @return The resulting number converted to degress.     
   		**/
		public static function radiusToDegress(angle:Number):Number{
			return angle*(180/Math.PI);
		}

		/**
		* Rotate a point by a degrees.
		* 
		* @param point The point to rotate.
		* @param degrees A radius to rotate.
		* 
		* @return The transformed Point point object.     
   		**/  
		public static function rotatePoint(value:Point,angle:Number):Point{
			var radius:Number = Math.sqrt(Math.pow(value.x, 2)+Math.pow(value.y, 2));
			var angle:Number = Math.atan2(value.y, value.x)+degressToRadius(angle);
			return new Point(roundTo(radius*Math.cos(angle), 3), roundTo(radius*Math.sin(angle), 3));
		}
		
		/**
		* Rotate a point around a given center point by degrees.
		* 
		* @param point The point to rotate.
		* @param centerPoint the center point that point should be roatated around.
		* @param degrees A radius to rotate.
		* 
		* @return The transformed Point point object.     
   		**/  
		public static function rotatePointOnCenterPoint(point:Point,centerPoint:Point,degrees:Number):Point{
			var tempReturnPoint:Point = new Point();
			var radians:Number = (degrees/180)*Math.PI;
			
			tempReturnPoint.x = centerPoint.x + ( Math.cos(radians) * 
			(point.x - centerPoint.x) - Math.sin(radians) * 
			(point.y - centerPoint.y));
			
		    tempReturnPoint.y = centerPoint.y + ( Math.sin(radians) * 
		    (point.x - centerPoint.x) + Math.cos(radians) * 
		    (point.y - centerPoint.y) )
							
			return tempReturnPoint;
			
		}
		
		//performance/optimization (assumption only:avoid local variable creation in recursive function calls)
		//the following external variable references are used to avoid local variable/Number object creation on recursive calls
		//they are not required as local variables/new instances by recursion in the cubicToQuadratic function
		private static var sx:Number;
		private static var sy:Number;
		private static var m1:Number;
		private static var m2:Number;
		private static var m3:Number;
		private static var dx:Number;
		private static var dy:Number;
		private static var dx1:Number;
		private static var dx2:Number;
		private static var returnResult:Array;
		/**
		* CubicToQuadratic
		* <p>Approximates a cubic bezier with as many quadratic bezier segments (n) as required 
		* to achieve a specified tolerance. </p>
		* 
		* @param p1x first endpoint x coord
		* @param p1y first endpoint y coord
		* @param c1x 1st control point x coord
		* @param c1y 1st control point y coord
		* @param c2x 2nd control point x coord
		* @param c2y 2nd control point y coord
		* @param p2x last endpoint x coord
		* @param p2y last endpoint y coord
		* @param k tolerance (low number = most accurate result)
		* @param commandStack will contain the path of quadratic bezier curves that closely approximates the original cubic bezier curve
		*/
	 	public static function cubicToQuadratic(p1x:Number,p1y:Number, c1x:Number,c1y:Number, c2x:Number,c2y:Number, p2x:Number,p2y:Number, k:Number, commandStack:CommandStack):Array{
			
			//prepare the return array
			if(!returnResult){
				returnResult = [];
			}
			
			// find intersection between bezier arms (intersection point calculated as coords sx,xy)
			dx1= c1x - p1x;
			dx2 = c2x - p2x;
			if (p1y == p2y && c1y == p1y && c2y == p2y)
			{
				//horizontal line: store it as a lineTo in commandStack
				//todo: consider the possible case where the control points extend beyond the anchor points... (not yet accounted for - need to check SVG standard)
				returnResult.push(commandStack.addLineTo(p2x, p2y));
				return returnResult;
			}
			if (!dx1 && !dx2 && p1x==p2x)
			{
				//vertical line: store it as a lineTo in commandStack
				//todo: consider the possible case where the control points extend beyond the anchor points... (not yet accounted for - need to check SVG standard)
				returnResult.push(commandStack.addLineTo(p2x, p2y));
				return returnResult;

			}
			else if (!dx1){
				sx=p1x;
				sy = ((c2y - p2y) / dx2) * (p1x - p2x) + p2y;
				dx = (p1x + p2x + sx * 4 - (c1x + c2x) * 3) * .125;
				dy = (p1y + p2y + sy * 4 - (c1y + c2y) * 3) * .125;
			} 
			else if (!dx2){
				sx=p2x;
				sy=((c1y - p1y) / dx1) * (p2x - p1x) + p1y;
				dx = (p1x + p2x + sx * 4 - (c1x + c2x) * 3) * .125;
				dy = (p1y + p2y + sy * 4 - (c1y + c2y) * 3) * .125;
			} else{
				m1 = (c1y - p1y) / dx1;
				m2 = (c2y - p2y) / dx2;
		
			if (Math.abs(m1)==Math.abs(m2))
			{
				//edge case:
				//bezier arms are parallel, so: are they colinear with anchors?
				m3 = ((p2y - p1y) / (p2x - p1x));
				if (m1 == m2  && m3 == m1) {
					//if they are colinear with the line between the anchors...its just a line
					//todo: consider the possible case where the control points extend beyond the anchor points... (not yet accounted for - need to check SVG standard)
					returnResult.push(commandStack.addLineTo(p2x, p2y));
					return returnResult;
				}
				//are they on the same side or opposite sides of the line between the anchors?
				if ((m1 > m3 && m2 < m3) || (m1 < m3 && m2 > m3)){
				//we can split the curve because the beziers arms are on the same side of the line between the anchors
				//and it is therefore reasonable to aim for a quadratic approximation. Use the average of the control points.
				sx = 	(c1x + c2x)	/ 2;
				sy =  	(c1y + c2y) / 2;
				dx = (p1x + p2x + sx * 4 - (c1x + c2x) * 3) * .125;
				dy = (p1y + p2y + sy * 4 - (c1y + c2y) * 3) * .125;
				} else {
				//the bezier arms are parallel and on opposite sides of the line between the anchors
				//let's just force a split as the bezier curve crosses through the centre of the anchors
					dx = k;
					dy = k;
				}
				
			} else {
				//normal handling
				sx = (-m2 * p2x + p2y + m1 * p1x - p1y) / (m1 - m2);
				sy = m1 * (sx - p1x) + p1y;
				dx = (p1x + p2x + sx * 4 - (c1x + c2x) * 3) * .125;
				dy = (p1y + p2y + sy * 4 - (c1y + c2y) * 3) * .125;
				}
			}

			// split curve if the quadratic isn't close enough
			if (dx * dx + dy * dy > k)
			{
				//dev note:these cannot be static external variables for performance gain, as they are required to maintain previous values on return from recusive execution
				var p01x:Number = (p1x + c1x) * half;
				var p01y:Number = (p1y + c1y) * half;
				var p12x:Number= (c1x + c2x) * half;
				var p12y:Number = (c1y + c2y) * half;				
				var p23x:Number = (c2x + p2x) * half;
				var p23y:Number = (c2y + p2y) * half;					
				var p02x:Number = (p01x + p12x) * half;
				var p02y:Number= (p01y + p12y) * half;
				var p13x:Number= (p12x + p23x ) * half;
				var p13y:Number = (p12y + p23y ) * half;					
				var p03x:Number= (p02x + p13x) * half;
				var p03y:Number = (p02y + p13y) * half;	
				// recursive call to subdivide curve
				cubicToQuadratic (p1x,p1y,p01x,p01y,p02x,p02y, p03x,p03y,k, commandStack);
				cubicToQuadratic (p03x,p03y,p13x,p13y,p23x,p23y, p2x,p2y,k, commandStack);	
			} 
			else{
				// end recursion by saving points
				returnResult.push(commandStack.addCurveTo(sx,sy,p2x,p2y));
			}
		
			return returnResult;
		
		}
		
		
	
	}
}