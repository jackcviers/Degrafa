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
package com.degrafa.geometry {
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.utilities.GeometryUtils;
	import com.degrafa.utilities.math.SimpleRoot;

	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import com.degrafa.utilities.math.SimpleRoot;
	import com.degrafa.utilities.math.Solve2x2;

	//--------------------------------------
	//  Other metadata
	//--------------------------------------

	[IconFile("CubicBezier.png")]

	[Bindable]
	/**
	 * The AdvancedCubicBezier element draws a cubic Bézier using the specified start point,
	 * end point and 2 control points. and contains several additional methods
	 * that are useful in advanced applications.
	 *
	 *
	 **/
	public class AdvancedCubicBezier extends CubicBezier {
		// bezier polynomial coefficients
		private var _c0X:Number;

		private var _c0Y:Number;

		private var _c1X:Number;

		private var _c1Y:Number;

		private var _c2X:Number;

		private var _c2Y:Number;

		private var _c3X:Number;

		private var _c3Y:Number;

		// limit on interval width before interval is considered completely bisected
		private var _bisectLimit:Number;

		// bisection interval bounds
		private var _left:Number;

		private var _right:Number;

		private var _twbrf:SimpleRoot;

		// stationary points of x(t) and y(t)
		private var _t1X:Number;

		private var _t1Y:Number;

		private var _t2X:Number;

		private var _t2Y:Number;

		// specialized 2x2 solver using Cramer's rule
		private var _solver:Solve2x2;

		/**
		 * Constructor.
		 *
		 * <p>The advanced cubic Bézier constructor accepts 8 optional arguments that define it's
		 * start, end and controls points.</p>
		 *
		 * @param x0 A number indicating the starting x-axis coordinate.
		 * @param y0 A number indicating the starting y-axis coordinate.
		 * @param cx A number indicating the first control x-axis coordinate.
		 * @param cy A number indicating the first control y-axis coordinate.
		 * @param cx1 A number indicating the second control x-axis coordinate.
		 * @param cy1 A number indicating the second control y-axis coordinate.
		 * @param x1 A number indicating the ending x-axis coordinate.
		 * @param y1 A number indicating the ending y-axis coordinate.
		 */
		public function AdvancedCubicBezier(x0:Number=NaN, y0:Number=NaN, cx:Number=NaN, cy:Number=NaN, cx1:Number=NaN, cy1:Number=NaN, x1:Number=NaN, y1:Number=NaN) {
			super();

			this.x0 = x0;
			this.y0 = y0;
			this.cx = cx;
			this.cy = cy;
			this.cx1 = cx1;
			this.cy1 = cy1;
			this.x1 = x1;
			this.y1 = y1;

			_bisectLimit = 0.05;
			_left = 0;
			_right = 1;
			_t1X = 0;
			_t1Y = 0;
			_t2X = 0;
			_t2Y = 0;

			// Jack Crenshaw's TWBRF and 2x2 solver, both instantiated on demand
			_twbrf = null;
			_solver = null;
		}

		/**
		 * @inheritDoc
		 **/
		override public function preDraw():void {
			if (invalidated) {

				commandStack.length = 0;

				// add a MoveTo at the start of the commandStack rendering chain
				commandStack.addMoveTo(x0, y0);

				commandStack.addCubicBezierTo(x0, y0, cx, cy, cx1, cy1, x1, y1, 1);

				if (close) {
					commandStack.addLineTo(x0, y0);
				}

				getBezierCoef();
				invalidated = false;
			}
		}

		override public function pointAt(_t:Number):Point {
			var t:Number = _t < 0 ? 0 : _t;
			t = t > 1 ? 1 : t;

			return new Point(_c0X + t * (_c1X + t * (_c2X + t * _c3X)), _c0Y + t * (_c1Y + t * (_c2Y + t * _c3Y)));
		}

		/**
		 * interpolate
		 *
		 * <p>Compute control points so that quadratic Bezier passes through three points at the specified parameter value.
		 *
		 * @param _points:Array - array of three <code>Point</code> references, representing the coordinates of the interpolation points.
		 *
		 * @return Array the parameter values in [0,1] at which the Bezier curve passes through the second and third interpolation points (determined by a chord-length parameterization).
		 * A negative value is returned if less than three interpolation points are provided.
		 *
		 */
		public function interpolate(points:Array):Array {
			// compute t-value using chord-length parameterization
			if (points.length < 4) {
				return [-1];
			}

			// no error-checking ... you break it, you buy it.
			var p0:Point = points[0];
			var p1:Point = points[1];
			var p2:Point = points[2];
			var p3:Point = points[3];

			x0 = p0.x;
			y0 = p0.y;
			x1 = p3.x;
			y1 = p3.y;

			// currently, this method auto-parameterizes the curve using chord-length parameterization.  A future version might allow inputting the two t-values, but this is more
			// user-friendly (what an over-used term :) 
			var deltaX:Number = p1.x - p0.x;
			var deltaY:Number = p1.y - p0.y;
			var d1:Number = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

			deltaX = p2.x - p1.x;
			deltaY = p2.y - p1.y;
			var d2:Number = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

			deltaX = p3.x - p2.x;
			deltaY = p3.y - p2.y;
			var d3:Number = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

			var d:Number = d1 + d2 + d3;
			var t1:Number = d1 / d;
			var t2:Number = (d1 + d2) / d;

			// there are four unknowns (x- and y-coords for P1 and P2), which are solved as two separate sets of two equations in two unknowns
			var t12:Number = t1 * t1;
			var t13:Number = t1 * t12;

			var t22:Number = t2 * t2;
			var t23:Number = t2 * t22;

			// x-coordinates of P1 and P2 (t = t1 and t2) - exercise: eliminate redudant computations in these equations
			var a11:Number = 3 * t13 - 6 * t12 + 3 * t1;
			var a12:Number = -3 * t13 + 3 * t12;
			var a21:Number = 3 * t23 - 6 * t22 + 3 * t2;
			var a22:Number = -3 * t23 + 3 * t22;

			var b1:Number = -t13 * x1 + x0 * (t13 - 3 * t12 + 3 * t1 - 1) + p1.x;
			var b2:Number = -t23 * x1 + x0 * (t23 - 3 * t22 + 3 * t2 - 1) + p2.x;

			if (_solver == null) {
				_solver = new Solve2x2();
			}

			// beware nearly or exactly coincident interior interpolation points
			var p:Point = _solver.solve(a11, a12, a21, a22, b1, b2);

			if (_solver.determinant < 0.000001) {
				// degenerates to a parabolic interpolation
				var t1m1:Number = 1.0 - t1;
				var tSq:Number = t1 * t1;
				var denom:Number = 2.0 * t1 * t1m1;

				// to do - handle case where this degenerates into all overlapping points (i.e. denom is numerically zero)
				cx = (p1.x - t1m1 * t1m1 * x0 - tSq * p2.x) / denom;
				cy = (p1.y - t1m1 * t1m1 * y0 - tSq * p2.y) / denom;

				cx1 = cx;
				cy1 = cy;

				getBezierCoef();

				return [t1, t1];
			} else {
				cx = p.x
				cx1 = p.y;
			}

			// y-coordinates of P1 and P2 (t = t1 and t2)      
			b1 = -t13 * y1 + y0 * (t13 - 3 * t12 + 3 * t1 - 1) + p1.y;
			b2 = -t23 * y1 + y0 * (t23 - 3 * t22 + 3 * t2 - 1) + p2.y;

			// resolving with same coefficients, but new RHS
			p = _solver.solve(a11, a12, a21, a22, b1, b2, 0.00001, true);
			cy = p.x
			cy1 = p.y;

			getBezierCoef();

			return [t1, t2];
		}

		/**
		 * tAtMinX
		 *
		 * <p>Find t-parameter at which the x-coordinate is a minimum.</p>
		 *
		 * @return Number Parameter value in [0,1] at which the cubic Bezier curve's x-coordinate is a minimum
		 *
		 * @since 1.0
		 *
		 */
		public function tAtMinX():Number {
			getStationaryPoints();

			var t:Number = 0;
			var minX:Number = x0;

			if (x1 < minX) {
				t = 1;
				minX = x1;
			}

			if (_t1X > 0 && _t1X < 1) {
				var myX:Number = pointAt(_t1X).x;

				if (myX < minX) {
					t = _t1X;
					minX = myX;
				}
			}

			if (_t2X > 0 && _t2X < 1) {
				if (pointAt(_t2X).x < minX) {
					t = _t2X;
				}
			}

			return t;
		}

		/**
		 * tAtMaxX
		 *
		 * <p>Find t-parameter at which the x-coordinate is a maximum.</p>
		 *
		 * @return Number Parameter value in [0,1] at which the cubic Bezier curve's x-coordinate is a maximum.
		 *
		 */
		public function tAtMaxX():Number {
			getStationaryPoints();

			var t:Number = 0;
			var maxX:Number = x0;

			if (x1 > maxX) {
				t = 1;
				maxX = x1;
			}

			if (_t1X > 0 && _t1X < 1) {
				var myX:Number = pointAt(_t1X).x;

				if (myX > maxX) {
					t = _t1X;
					maxX = myX;
				}
			}

			if (_t2X > 0 && _t2X < 1) {
				if (pointAt(_t2X).x > maxX) {
					t = _t2X;
				}
			}

			return t;
		}

		/**
		 * tAtMinY
		 *
		 * <p>Find t-parameter at which the y-coordinate is a minimum.</p<>
		 *
		 * @return Number - Parameter value in [0,1] at which the cubic Bezier curve's y-coordinate is a minimum.
		 *
		 */
		public function tAtMinY():Number {
			getStationaryPoints(false);

			var t:Number = 0;
			var minY:Number = y0;

			if (y1 < minY) {
				t = 1;
				minY = y1;
			}

			if (_t1Y > 0 && _t1Y < 1) {
				var myY:Number = pointAt(_t1Y).y;

				if (myY < minY) {
					t = _t1Y;
					minY = myY;
				}
			}

			if (_t2Y > 0 && _t2Y < 1) {
				if (pointAt(_t2Y).y < minY) {
					t = _t2Y;
				}
			}

			return t;
		}

		/**
		 * tAtMaxY
		 *
		 * <p>Find t-parameter at which the y-coordinate is a maximum.</p>
		 *
		 * @return Number Parameter value in [0,1] at which the cubic Bezier curve's y-coordinate is a maximum.
		 *
		 */
		public function tAtMaxY():Number {
			getStationaryPoints(false);

			var t:Number = 0;
			var maxY:Number = y0;

			if (y1 > maxY) {
				t = 1;
				maxY = y1;
			}

			if (_t1Y > 0 && _t1Y < 1) {
				var myY:Number = pointAt(_t1Y).y;

				if (myY > maxY) {
					t = _t1Y;
					maxY = myY;
				}
			}

			if (_t2Y > 0 && _t2Y < 1) {
				if (pointAt(_t2Y).y > maxY) {
					t = _t2Y;
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
		 * array contains either one, two, or three y-coordinates.  There are issues with curves that are exactly or nearly (for
		 * numerical purposes) vertical in which there could theoretically be an infinite number of y-coordinates for a single
		 * x-coordinate.  This method does not work in such cases, although compensation might be added in the future.
		 *
		 * <p>Each array element is a reference to an <code>Object</code> whose 't' parameter represents the Bezier t parameter.  The
		 * <code>Object</code> 'y' property is the corresponding y-value.  The returned (t,y) coordinates may be used by the caller
		 * to determine which of the (up to three) returned y-coordinates might be preferred over the others.</p>
		 *
		 */
		public function yAtX(_x:Number):Array {
			if (isNaN(_x)) {
				return [];
			}

			// check bounds
			var xMax:Number = pointAt(tAtMaxX()).x;
			var xMin:Number = pointAt(tAtMinX()).x;

			if (_x < xMin || _x > xMax) {
				return [];
			}

			// the necessary y-coordinates are the intersection of the curve with the line x = _x.  The curve is generated in the
			// form c0 + c1*t + c2*t^2 + c3*t^3, so the intersection satisfies the equation 
			// Bx(t) = _x or Bx(t) - _x = 0, or c0x-_x + c1x*t + c2x*t^2 + c3x*t^3 = 0.

			getBezierCoef();

			// Find one root - any root - then factor out (t-r) to get a quadratic poly. for the remaining roots
			var f:Function = function(_t:Number):Number {return _t * (_c1X + _t * (_c2X + _t * (_c3X))) + _c0X - _x;}

			if (_twbrf == null)
				_twbrf = new SimpleRoot();

			// some curves that loop around on themselves may require bisection
			_left = 0;
			_right = 1;
			__bisect(f, 0, 1);

			// experiment with tolerance - but not too tight :)  
			var t0:Number = _twbrf.findRoot(_left, _right, f, 50, 0.000001);
			var eval:Number = Math.abs(f(t0));

			if (eval > 0.00001)
				return []; // compensate in case method quits due to error (no event listener here)

			var result:Array = new Array();

			if (t0 <= 1)
				result.push({t: t0, y: pointAt(t0).y});

			// Factor theorem: t-r is a factor of the cubic polynomial if r is a root.  Use this to reduce to a quadratic poly.
			// using synthetic division
			var a:Number = _c3X;
			var b:Number = t0 * a + _c2X;
			var c:Number = t0 * b + _c1X;

			// process the quadratic for the remaining two possible roots
			var d:Number = b * b - 4 * a * c;

			if (d < 0) {
				return result;
			}

			d = Math.sqrt(d);
			a = 1 / (a + a);
			var t1:Number = (d - b) * a;
			var t2:Number = (-b - d) * a;

			if (t1 >= 0 && t1 <= 1)
				result.push({t: t1, y: pointAt(t1).y});

			if (t2 >= 0 && t2 <= 1)
				result.push({t: t2, y: pointAt(t2).y});

			return result;
		}

		/**
		 * xAtY
		 *
		 * <p>Return the set of x-coordinates corresponding to the input y-coordinate.</p>
		 *
		 * @param _y:Number y-coordinate at which the desired x-coordinates are desired
		 *
		 * @return Array set of (t,x)-coordinates at the input y-coordinate provided that the y-coordinate is inside the range
		 * covered by the quadratic Bezier in [0,1]; that is there must exist t in [0,1] such that By(t) = _y.  If the input
		 * y-coordinate is not inside the range covered by the Bezier curve, the returned array is empty.  Otherwise, the
		 * array contains either one, two, or three x-coordinates.  There are issues with curves that are exactly or nearly (for
		 * numerical purposes) horizontal in which there could theoretically be an infinite number of x-coordinates for a single
		 * y-coordinate.  This method does not work in such cases, although compensation might be added in the future.
		 *
		 * <p>Each array element is a reference to an <code>Object</code> whose 't' parameter represents the Bezier t parameter.  The
		 * <code>Object</code> 'x' property is the corresponding x-coordinate.  The returned (t,x) coordinates may be used by the caller
		 * to determine which of the (up to three) returned x-coordinates might be preferred over the others.</p>
		 *
		 */
		public function xAtY(_y:Number):Array {
			if (isNaN(_y)) {
				return [];
			}

			// check bounds
			var yMax:Number = pointAt(tAtMaxY()).y;
			var yMin:Number = pointAt(tAtMinY()).y;

			if (_y < yMin || _y > yMax) {
				return [];
			}

			// the necessary y-coordinates are the intersection of the curve with the line y = _y.  The curve is generated in the
			// form c0 + c1*t + c2*t^2 + c3*t^3, so the intersection satisfies the equation 
			// By(t) = _y or By(t) - _y = 0, or c0y-_y + c1y*t + c2y*t^2 + c3y*t^3 = 0.

			getBezierCoef();

			// Find one root - any root - then factor out (t-r) to get a quadratic poly. for the remaining roots
			var f:Function = function(_t:Number):Number {return _t * (_c1Y + _t * (_c2Y + _t * (_c3Y))) + _c0Y - _y;}

			if (_twbrf == null)
				_twbrf = new SimpleRoot();

			// some curves that loop around on themselves may require bisection
			_left = 0;
			_right = 1;
			__bisect(f, 0, 1);

			// experiment with tolerance - but not too tight :)  
			var t0:Number = _twbrf.findRoot(_left, _right, f, 50, 0.000001);
			var eval:Number = Math.abs(f(t0));

			if (eval > 0.00001)
				return []; // compensate in case method quits due to error (no event listener here)

			var result:Array = new Array();

			if (t0 <= 1)
				result.push({t: t0, x: pointAt(t0).x});

			// Factor theorem: t-r is a factor of the cubic polynomial if r is a root.  Use this to reduce to a quadratic poly. using synthetic division
			var a:Number = _c3Y;
			var b:Number = t0 * a + _c2Y;
			var c:Number = t0 * b + _c1Y;

			// process the quadratic for the remaining two possible roots
			var d:Number = b * b - 4 * a * c;

			if (d < 0) {
				return result;
			}

			d = Math.sqrt(d);
			a = 1 / (a + a);
			var t1:Number = (d - b) * a;
			var t2:Number = (-b - d) * a;

			if (t1 >= 0 && t1 <= 1)
				result.push({t: t1, x: pointAt(t1).x});

			if (t2 >= 0 && t2 <= 1)
				result.push({t: t2, x: pointAt(t2).x});

			return result;
		}

		// recompute polynomial coefficients
		private function getBezierCoef():void {
			_c0X = x0;
			_c0Y = y0;

			var dX:Number = 3.0 * (cx - x0);
			var dY:Number = 3.0 * (cy - y0);
			_c1X = dX;
			_c1Y = dY;

			var bX:Number = 3.0 * (cx1 - cx) - dX;
			var bY:Number = 3.0 * (cy1 - cy) - dY;
			_c2X = bX;
			_c2Y = bY;

			_c3X = x1 - x0 - dX - bX;
			_c3Y = y1 - y0 - dY - bY;
		}

		// bisect the specified range to isolate an interval with a root.
		private function __bisect(_f:Function, _l:Number, _r:Number):void {
			if (Math.abs(_r - _l) <= _bisectLimit) {
				return;
			}

			var left:Number = _l;
			var right:Number = _r;
			var middle:Number = 0.5 * (left + right);

			if (_f(left) * _f(right) <= 0) {
				_left = left;
				_right = right;
				return;
			} else {
				__bisect(_f, left, middle);
				__bisect(_f, middle, right);
			}
		}

		// get the statonary points of x(t) and y(t)
		private function getStationaryPoints(pX:Boolean=true):void {
			// in a future release, this will be made more efficient - don't want to mess with the invalidated flag just yet :)
			getBezierCoef();

			// given polynomial coefficients, the bezier curve equation is of the form c0 + c1*t + c2*t^2 + c3*t^3, so the derivative is of 
			// the form c1 + 2*c2*t + 3*c3*t^2, which has two roots
			var d:Number = -1;
			var t1:Number = -1;
			var t2:Number = -1;

			if (pX) {
				d = 4 * _c2X * _c2X - 12 * _c1X * _c3X;

				if (d >= 0) {
					d = Math.sqrt(d);
					var a:Number = 6 * _c3X;
					var b:Number = 2 * _c2X;
					t1 = (-b + d) / a;
					t2 = (-b - d) / a;
				}

				_t1X = t1 >= 0 && t1 <= 1 ? t1 : -1;
				_t2X = t2 >= 0 && t2 <= 1 ? t2 : -1;
			} else {
				d = 4 * _c2Y * _c2Y - 12 * _c1Y * _c3Y;

				if (d >= 0) {
					d = Math.sqrt(d);
					a = 6 * _c3Y;
					b = 2 * _c2Y;
					t1 = (-b + d) / a;
					t2 = (-b - d) / a;
				}

				_t1Y = t1 >= 0 && t1 <= 1 ? t1 : -1;
				_t2Y = t2 >= 0 && t2 <= 1 ? t2 : -1;
			}
		}
	}
}