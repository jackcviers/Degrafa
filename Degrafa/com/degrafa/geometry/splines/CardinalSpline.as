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
// Reference: http://www.algorithmist.net/media/catmullrom.pdf
//
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.splines
{	 
	 import com.degrafa.GraphicPoint;
	 import com.degrafa.IGeometry;
	 import com.degrafa.IGraphicPoint;
	 import com.degrafa.core.collections.GraphicPointCollection;
	 import com.degrafa.geometry.Geometry;
	 import com.degrafa.utilities.math.CardSpline;
	
	 import flash.display.Graphics;
	 import flash.geom.Point;
	 import flash.geom.Rectangle;
	
	 import mx.events.PropertyChangeEvent;
 	
  [DefaultProperty("points")]	
  	
  [Bindable]
/**
	* The CardinalSpline is a version of the Cardinal Spline utility that is optimized
	* for drawing in the Degrafa command stack.  This spline is normally used to interpolate a set
	* of x-y data points with variable tensionn.  The default tension reproduces the Catmull-Rom
 * spline.  The CardinalSpline has adjustable 'auxiliary' points that affect the spline shape
 * at beginning and end knots just as the Catmull-Rom.
	*
	* There should be at least three knots specified before drawing the spline.
	*
	* @see com.degrafa.geometry.splines.CatmullRom CatmullRom
 */
  public class CardinalSpline extends BasicSpline
  { 
	   // reference to base card. spline utility
	   private var _mySpline:CardSpline;
	   
	   // closed spline?
	   private var _isClosed:Boolean;
    
/**
	* CardinalSpline Construct a new CardinalSpline instance
	*
	* @return Nothing
	*
	* @since 1.0
	*
	*/
	   public function CardinalSpline( _myPoints:Array=null )
	   {
	    	super(_myPoints);
	   
			   _mySpline    = new CardSpline();
			   super.spline = _mySpline;
			   
			   _isClosed = false;
	   }
	   
/**
	* [set] tension Set the spline's tension
	*
 * @param _t:Number tension value, normally in [0,1] range
 * 
	* @return Nothing  Tension affects how 'tight' the spline fits the knots.  A zero-tension spline provides a relatively loose fit, and in fact defaults
 * to the Catmull-Rom spline.  A negative tension loosens the spline even further.  Tensions as low as -1 are allowed.  As tension approaches 1, the 
 * spline approaches a line-to-line interpolation of the knots.  A tension value above 1 causes the spline to loop around itself moving through knots.  
 * Tensions as high as +3 are supported.
	*
	* @since 1.0
	*
	*/
	  public function set tension(_t:Number):void
	  {
	    var t:Number = Math.min(_t, 3.0);
     t            = Math.max(t, -1.0);
        
	    _mySpline.tension = _t;
	  }
	   
/**
	* [set] closed Create a closed-loop spline from the current knot set 
	*
	* @param _closed:Boolean true if the spline is to be automatically closed
	* 
	* @return Nothing  Knots should already be defined in a manner that tends towards a naturally closed loop.  There is no need to duplicate the first knot in
	* sequence.  If the knot sequence does not tends towards a closed shape, results are unpredicatable.  <b>DO NOT</b> attempt to add knots to a closed spline.
	* Setting closure to <code>true</code> after false currently has no effect, but allowing unclosure is reserved for possible inclusion in a future version. 
	* This setter is intended for use via MXML.
	*
	* @since 1.0
	*
	*/
		  public function set closed(_closed:Boolean):void
		  {
		    if( !_isClosed && _closed )
		    {
		      _mySpline.closed = true;
		      
		      super.invalidated = true;
		      super.drawToTargets();
		    }
		  }
	   
/**
	*  x-coordinate of the Catmull-Rom spline at the specified t-parameter
	*/
    override public function getX(_t:Number):Number { return _mySpline.getX(_t); }
    
/**
	*  y-coordinate of the Catmull-Rom spline at the specified t-parameter
	*/
    override public function getY(_t:Number):Number { return _mySpline.getY(_t); }
    
/**
	*  dx/dt of Catmull-Rom spline
	*/
    override public function getXPrime(_t:Number):Number { return _mySpline.getXPrime(_t); }
    
/**
	*  dx/dt of Catmull-Rom spline
	*/
    override public function getYPrime(_t:Number):Number { return _mySpline.getYPrime(_t); }
	 }
}