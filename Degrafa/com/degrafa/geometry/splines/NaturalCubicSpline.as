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
// Reference: http://www.algorithmist.net/spline.html
//
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.splines
{	 
	 import com.degrafa.GraphicPoint;
	 import com.degrafa.IGeometry;
	 import com.degrafa.IGraphicPoint;
	 import com.degrafa.core.collections.GraphicPointCollection;
	 import com.degrafa.geometry.CubicBezier;
	 import com.degrafa.geometry.Geometry;
	
	 import flash.display.Graphics;
	 import flash.geom.Point;
	 import flash.geom.Rectangle;
	
	 import mx.events.PropertyChangeEvent;
 	
  [DefaultProperty("points")]	
  	
  [Bindable]
	/**
 	* The Natural Cubic Spline is a version of the natural cubic spline utility that is optimized
 	* for drawing in the Degrafa command stack.  This spline is normally used to interpolate a set
 	* of x-y data points.  y must be a strict function of x; that is, x-coordinates are monotonically
 	* increasing. The spline is designed to be open.  It can be manually closed, but there is no facility
 	* to adjust tangents to make the closure smooth.
 	*
 	* There should be at least three knots specified before drawing the spline.
 	*
 	**/
  public class NaturalCubicSpline extends BasicSpline
  { 
	   // reference to plottable cubic spline
	   private var _cubicSpline:PlottableCubicSpline;
    
		/**
		* @description 	Method: NaturalCubicSpline() - Construct a new NaturalCubicSpline instance
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	   public function NaturalCubicSpline( _myPoints:Array=null )
	   {
	    	super(_myPoints);
	   
			   _cubicSpline = new PlottableCubicSpline();
			   super.spline = _cubicSpline;
	   }
	   
	 /**
		*  evaluate a cartesian spline at the specified x-coordinate
		**/
    override public function eval(_x:Number):Number { return _cubicSpline.eval(_x); }
    
 /**
		*  evaluate a cartesian spline's first derivative at the specified x-coordinate
		**/
    override public function derivative(_x:Number):Number { return _cubicSpline.derivative(_x); }
	 }
}