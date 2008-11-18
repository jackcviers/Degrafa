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
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net) and 
// ported by the Degrafa team.
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry.splines{
	 
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.CubicBezier;
	import com.degrafa.geometry.Polyline;
	import com.degrafa.geometry.splines.math.*;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
  	
	/**
 	* The BezierSpline can be used for drawing of a smooth curve through 
 	* multiple points, with some shape control over the curve via a tension 
 	* parameter. It may also be used for general path animation with tension
 	* control, optional closed-path control, and velocity control 
 	* (arc-length parameterization). 
 	**/
  	public class BezierSpline extends Polyline implements IGeometry{
		
		// FastBezier instance for each cubic segment
		private var _bezier:Array=new Array();                    
		
		// local parameter value corresponding to input parameter value
		private var _t:Number;                        
		
		// current arc-length
		private var _s:Number;  
		                      
		// index of cubic segment corresponding to input parameter value                      
		private var _index:uint;                      
		
		// control cage manager
		private var _controlCage:BezierSplineControl= new BezierSplineControl(); 
		
		// count number of points added
		private var _count:uint=0;                     
		
		// reference to commonly used constants
		private var _consts:Consts = new Consts();                   
		
		// Arc-length computation and parameterization
		// parameterization method
		private var _param:String;
		
		// Gauss-Legendre integration class
		private var _integral:Gauss= new Gauss();
		                  
		// current arc length
		private var _arcLength:Number=-1;                
		
		// interpolation for arc-length parameterization
		private var _minSegLength:Number;
		private var _interpS:Array= new Array();
		private var _interpT:Array= new Array();
		private var _points:Array;
		private var _arcLengthAtSegments:Array=new Array();

		/**
		* @description 	Method: BezierSpline() - Construct a new BezierSpline instance
		*
		* @return Nothing
		*
		* @since 1.0
		*
		*/
	    public function BezierSpline(){
	    	super();
	    }
		
		override public function set data(value:String):void{
			super.data = value;
			
			//setup the cage
			_controlCage.knots  = points;
			
			//add the control points
			for each (var point:Point in points){
				_bezier.push(new CubicBezier());
			}
		}
				
	    public function get length():Number{ 
	    	return points.length; 
	    }
	    	    
	    private var _tension:Number=1;
	    /**
	    *  spline 'tension' - lower tension increases probability of ripples
	    **/
		public function get tension():uint { 
	    	return _tension;       
	    }    
	    public function set tension(_t:uint):void{
	      	var t:Number = Math.max(0,_t);
	      	t = Math.min(5,t);
	      	_controlCage.tension = t;
	      	_tension = _t;
	    }
	    
	    
		private var _quality:uint=2;   
		/**
		* Controls number of subdivision sweeps in cubic bezier segments
		**/
		public function get quality():uint { 
	    	return _quality;       
	    }   
	    public function set quality(_t:uint):void{
	      	var t:Number = Math.max(0,_t);
	      	t = Math.min(3,t);
	    	_quality    = t;  	
	    }
	    
	    private var _parameterization:String="UNIFORM";
	    /**
	    * Spline parameterization, arc-length or uniform.
	    **/
	    [Inspectable(category="General", enumeration="AUTO,DUPLICATE,EXPLICIT,CHORD_LENGTH,ARC_LENGTH,UNIFORM,FIRST,LAST,POLAR", defaultValue="UNIFORM")]
		public function get parameterization():String{ 
	    	return _parameterization;       
	    }
	    public function set parameterization(_s:String):void{
	    	
	    	_parameterization = _s
	    	
	    	//map the const
	    	_s= Consts[_s];
	    	
	    	if( _s == Consts.ARC_LENGTH || _s == Consts.UNIFORM ){
	        	_param = _s;
	        	invalidated = true;
	     	}
	     	
	    }
	    
	    //todo not yet implemented	    	    
	    public function _integrand(_t:Number):Number{
	    	var x:Number = _bezier[_index].getXPrime(_t);
	      	var y:Number = _bezier[_index].getYPrime(_t);
	      	return Math.sqrt( x*x + y*y );
	    }
		
		/**
		* Adds a new point to the bezier curve.
		**/
	    public function addControlPoint( _xCoord:Number, _yCoord:Number ):void{
	    	if( !isNaN(_xCoord) && !isNaN(_yCoord) ){
	        	points.push(new GraphicPoint(_xCoord, _yCoord));
	        	
	        	_index = points.length-1;
	        
	        	if( _index > 0 ){
	          		var b:CubicBezier = new CubicBezier();
	          		//_bezier[_index-1] = b;
	          		
	          		_bezier.push(b);
	        	}
	      	} 
	    }
		
		//todo jason. may rather use a points.length = 0 for the arrays
	    public function reset():void{
		    points.splice(0);
		    for( var i:uint=0; i<_bezier.length; ++i )
		    	_bezier[i].reset();
		
	      	_bezier.splice(0);
	      	_interpS.splice(0);
	      	_interpT.splice(0);
	      	_points.splice(0);
	      	_arcLengthAtSegments.splice(0);
	
	      	_count      = 0;
	      	_arcLength  = -1;
	      	invalidated = true;
	    }
	
	    public function getX(_t:Number):Number{
	      	if(invalidated)
	        	_assignControlPoints();
	
	      	_interval(_t);
	 
	      	return _bezier[_index].getX(_t);
	    }
	    
	    public function getY(_t:Number):Number{
	    	if(invalidated)
	        	_assignControlPoints();
	
	      	_interval(_t);
	 
	      	return _bezier[_index].getY(_t);
	    }
	    
	    private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object or 
		* the current layout bounds if a layout constraint exists.
		**/
		override public function get bounds():Rectangle{
			return commandStack.bounds;
		}
		
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{

			if(_layoutConstraint){
				if (_layoutConstraint.invalidated){
					super.calculateLayout();
						
					_layoutRectangle = _layoutConstraint.layoutRectangle;
			 	
				}
			}
		}
		
	    /**
		* @inheritDoc 
		**/
	    override public function preDraw():void{
	    	if( invalidated ){
	    		
	        	if(points.length<1){return;}
				
	        	_assignControlPoints();
	        	
	        	//add a move to for the first item.
	        	commandStack.length=0;
				
				//add a MoveTo at the start of the commandStack rendering chain
				commandStack.addMoveTo(points[0].x,points[0].y);
				
				var cubic:CubicBezier;
				
		        //todo not sure were this extra one is coming from yet.
		        //re:: - 1 on the count
		        for( var i:uint=0; i<_bezier.length-1; ++i ){
		        	
		        	cubic = _bezier[i];
		        	
		        	commandStack.addCubicBezierTo(cubic.x0,cubic.y0,cubic.cx,
		        	cubic.cy,cubic.cx1,cubic.cy1,cubic.x1,cubic.y1,1);
		        	
		    	}
		    	
	       		invalidated = false;
	     	}
	    }
	   	
	    //_t:Number=1.0
	    
	    /**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		override public function draw(graphics:Graphics,rc:Rectangle):void{
	    	
	    	//re init if required
		 	if (invalidated) preDraw(); 
			
			//init the layout in this case done after predraw.
			if (_layoutConstraint) calculateLayout();	
	    
	     	super.draw(graphics,(rc)? rc:bounds);
	    }
	    
	    
	    public function arcLength():Number{
	    	if ( _arcLength != -1 ){return _arcLength;}
	        
			if( invalidated ){
	        	_assignControlPoints();
	       	}
	
	      	if( _arcLengthAtSegments.length == 0 ){
	        	_getArcLengthAtSegments();
	       	}
	     
	      	_arcLength = _arcLengthAtSegments[points.length-2];
	      
	      	return _arcLength;
	    }
	
		public function arcLengthAt(_t:Number):Number{
	    	
	      	// compute the length of each segment and sum
	     	var len:Number = 0;
	      	var k:uint     = points.length;
	      
	    	if( k < 2 || _t == 0 ){
	      		return len;
	     	}
	      
	      	if( invalidated ){
	      		_assignControlPoints();
	      	}
	
	      	if( _arcLengthAtSegments.length == 0 ){
	        	_getArcLengthAtSegments();
	       	}
	      
	      	if( _t == 1 ){return _arcLength;}
	      	          
	      	var t:Number = (_t<0) ? 0 : _t;
	      	t = (t>1) ? 1 : t;
	
	      	// determine which segment corresponds to the input value and the local 
	      	//parameter for that segment
	      	var N1:Number = k-1;
	      	var N1t:Number = N1*t;
	      	var f:Number = Math.floor(N1t);
	      	var maxSeg:Number = Math.min(f+1, N1)-1;
	      	var param:Number = N1t - f;
	
	      	// full curve length up to, but not including final segment
	      	if( maxSeg > 0 ){
	        	len = _arcLengthAtSegments[maxSeg-1];
	      	}
	
	      	// add partial curve segment length, unless we're at a knot
	      	if( param != 0 ){
	        	_index = maxSeg;
	        	len += _integral.eval( _integrand, 0, param, 5 );
	      	}
	            
	      	return len;
	    }
	    
	    private function _getArcLengthAtSegments():void{
	    	_index = 0;
	      	_arcLengthAtSegments[0] = _integral.eval( _integrand, 0, 1, 5 );
	      
	      	_minSegLength = _arcLengthAtSegments[0];
	      	
	      	for( var i:uint=1; i<points.length-1; ++i ){
	        	_index = i;
	        	var segLength:Number     = _integral.eval( _integrand, 0, 1, 5 );
	        	_arcLengthAtSegments[i] = _arcLengthAtSegments[i-1] + segLength;
	        	_minSegLength = Math.min(_minSegLength, segLength);
	      	}
	    }
	
	    // compute the index of the cubic bezier segment and local parameter 
	    //corresponding to the global parameter, based on parameterization
	    private function _interval(_t:Number):void{
	    	var t:Number = (_t<0) ? 0 : _t;
	      	t = (t>1)  ? 1 : t;
	      
	      	// if arc-length parameterization, approximate L^-1(s)
	      	if( _param == Consts.ARC_LENGTH ){
	        	if( t != _s ){
	          		//_t = _spline.eval(t);
	          		_t = _interpolate(t);
	          		_s = t;
	          		_segment();
	         	}
	        }
	      	else{
	        	if( t != _t ){
	          		_t = t;
	          		_segment();
	        	}      
	      	}
	    }
	    
	    // compute current segment and local parameter value
	    private function _segment():void{
	    	// the trivial case -- one segment
	      	var k:Number = points.length;
	      	if( k == 2 ){
	      		_index = 0;
	      	}
	      	else {
	        	if( _t == 0 ){
	          		_index = 0;
	         	}
	        	else if( _t == 1.0 ){
	          		_index = k-2;
	         	}
	        	else{
	          		var N1:Number = k-1;
	          		var N1t:Number = N1*_t;
	          		var f:Number = Math.floor(N1t);
	          		_index = Math.min(f+1, N1)-1;
	          		_t = N1t - f;
	        	}
	      	}
	    }
	    
	    // assign control points for each cubic segment
	    private function _assignControlPoints():void{
	    	// if the spline is closed, a new control point is added so that the 
	      	//start and end points of the spline match
	     
		 	var l1:uint = points.length-1;
	     	if(autoClose && points[0].x != points[l1].x && points[0].y != points[l1].y ){
	      		//todo jason
	      		addControlPoint(points[0].x, points[0].y);
	      	}
	      	
	
	      	_controlCage.construct();
	    
	      	for( var i:uint=0; i<_bezier.length-1; ++i ){
	        	var c:CubicCage  = _controlCage.getCage(i);
	        	var b:CubicBezier = _bezier[i];
			
				b.x0 =c.P0X;
				b.y0 =c.P0Y;
				b.cx=c.P1X;
				b.cy=c.P1Y;
				b.cx1=c.P2X;
				b.cy1=c.P2Y;
				b.x1=c.P3X;	
				b.y1=c.P3Y;
		  	}
	
	      	invalidated = false;
	     	_parameterize();
	    }
	    
	    // parameterize composite curve - this function may vary based on the type of curve.
	    private function _parameterize():void{
	    	if( _param == Consts.ARC_LENGTH ){
	    		
		       	if( _arcLength == -1 )
		       		var len:Number = arcLength();
		
	        	_interpS.splice(0);
	        	_interpT.splice(0);
	        	_points.splice(0);
	                 
	        	// number of interpolation points per segment - min segment length gets four, everything else is proportional (up to a limit)
	       		for( var i:uint=0; i<_arcLengthAtSegments.length; ++i ){
	        		var ratio:Number = Math.floor(_arcLengthAtSegments[i]/_minSegLength);
	          		_points[i] = Math.min( 12, 4*ratio);
	        	}
	
	        	var normalize:Number = 1.0/_arcLength;
	
		        // x-coordinate of spline knot is normalized arc-length, y-coordinate 
		        //is t-value for uniform parameterization
		        _interpS[0] = 0;
		        _interpT[0] = 0;
		        var prevT:Number    = 0;
		        //var k:uint          = _knots.length;
		        var k:uint          = points.length;
		        var knotsInv:Number = 1.0/Number(k-1);
		        var indx:uint       = 1;
		        
		        for( i=1; i<k-1; i++ ){
		        	// get t-value at this knot for uniform parameterization
		          	var t:Number    = Number(i)*knotsInv;
		          	var pt:Number   = _points[i-1]+1;
		          	var count:uint  = uint(pt-1);
		          	var inc:Number  = 1.0/pt;
		          	var mult:Number = inc;
		          	for( var j:uint=0; j<count; ++j ){
		            	var t1:Number     = prevT + mult*(t-prevT);
		            	var l:Number      = arcLengthAt(t1)*normalize;
		            	_interpS[indx]   = l;
		            	_interpT[indx++] = t1;
		            
		          		mult += inc;
		          	}
		          
		        	l = arcLengthAt(t)*normalize;
		          	_interpS[indx]   = l;
		          	_interpT[indx++] = t;
		
		          	prevT = t;
		        }
	        
	
		        pt = _points[k-2]+1;
		        count = uint(pt-1);
		        inc = 1.0/pt;
		        mult = inc;
		        for( j=0; j<9; ++j ){
		        	t1 = prevT + mult*(1.0-prevT);
		          	l = arcLengthAt(t1)*normalize;
		          	_interpS[indx] = l;
		          	_interpT[indx++] = t1;
		          	mult += inc;
		        }
		        
		        // last knot, t=1, normalized arc-length = 1
		        _interpS[indx] = 1;
		        _interpT[indx] = 1;
			}
	    }
	    
	    // linear interpolation of arc length vs uniform parameter in open interval (0,1)
	    private function _interpolate(_s:Number):Number{
	    	// determine segment to narrow lookup
	      	var s:Number   = _s*_arcLength;
	      	var start:uint = 1;
	     
	      	for( var k:uint=0; k<_arcLengthAtSegments.length; ++k ){
	        	if( _arcLengthAtSegments[k] >= s ){
	          		start = k;
	          		break;
	        	}
	      	}
	
	      	start = start == 0 ? 1 : _points[start-1];
	      
	      	// determine specific lookup interval in the segment
	      	for( var i:uint=start; i<_interpS.length; ++i ){
	        	var knot:Number = _interpS[i];
	        	if( _s <= knot ){
	        		var knot1:Number = _interpS[i-1];
	          		var r:Number     = (_s-knot1)/(knot-knot1);
	          		return _interpT[i-1] + r*(_interpT[i] - _interpT[i-1]);
	        	}
	      	}
	      
	    	return 0;
	    }
    
	}
}