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
////////////////////////////////////////////////////////////////////////////////
package com.degrafa.geometry{
	
	import com.degrafa.GraphicPoint;
	import com.degrafa.IGeometry;
	import com.degrafa.core.collections.GraphicPointCollection;
	import flash.geom.Point;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.events.PropertyChangeEvent;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("Polygon.png")]
	
	[DefaultProperty("points")]	
	
	[Bindable]	
	/**
 	*  The Polygon element draws a polygon using the specified points. 
 	*  
 	*  @see http://degrafa.com/samples/Polygon_Element.html	    
 	* 
 	**/
	public class Polygon extends Geometry implements IGeometry{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The polygon constructor accepts 1 optional argument that describes it's points.</p>
	 	* 
	 	* @param points An array of points describing the polygon.
	 	*/	
		public function Polygon(points:Array=null){
			super();
			
			if(points){
				this.points=points;
			}
			

		}
		
		/**
		* Polygon short hand data value.
		* 
		* <p>The polygon data property expects a list of space seperated points. For example
		* "10,20 30,35". </p>
		* 
		* @see Geometry#data
		* 
		**/
		override public function set data(value:String):void{
			
			if(super.data != value){
				
				super.data = value;
			
				//parse the string on the space
				var pointsArray:Array = value.split(" ");
				
				//create a temporary point array
				var pointArray:Array=[];
				var pointItem:Array;
				 
				//and then create a point struct for each resulting pair
				//eventually throw excemption is not matching properly
				var i:int = 0;
				var length:int = pointsArray.length;
				for (; i< length;i++){
					pointItem = String(pointsArray[i]).split(",");
					
					//skip past blank items as there may have been bad 
					//formatting in the value string, so make sure it is 
					//a length of 2 min	
					if(pointItem.length==2){
						pointArray.push(new GraphicPoint(pointItem[0],pointItem[1]));
					}
					
				}
				
				//set the points property
				points=pointArray;
			
				invalidated = true;
			
			}
			
			
		} 
		
		private var _points:GraphicPointCollection;
		[Inspectable(category="General", arrayType="com.degrafa.IGraphicPoint")]
		[ArrayElementType("com.degrafa.IGraphicPoint")]
		/**
		* A array of points that describe this polygon.
		**/
		public function get points():Array{
			initPointsCollection();
			return _points.items;
		}
		public function set points(value:Array):void{			
			initPointsCollection();
			_points.items = value;
						
			invalidated = true;
		
		}
		
		/**
		* Access to the Degrafa point collection object for this polyline.
		**/
		public function get pointCollection():GraphicPointCollection{
			initPointsCollection();
			return _points;
		}
		
		/**
		* Initialize the point collection by creating it and adding the event listener.
		**/
		private function initPointsCollection():void{
			if(!_points){
				_points = new GraphicPointCollection();
				
				//add a listener to the collection
				if(enableEvents){
					_points.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,propertyChangeHandler);
				}
			}
		}
		
		/**
		* Principle event handler for any property changes to a 
		* geometry object or it's child objects.
		**/
		override protected function propertyChangeHandler(event:PropertyChangeEvent):void{
			invalidated = true;
			super.propertyChangeHandler(event);
		}
		
		
		private var _x:Number;
		/**
		* The x-coordinate of the upper left point to begin drawing from. If not specified 
		* a default value of 0 is used.
		**/
		override public function get x():Number{
			if(!_x){return 0;}
			return _x;
		}
		override public function set x(value:Number):void{
			if(_x != value){
				_x = value;
				invalidated = true;
			}
		}
		
		
		private var _y:Number;
		/**
		* The y-coordinate of the upper left point to begin drawing from. If not specified 
		* a default value of 0 is used.
		**/
		override public function get y():Number{
			if(!_y){return 0;}
			return _y;
		}
		override public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
				
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
				
				if(!_points || !_points.items || _points.items.length<1){return;}
				
				commandStack.length=0;
				
				commandStack.addMoveTo(_points.items[0].x+x,_points.items[0].y+y);	
				
				var i:int = 0;
				var length:int = _points.items.length;
				for (;i < length; i++){
					commandStack.addLineTo(_points.items[i].x+x,_points.items[i].y+y);
				}	
			
				//close if not done already
				if (_points.items[_points.items.length-1].x+x !=_points.items[0].x+x || _points.items[_points.items.length-1].y+y !=_points.items[0].y+y){
					commandStack.addLineTo(_points.items[0].x+x,_points.items[0].y+y);
				}
				invalidated = false;
			}
		}
		
		/**
		* Performs the specific layout work required by this Geometry.
		* @param childBounds the bounds to be layed out. If not specified a rectangle
		* of (0,0,1,1) is used. 
		**/
		override public function calculateLayout(childBounds:Rectangle=null):void{
			if(_layoutConstraint){
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
					
					tempLayoutRect.x = (_x)? _x:0;
					tempLayoutRect.y = (_y)? _y:0;
					
					super.calculateLayout(tempLayoutRect);
						
					_layoutRectangle = _layoutConstraint.layoutRectangle;

				}
			}
		}
		
		

		
		private var _area:Number;
		
		/**
		 * experimental utility function to return the centroid of this polygon. Candidate for geometryUtils and generalization via commandstack
		 * ported from source: http://tog.acm.org/GraphicsGems/gemsiv/centroid.c
		 * STRIKE: returns null if the polygon is degenerate
		 * returns Point(NaN,NaN) if the polygon is degenerate or if the area is zero and there is no centroid
		 */
		public function get centroid():Point {
			var n:uint;
			if ((n=points.length)>2) {
				var j:uint = 0;
				var i:uint = n - 1;
				var atmp:Number = 0;
				var ai:Number = 0;
				var xtmp:Number = 0;
				var ytmp:Number = 0;
				_area = 0;
				for (; j < n; i = j, j++) {
					ai = points[i].x * points[j].y - points[j].x * points[i].y;
					atmp += ai;
					xtmp += (points[j].x + points[i].x) * ai;
					ytmp += (points[j].y + points[i].y) * ai;
				}
				_area = atmp *.5;
				if (_area != 0) {
					var mult:Number = 1 / (atmp * 3);
					return new Point(xtmp *mult, ytmp *mult);
				}
			//	else return new Point(NaN, NaN);
				}
		//	else return null;
			return new Point(NaN, NaN);
		}
		
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
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function set derive(value:Polygon):void{
			
			if (!fill){fill=value.fill;}
			if (!stroke){stroke = value.stroke}
			if (!_x){_x = value.x};
			if (!_y){_y = value.y};
			
			if (!_points && value.points.length!=0){points = value.points};
			
		}
		
	}
}