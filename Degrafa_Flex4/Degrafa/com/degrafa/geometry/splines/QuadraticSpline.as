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
// Programmed by:  Jim Armstrong, (www.algorithmist.net)
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.splines
{	 
	 import com.degrafa.GraphicPoint;
	 import com.degrafa.IGeometry;
	 import com.degrafa.IGraphicPoint;
	 import com.degrafa.core.collections.GraphicPointCollection;
	 import com.degrafa.geometry.Geometry;
	 
	 import flash.display.Graphics;
	 import flash.geom.Rectangle;
	 
	 import mx.events.PropertyChangeEvent;
 	
  [DefaultProperty("points")]	
  	
  [Bindable]
	/**
 	* The Quadratic can be used for drawing of a smooth curve that passes through
 	* the first and last points.  Interior points influence the shape of the curve.
 	* Some shape control is provided with a tension parameter and the spline is
 	* intended for fast drawing of approximate shapes.  Use the cubic Bezier spline
 	* to fit a smooth curve through an arbitrary number of points. 
 	**/
  public class QuadraticSpline extends Geometry implements IGeometry
  {
		  // count number of points added
		  private var _count:uint=0;        

    // index into a specific quadratic segment or AdvancedQuadraticBezier instance
    private var _index:uint;            
		
	   // reference to QuadData instance representing each segment
	   private var _quadratics:Array;
	   
	   // min/max t-parameters for mapping non-interpolative tension
	   private var _tMin:Number;
	   private var _tMax:Number;

		/**
		* @description 	Method: QuadraticSpline() - Construct a new QuadraticSpline instance
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	   public function QuadraticSpline( _myPoints:Array=null )
	   {
	    	super();
	    	
			   if( _myPoints )
			   {
				    points = _myPoints;
			   }
			   
			   _quadratics = new Array();
			   _tension    = 0;
			   _index      = 0;
			   _count      = 0;
			   _autoClose  = false;
			   
			   _tMin = 0;
			   _tMax = 1;
	   }
					
		/**
		* Spline short hand data value.
		* 
		* <p>The spline data property expects a list of space seperated points. For example
		* "10,20 30,35". </p>
		* 
		* @see Geometry#data
		* 
		**/
		  override public function set data(value:Object):void
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
					     }
				    }
				
			    	// set the points property
				    points=pointArray;
			   }
		  }
		  
		  private var _autoClose:Boolean;
		/**
		* Specifies if this polyline is to be automatically closed. 
		**/
		  [Inspectable(category="General", enumeration="true,false")]
		  public function get autoClose():Boolean
		  {
		  	 return _autoClose;
		  }
		  public function set autoClose(value:Boolean):void
		  {
			   if( _autoClose != value )
			   {
				    _autoClose  = value;
				    invalidated = true;
			   }
		  }
		
		  private var _points:GraphicPointCollection;
		  
		  [Inspectable(category="General", arrayType="com.degrafa.IGraphicPoint")]
		  [ArrayElementType("com.degrafa.IGraphicPoint")]
		  /**
		  * A array of points that describe this polyline.
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
			   
			   invalidated = true;
		  }
		
		  /**
		  * Access to the Degrafa point collection object for this spline.
		  **/
		  public function get pointCollection():GraphicPointCollection
		  {
			   initPointsCollection();
			   return _points;
		  }
		
		  /**
		  * Initialize the point collection by creating it and adding the event listener.
		  **/
		  private function initPointsCollection():void
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
		   * tension value controls the general tightness of the spline between points and ranges from zero to one.
		  **/
		  private var _tension:Number;
		  [Inspectable(category="General", type="Number")]
		  public function get tension():Number
		  {
			   return _tension;
		  }
		  
		  public function set tension(value:Number):void
		  {
			   _tension = isNaN(value) ? 1 : value;
			   _tension = Math.max(0, _tension);
			   _tension = Math.min(1, _tension);
		  }
		
		/**
		* Principle event handler for any property changes to a geometry object or it's child objects.
		**/
		  override protected function propertyChangeHandler(event:PropertyChangeEvent):void
		  {
			   invalidated = true;
			   super.propertyChangeHandler(event);
	  	}
				
	   public function get length():Number
	   { 
	     return points.length; 
	   }
	    	    
		/**
		* Adds a new point to the quadratic spline.
		**/
    public function addControlPoint(x:Number,y:Number):void
	   {
	    	if( !isNaN(x) && !isNaN(y) )
	    	{
	    	  initPointsCollection();
	    	  
	       _points.addItem(new GraphicPoint(x,y));
	       _count++; 
	       
	       invalidated = true;
	     } 
	   }
		
		/**
		* Resets the spline to its original state, that is, no control points and default parameter values
		**/
    public function reset():void
	   {
		    points.splice(0);
		    _quadratics.splice(0);
		    
			   _tension    = 0;
			   _index      = 0;
			   _count      = 0;
			   _autoClose  = false;
	    	invalidated = true;
	   }
	    		
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
		
		  // assign AdvancedQuadraticBezier instances for each segment
		  private function initPoints():void
		  {
			   if( !points.length )
			   {
			     return;
			   }
			  
			   if( _count > 2 )
			   {
			     _createQuadControlPoints();
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
				
	      	_createQuadControlPoints();
	        	
	     	 commandStack.length=0;
				
				    // add a MoveTo at the start of the commandStack rendering chain
				    commandStack.addMoveTo(points[0].x,points[0].y);
		        	
		      // The AdvancedQuadraticBezier class will probably not be used in the future.  It's useful in the event we need to perform
		      // advanced operations on individual quadratic segments of the spline.  If it is only used for fast drawing, we can store
		      // the quad. coefficients in an Object and be done with it :)
		    	 var q:QuadData = _quadratics[0];
		    	 commandStack.addLineTo(q.x0, q.y0);
		    	   
		    	 for( var i:uint=0; i<_quadratics.length; ++i )
		      {
		        q = _quadratics[i];
		        commandStack.addCurveTo(q.cx, q.cy, q.x1, q.y1);
		      }
		        
		      commandStack.addLineTo(points[_count-1].x, points[_count-1].y);
		    	 
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

	   // assign control points for each quadratic segment
	   private function _createQuadControlPoints():void
	   { 
	     // first implementation is to verify functionality; will be performance-optimized in a future release
	   
	     var l1:uint = points.length-1;
	     if( autoClose && ((points[0].x != points[l1].x) || (points[0].y != points[l1].y)) )
	     {
	       addControlPoint( points[0].x, points[0].y );
	     }
	      	
	     // always start from a clean set
	     _quadratics.splice(0);
	    
	     var t:Number  = _tMin + _tension*(_tMax-_tMin);
	     var t1:Number = 1.0-t;
	     var pX:Number = (1-t)*points[0].x + t*points[1].x;
	     var pY:Number = (1-t)*points[0].y + t*points[1].y;
	     var qX:Number = (1-t1)*points[1].x + t1*points[2].x;
	     var qY:Number = (1-t1)*points[1].y + t1*points[2].y;
	        
	     var q:QuadData  = new QuadData( pX, pY, points[1].x, points[1].y, qX, qY );
	     _quadratics[0]  = q;
	       
	     
	     if( _count > 3 )
	     {
	       var s:Number = t1;
	       for( var i:uint=2; i<_count-1; ++i )
	       {
	         pX = qX;
	         pY = qY;
	         s  = s == t ? t1 : t;
	         qX = (1-s)*points[i].x + s*points[i+1].x;
	         qY = (1-s)*points[i].y + s*points[i+1].y;
	         
	         q                = new QuadData( pX, pY, points[i].x, points[i].y, qX, qY );
	         _quadratics[i-1] = q;
	       }
	     }
	     
	    	invalidated = false;
	   }
	 }
}