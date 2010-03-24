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
	 import com.degrafa.geometry.CubicBezier;
	 import com.degrafa.geometry.Geometry;
	 import com.degrafa.geometry.utilities.BezierUtils;
  import com.degrafa.utilities.math.SplineToBezier;
	
	 import flash.display.Graphics;
	 import flash.geom.Point;
	 import flash.geom.Rectangle;
	
	 import mx.events.PropertyChangeEvent;
 	
  [DefaultProperty("points")]	
  	
  [Bindable]
	/**
 	* The Basic Spline is a pseudo-abstract base class from which a wide variety of splines
 	* may be constructed and easily integrated into the Degrafa geometry pipeline.  This class
 	* is currently designed for purely interpolative splines.
 	*
 	**/
  public class BasicSpline extends Geometry implements IGeometry, ISpline
  {
		  // count number of points added
		  protected var _count:uint=0;
		
	   // reference to QuadData instances for the quad. beziers that approximate the spline
	   protected var _quads:Array;
	   
	   // reference to plottable spline that provides the computational 'base' for this spline.  this is developed externally.
	   protected var _spline:IPlottableSpline;

    // approximate cartesian or parametric spline with quad. Beziers
    protected var _toBezier:SplineToBezier;
    
		/**
		* @description 	Method: BasicSpline() - Construct a new BasicSpline instance
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	   public function BasicSpline( _myPoints:Array=null )
	   {
	    	super();
	    	
	    	_count = 0;
	    			   
			   if( _myPoints )
			   {
				    points = _myPoints;
			   }

      _spline   = null;			   
			   _quads    = new Array();
			   _toBezier = new SplineToBezier();
	   }
					
		  private var _points:GraphicPointCollection;
		  
		  // it is more natural to talk about knots for spline developers, although 'points' are more frequently used for other Degrafa geometry objects
		  [Inspectable(category="General", arrayType="com.degrafa.IGraphicPoint")]
		  [ArrayElementType("com.degrafa.IGraphicPoint")]
		  /**
		  * Access the array of points that describe the knot set.
		  **/
		  public function get points():Array
		  {
			   initPointsCollection();
			   return _points.items;
		  }
		  
  		public function set points(value:Array):void
  		{			
			   initPointsCollection();
			   _points.items = value;
			   _count        = value.length;
			   
			   // tbd - assign the knots to the spline
			   invalidated = true;
		  }
		
		  /**
		  * Access the direct sequence of quadratic Bezier data that approximates the spline, including index into starting quad at each knot.
		  * First array is sequence of QuadData instances.  Second array is index of QuadData instance of each knot.
		  **/
		  public function get quadApproximation():Array { return _quads.slice(); }
		  
		  /**
		  * Access to the Degrafa point collection object for this spline.
		  **/
		  public function get pointCollection():GraphicPointCollection
		  {
			   initPointsCollection();
			   return _points;
		  }
		  
		 /**
		  * <code>[set] spline</code> Assign the reference to the <code>IPlottableSpline</code> providing the computational basis for this Degrafa spline.
		  **/
		  public function set spline(splineRef:IPlottableSpline):void
		  {
		    if( splineRef != null )
		    {
		      _spline = splineRef;
		    }
		  }
		  
		  /**
		  * return an array of quad Bezier approximations to the spline over the specified interval (cartesian or parameteric) - returns null if the 
		  * values are outside the knot range for a cartesian spline or outside [0,1] for a parametric spline.  Also returns null if the quad. Bezier
		  * approximation is not yet available, which is the case until Degrafa indicates the spline is completely rendered.
		  **/
    public function approximateInterval(val1:Number, val2:Number):Array
    {
      if( _spline.type == SplineTypeEnum.CARTESIAN )
      {
        return approximateCartesianInterval(val1, val2);
      }
      
      return [];
    }
    
    protected function approximateCartesianInterval(val1:Number, val2:Number):Array
    {
      var quads:Array = quadApproximation;
      if( quads == null )
      {
        return quads;
      }
      
      if( val2 <= val1 )
      {
        return null;
      }
      
      var knots:Array = points;
      if( val1 < knots[0].x || val2 > knots[knots.length-1].x )
      {
        return null;
      }
      
      var q:Array     = quads[0];
      var index:Array = quads[1];
      
      // find bezier interval for the first and last values
      var i1:int = 0;
      var i2:int = 0;
      for( var i:int=0; i<q.length-1; ++i )
      {
        var qb:QuadData = q[i];
        if( val1 <= qb.x1 )
        {
          i1 = i;
          break;
        }
      }
      
      for( i=i1; i<q.length; ++i )
      {
        qb = q[i]
        if( val2 <= qb.x1 )
        {
          i2 = i;
          break;
        }
      }
      
      var approx:Array = [];
      
      // subdivision required for first value?
      qb = q[i1];
      if( qb.x0 == val1 )
        approx.push(qb);
      else
      {
        var tParam:Object = BezierUtils.tAtX(qb.x0, qb.y0, qb.cx, qb.cy, qb.x1, qb.y1, val1);
        
        // should only be one parameters
        var t:Number = tParam.t1;
        if( t >= 0 )
        {
          // subdivide at the parameter and take the second Bezier as the first quad in sequence - only need the middle control point, the other two points are already computed
          var t1:Number = 1.0 - t;

          var cx:Number = t*qb.x1 + t1*qb.cx;
          var cy:Number = t*qb.y1 + t1*qb.cy;

          approx.push( new QuadData(val1, eval(val1), cx, cy, qb.x1, qb.y1) );
        }
        else
        {
          // should not happen, but put in a safety valve
          approx.push(qb);
        }
      }
      
      // fill out in-between quads
      if( i2 > i1 )
      {
        for( i=i1+1; i<i2; ++i )
        {
          approx.push(q[i]);
        }
      }
      
      // subdivision required for second value?
      qb = q[i2];
      if( qb.x1 == val2 )
        approx.push(qb);
      else
      {
        tParam = BezierUtils.tAtX(qb.x0, qb.y0, qb.cx, qb.cy, qb.x1, qb.y1, val2);
        
        // should only be one parameters
        t = tParam.t1;
        if( t >= 0 )
        {
          // subdivide at the parameter and take the first Bezier as the last quad in sequence - only need the middle control point, the other two points are already computed
          t1 = 1.0 - t;

          cx = t*qb.cx + t1*qb.x0;
          cy = t*qb.cy + t1*qb.y0;

          approx.push( new QuadData(qb.x0, qb.y0, cx, cy, val2, eval(val2)) );
        }
        else
        {
          // should not happen, but put in a safety valve
          approx.push(qb);
        }
      }
      
      return approx;
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
		  public function set knots(value:Object):void
		  {
		    // borrowed from BezierSpline
			   if(super.data != value && _spline != null)
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
						      
						      _spline.addControlPoint( pointItem[0], pointItem[1] ); // immediately add control point to the internal cubic spline
					     }
				    }
				
			    	// set the points property
				    points = pointArray;
			   }
		  }
		  
		  
		  public function addItem(_x:Number, _y:Number):void
		  {
		    _points.addItem(new GraphicPoint(_x,_y));
		  }
		  
		  /**
		  * Initialize the point collection by creating it and adding the event listener.
		  **/
		  protected function initPointsCollection():void
		  {
			   if( !_points )
			   {
				    _points = new GraphicPointCollection();
				
				    // add a listener to the collection
				    if( enableEvents )
				    {
					     _points.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				    }
			   }
		  }
		
		/**
		* Principle event handler for any property changes to a geometry object or it's child objects.
		**/
		  override protected function propertyChangeHandler(event:PropertyChangeEvent):void
		  {
			   invalidated = true;
			   super.propertyChangeHandler(event);
	  	}
				
		/**
		* Access the knot count
		**/		
	   public function get knotCount():int
	   { 
	     return int(points.length); 
	   }
	    	    
		/**
		* Adds a new knot to the spline.
		**/
    public function addControlPoint(x:Number,y:Number):void
	   {
	    	if( !isNaN(x) && !isNaN(y) && _spline != null )
	    	{
	    	  initPointsCollection();
	    	  
	       addItem(x,y);
	       _spline.addControlPoint(x,y);
	       
	       _count++; 
	       
	       invalidated = true;
	     }
	   }
	   
	   // following  accessors should be overriden and implemented based on the type of spline, which should be a simple call since each spline implements IPlottableSpline
	   
	   // evaluate a cartesian spline at the specified x-coordinate
    public function eval(_x:Number):Number { return 0; }
    
    // evaluate the first derivative of a cartesian spline at the specified x-coordinate
    public function derivative(_x:Number):Number { return 0; }
    
    // evaluate the x- and y-coordinates of a parameteric spline at the specified parameter
    public function getX(_t:Number):Number { return 0; }
    public function getY(_t:Number):Number { return 0; }
    
    // evaluate x'(t) and y'(t) of a parameteric spline at the specified parameter
    public function getXPrime(_t:Number):Number { return 0; }
    public function getYPrime(_t:Number):Number { return 0; }
	   
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used. 
		**/
		  override public function calculateLayout(childBounds:Rectangle=null):void
	  	{
      // tbd
			/*if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
					var tempLayoutRect:Rectangle = new Rectangle(0,0,1,1);
					
					//default to bounds if no width or height is set
					//and we have layout
					if(isNaN(_layoutConstraint.width)){
						tempLayoutRect.width = bounds.width;
					}
					 
					if(isNaN(_layoutConstraint.height)){
						tempLayoutRect.height = bounds.height;
					}
					
					if(isNaN(_layoutConstraint.x)){
			 			tempLayoutRect.x = bounds.x;
			 		}
			 		
			 		if(isNaN(_layoutConstraint.y)){
			 			tempLayoutRect.y = bounds.y;
			 		}
					
					super.calculateLayout(tempLayoutRect);
						
					_layoutRectangle = _layoutConstraint.layoutRectangle;
			 	
				}
			}*/
    }
		
		  // approximate spline with quad. Beziers
		  protected function initPoints():void
		  {
			   if( !points.length )
			   {
			     return;
			   }
			   
			   if( _count > 2 )
			   {
			     _quads      = _toBezier.convert(_spline);
			     invalidated = false;
			   }
		  }
		
	 /**
		* @inheritDoc 
		**/
	   override public function preDraw():void
	   {
	    	if( invalidated )
	    	{	
	       if( _count < 3 )
	       {
	         return;
	       }
				
				    //init the points
				    initPoints();
	        	
	     	 commandStack.length=0;
				
				    // add a MoveTo at the start of the commandStack rendering chain
				    commandStack.addMoveTo(points[0].x,points[0].y);
		    	   
		    	 var quads:Array = _quads[0];
		    	 for( var i:uint=0; i<quads.length; ++i )
		      {
		        var q:QuadData = quads[i];
		        commandStack.addCurveTo(q.cx, q.cy, q.x1, q.y1);
		      }
		    	 
	       invalidated = false;
      }
    }
	    
	/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		  override public function draw(graphics:Graphics, rc:Rectangle):void
		  { 	
	    	//re init if required
		 	  if( invalidated ) 
		 	    preDraw(); 
			
			   // init the layout in this case done after predraw.
			   if( _layoutConstraint ) 
			     calculateLayout();	
	    
	     super.draw( graphics,(rc)? rc:bounds );  		     	
	   }
	 }
}