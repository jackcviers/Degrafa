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
	 import com.degrafa.utilities.math.CatmullRom;
	
	 import flash.display.Graphics;
	 import flash.geom.Point;
	 import flash.geom.Rectangle;
	
	 import mx.events.PropertyChangeEvent;
 	
  [DefaultProperty("points")]	
  	
  [Bindable]
	/**
 	* The CatmullRomSpline is a version of the Catmull-Rom spline utility that is optimized
 	* for drawing in the Degrafa command stack.  This spline is normally used to interpolate a set
 	* of x-y data points and for path animation.  The spline may be closed and there is a facility
 	* to adjust the shape of the spline out of the first knot and into the last knot by adjusting
 	* 'auxiliary' or 'artificial' knots before the first and after the last.  Options are to 
 	* have the code automatically chose the artificial knots (default), duplicate the first and last
 	* knots, or specify them manually.
 	*
 	* There should be at least three knots specified before drawing the spline.
 	*
 	**/
  public class CatmullRomSpline extends BasicSpline
  { 
	   // reference to CR spline utility
	   private var _mySpline:CatmullRom;
	   
	   // closed spline?
	   private var _isClosed:Boolean;
    
		/**
		* CatmullRomSpline Construct a new CatmullRomSpline instance
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	   public function CatmullRomSpline( _myPoints:Array=null )
	   {
	    	super(_myPoints);
	   
			   _mySpline = new CatmullRom();
			   super.spline = _mySpline;
			   
			   _isClosed = false;
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
		**/
    override public function getX(_t:Number):Number { return _mySpline.getX(_t); }
    
 /**
		*  y-coordinate of the Catmull-Rom spline at the specified t-parameter
		**/
    override public function getY(_t:Number):Number { return _mySpline.getY(_t); }
    
 /**
		*  dx/dt of Catmull-Rom spline
		**/
    override public function getXPrime(_t:Number):Number { return _mySpline.getXPrime(_t); }
    
 /**
		*  dx/dt of Catmull-Rom spline
		**/
    override public function getYPrime(_t:Number):Number { return _mySpline.getYPrime(_t); }
	 }
}