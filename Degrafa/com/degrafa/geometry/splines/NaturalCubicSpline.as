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
  import com.degrafa.utilities.math.SplineToBezier;
	
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
	   
	     // The PlottableCubicSpline is an example of a spline code that is written external to Degrafa.  Over the long term, as long as any spline conforms to the
	     // IPlottableSpline interface, it should be possible to extend BasicSpline and integrate the spline into Degrafa with little knowlege of the Degrafa
	     // geometry pipline or its internal functioning. 
			   _cubicSpline = new PlottableCubicSpline();
	   }
					
		/**
		* Assign the knot collection using a shorthand data value, similar to the Geometry data setter.
		* 
		* <p>The spline data property expects a list of space seperated points. For example
		* "10,20 30,35". </p>
		* 
		* @see Geometry#data
		* 
		**/
		  override public function set knots(value:Object):void
		  {
		    // borrowed from BezierSpline
			   if(super.data != value)
			   {
				    super.data = value;
			
				    // parse the string on the space
				    var pointsArray:Array = value.split(" ");
				
				    // create a temporary point array
				    var pointArray:Array=[];
				    var pointItem:Array;
				 
				    // and then create a point struct for each resulting pair eventually throw excemption is not matching properly
				    var i:int = 0;
				    var length:int = pointsArray.length;
				    for (; i< length;i++)
				    {
					     pointItem = String(pointsArray[i]).split(",");
					
					     // skip past blank items as there may have been bad formatting in the value string, so make sure it is a length of 2 min	
					     if( pointItem.length == 2 )
					     {
						      pointArray.push(new GraphicPoint(pointItem[0],pointItem[1]));
						      
						      _cubicSpline.addControlPoint( pointItem[0], pointItem[1] ); // immediately add control point to the internal cubic spline
					     }
				    }
				
			    	// set the points property
				    points = pointArray;
			   }
		  }
	    	    
		/**
		* @inheritDoc
		**/
    override public function addControlPoint(x:Number,y:Number):void
	   {
	    	if( !isNaN(x) && !isNaN(y) )
	    	{
	    	  initPointsCollection();
	    	  
	       super.addItem(x,y);
	       _cubicSpline.addControlPoint(x,y);
	       
	       _count++; 
	       
	       invalidated = true;
	     } 
	   }
	   
	 /**
		*  evaluate a cartesian spline at the specified x-coordinate
		**/
    override public function eval(_x:Number):Number { return _cubicSpline.eval(_x); }
    
 /**
		*  evaluate a cartesian spline's first derivative at the specified x-coordinate
		**/
    override public function derivative(_x:Number):Number { return _cubicSpline.derivative(_x); }
	   
		  // approximate spline with quad. Beziers
		  override protected function initPoints():void
		  {
			   if( !points.length )
			   {
			     return;
			   }
			   
			   if( _count > 2 )
			   {
			     _quads      = _toBezier.convert(_cubicSpline);
			     invalidated = false;
			   }
		  }
	 }
}