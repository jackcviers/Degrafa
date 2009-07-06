// This interface documents the methods that must be implemented by any plottable spline that is not naturally
// subdivided into constituents that fit into the Degrafa command stack, such as natural cubic spline, Catmull-Rom
// spline, parameteric spline, etc.  This is used by the spline->Bezier conversion utility.
package com.degrafa.geometry.splines
{
  public interface IPlottableSpline
  {
    // return type of spline - cartesian (y as a function of x) or parameteric (x and y as functions of t in [0,1])
    function get type():String;
    
    // return the knot collection as a simple collection of Objects with 'X' and 'Y' properties representing the point coordinates
    function get knots():Array;
    
    // add a set of control or interpolation points to the spline
    function addControlPoint(_x:Number, _y:Number):void;
    
    // evaluate a cartesian spline at the specified x-coordinate
    function eval(_x:Number):Number;
    
    // evaluate the first derivative of a cartesian spline at the specified x-coordinate
    function derivative(_x:Number):Number;
    
    // evaluate the x- and y-coordinates of a parameteric spline at the specified parameter
    function getX(_t:Number):Number;
    function getY(_t:Number):Number;
    
    // evaluate x'(t) and y'(t) of a parameteric spline at the specified parameter
    function getXPrime(_t:Number):Number;
    function getYPrime(_t:Number):Number;
    
    // for a parametric spline, return the cubic polynomial coefficients for a specified segment in an Object
    function getCoef(_segment:uint):Object;
  }
}