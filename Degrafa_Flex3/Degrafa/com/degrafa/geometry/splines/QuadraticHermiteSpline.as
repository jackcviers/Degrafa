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
// Programmed by:  Jim Armstrong, (http://algorithmist.wordpress.com)
//
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.splines
{	 
	 import com.degrafa.GraphicPoint;
	 import com.degrafa.IGeometry;
	 import com.degrafa.IGraphicPoint;
	 import com.degrafa.core.collections.GraphicPointCollection;
	 import com.degrafa.geometry.Geometry;
	 import com.degrafa.utilities.math.QuadHermiteSpline;
	
	 import flash.display.Graphics;
	 import flash.geom.Point;
	 import flash.geom.Rectangle;
	
	 import mx.events.PropertyChangeEvent;
 	
  [DefaultProperty("points")]	
  	
  [Bindable]
	/**
 	* The QuadraticHermitSpline interpolates a set of knots with quadratic Hermit seggments.  The shape of the spline
 	* is determined by both the interpolation points and a start tangent from the first point.  The start tangent may
 	* be automatically chosen (default) or user selected.  The spline has no facllity for automatic closure.  It can be manually
 	* closed, but without continuity.  
 	*
 	* There should be at least three knots specified before drawing the spline.
 	*
 	**/
  public class QuadraticHermiteSpline extends BasicSpline
  { 
	   // reference to base quad hermite utility
	   private var _mySpline:QuadHermiteSpline;
    
		/**
		* CatmullRomSpline Construct a new CatmullRomSpline instance
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	   public function QuadraticHermiteSpline( _myPoints:Array=null )
	   {
	    	super(_myPoints);
	   
			   _mySpline = new QuadHermiteSpline();
			   super.spline = _mySpline;
	   }
	   
/**
		* [set] startTangent Assign the start tangent
		*
		* @param _tangent:String Comma-delimited string of x- and y-coordinates for the start tangent.  Use the actual coordinates, not offsets from the initial knot to
	 * define the tangent.  Use the string "auto" to have the spline automatically select a start tangent.
	 * 
		* @return Nothing.
		*
		* @since 1.0
		*
		*/
		  public function set startTangent(_tangent:String):void
		  {
		    if( _tangent.toLowerCase() != "auto" )
		    {
		      var pts:Array = _tangent.split(",");
		      if( pts.length == 2 )
		      {
		        if( !isNaN(pts[0]) && !isNaN(pts[1]) )
		        {
		          _mySpline.startTangent(pts[0], pts[1]);
		        }
		      }
		    }
		  }
	   
/**
	* <code>getX</code> return x-coordinate of the quadratic Hermite spline at the specified t-parameter
	* 
	* @return Number x-coordinate of spline at specified parameter
	**/
    override public function getX(_t:Number):Number { return _mySpline.getX(_t); }
    
/**
	* <code>getY</code> y-coordinate of the quadratic Hermite spline at the specified t-parameter
 * 
 * @return Number y-coordinate of spline at specified parameter 
**/
    override public function getY(_t:Number):Number { return _mySpline.getY(_t); }
    
/**
	* <code>getXPrime</code> return dx/dt of quadratic Hermite spline
 * 
 * @return Number x-coordinate of spline first derivative at specified parameter
**/
    override public function getXPrime(_t:Number):Number { return _mySpline.getXPrime(_t); }
    
/**
	*  <code>getYPrime</code> return dy/dt of quadratic Hermite spline
	* 
	* @return Number y-coordinate of spline first derivative at specified parameter 
**/
    override public function getYPrime(_t:Number):Number { return _mySpline.getYPrime(_t); }
	 }
}