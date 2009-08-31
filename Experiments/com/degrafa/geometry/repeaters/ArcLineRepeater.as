////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 Jason Hawryluk, Juan Sanchez, Andy McIntosh, Ben Stucki 
// and Pavan Podila.
//
//	Rev 4/2/2008 Tom Gonzalez
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
package com.degrafa.geometry.repeaters{
	
	import com.degrafa.geometry.Line;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------

	
	[Exclude(name="fill", kind="property")]
	[Bindable]
	/**
 	*  The CircleLineRepeater element draws a straight line using the specified x, y, 
 	 * and y1 coordinate values. Then progressively repeats the line using count and offsets.
 	*  
 	*  @see http://samples.degrafa.com/VerticalLineRepeater/VerticalLineRepeater.html	    
 	* 
 	**/		
	public class ArcLineRepeater extends Repeater{
	
		/**
	 	* Constructor.
	 	*  
	 	* <p>The vertical line repeater constructor accepts 3 optional arguments that define it's 
	 	* center point and radius; as well as 5 arguments to repeat, including count and offsets.</p>
	 	* 
	 	* @param startAngle A number indicating the starting angle coordinate.
	 	* @param innerRadius A number indicating the inner radius of the lines to be repeated.
	 	* @param outerRadius A number indicating the outer radius of the lines to be repeated.
	 	* @param angleOffset An angle number indicating the angle offset of each line repeated.
	 	* @param centerXOffset A number indicating the x-axis offset for the center of the arc, a 0 value will center the arc within your component bounds.
	 	* @param centerYOffset A number indicating the y-axis offset for the center of the arc, a 0 value will center the arc within your component bounds.
	 	*/
		public function ArcLineRepeater(startAngle:Number=0, endAngle:Number=360, innerRadius:Number=0, 
		outerRadius:Number=10, angleOffset:Number=1, centerXOffset:Number=0, centerYOffset:Number=0){
			
			super();
			this.startAngle=startAngle;
			this.endAngle=endAngle;
			this.innerRadius=innerRadius;
			this.outerRadius=outerRadius;
			this.angleOffset=angleOffset;
			this.centerXOffset=centerXOffset;
			this.centerYOffset=centerYOffset;
	
			
		}


		override public function set data(value:Object):void {
			//TODO - Talk to Jason about what really needs to get set here.
		}
		
		
		override public function set count(value:Number):void {
			//Do nothing this is now read only and calculated by start/end angle and angle offset
			
			//Question, does this violate the way all the other components work?  Perhaps instead
			// 	we need to provide a utility function that autocalcs on this.
			
		}
		
		override public function get count():Number {
			return _count;	
		}
		
		private var _count:Number=0;
		
		private var _innerRadius:Number=0;
		/**
		* The inner radius for the arc of repeated lines. If not specified 
		* a default value of 0 is used.
		**/
		public function get innerRadius():Number{
			return _innerRadius;
		}
		public function set innerRadius(value:Number):void{
			if(_innerRadius != value){
				_innerRadius = value;
				invalidated=true;
			}
		}
	
		private var _outerRadius:Number=10;
		/**
		* The outer radius for the arc of repeated lines. If not specified 
		* a default value of 10 is used.
		**/
		public function get outerRadius():Number{
			return _outerRadius;
		}
		public function set outerRadius(value:Number):void{
			if(_outerRadius != value){
				_outerRadius = value;
				invalidated=true;
			}
		}
	
		private var _angleOffset:Number=2;
		/**
		* The angle offset of each repeated line. If not specified 
		* a default value of 2 is used.
		**/
		public function get angleOffset():Number{
			return _angleOffset;
		}
		public function set angleOffset(value:Number):void{
			if(_angleOffset != value){
				_angleOffset = value;
				invalidated=true;
			}
		}
		
		private var _centerXOffset:Number=2;
		/**
		* The x-offset for the center of the arc's rotation 
		**/
		public function get centerXOffset():Number{
			return _centerXOffset;
		}
		public function set centerXOffset(value:Number):void{
			if(_centerXOffset != value){
				_centerXOffset = value;
				invalidated=true;
			}
		}
		
		private var _centerYOffset:Number=2;
		/**
		* The y-offset for the center of the arc's rotation 
		**/
		public function get centerYOffset():Number{
			return _centerYOffset;
		}
		public function set centerYOffset(value:Number):void{
			if(_centerYOffset != value){
				_centerYOffset = value;
				invalidated=true;
			}
		}
			
		
		private var _startAngle:Number=0;
		/**
		* The angle of the start point of the first line. If not specified 
		* a default value of 0 is used.
		**/
		public function get startAngle():Number{
			return _startAngle;
		}
		public function set startAngle(value:Number):void{
			if(_startAngle != value){
				_startAngle = value;
				invalidated=true;
			}
		}			
		
		private var _endAngle:Number=0;
		/**
		* The angle of the start point of the first line. If not specified 
		* a default value of 0 is used.
		**/
		public function get endAngle():Number{
			return _endAngle;
		}
		public function set endAngle(value:Number):void{
			if(_endAngle != value){
				_endAngle = value;
				invalidated=true;
			}
		}	
				
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			return _bounds;	
		}
		
		
		/**
		* Calculates the bounds for this element. 
		**/
		private function calcBounds(unionRectangle:Rectangle):void{
			
			if(_bounds){
				_bounds = _bounds.union(unionRectangle);
			}
			else{
				_bounds = unionRectangle;
			}
		}	
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated){
				
				objectStack=[];
				_bounds = null;
				
				//Figure out our count based on start/end angle and the angle offset
				_count=(_endAngle-startAngle)/_angleOffset;
				
				var angle:Number=_angleOffset;
		
				var newLine:Line;
	    	    //loop calc and add the line for each count    	
	        	for (var i:int = 0;i<= count;i++){	
	        		
	        		
	        		//figure out our x/y start stops for the line
	        		var lineX:Number=centerXOffset+innerRadius*Math.sin((i*angle+startAngle)*Math.PI/180);
	        		var lineY:Number=centerYOffset+innerRadius*Math.cos((i*angle+startAngle)*Math.PI/180);
	        		var lineX1:Number=centerXOffset+outerRadius*Math.sin((i*angle+startAngle)*Math.PI/180);;
	        		var lineY1:Number=centerYOffset+outerRadius*Math.cos((i*angle+startAngle)*Math.PI/180);
	
	        		
	    			newLine = new Line(lineX,lineY,lineX1,lineY1);
	    		  	
	    		  	newLine.stroke = stroke;
	    			newLine.fill = fill;
					
					//add to the bounds
					newLine.preDraw();
        			calcBounds(newLine.bounds);
        		
        			objectStack.push(newLine);
        		
				}
			
				invalidated=false;	
			}
		}
		
		/**
		* An Array of geometry objects that make up this repeater. 
		**/
		protected var objectStack:Array=[];	
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/		
		override public function draw(graphics:Graphics,rc:Rectangle):void{			
			
			preDraw();
			
        	var item:Line
        	
        	for each (item in objectStack){
        		//draw the item
				item.draw(graphics,rc);
			}    
        		
			
		}
		
	}
}