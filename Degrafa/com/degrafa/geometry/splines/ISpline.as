package com.degrafa.geometry.splines
{
  import com.degrafa.core.collections.GraphicPointCollection;
  
  public interface ISpline
  {
    function get quadApproximation():Array;
    function get points():Array;
    function get knotCount():int;
    function get pointCollection():GraphicPointCollection;
    
    function set points(value:Array):void;
    function set knots(value:Object):void;
    
    function addControlPoint(x:Number,y:Number):void;
    
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
  }
}