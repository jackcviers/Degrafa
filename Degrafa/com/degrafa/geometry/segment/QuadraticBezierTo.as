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
package com.degrafa.geometry.segment{
	
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	import com.degrafa.geometry.utilities.GeometryUtils;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("QuadraticBezierTo.png")]
	
	//(Q,q,T,t) path data commands
	[Bindable]	
	/**
 	*  Defines a quadratic Bézier curve from the current point to 
 	*  (x,y) using (cx,cy) as the control point.
 	*  
 	*  @see http://www.w3.org/TR/SVG/paths.html#PathDataQuadraticBezierCommands
 	*  
 	**/
	public class QuadraticBezierTo extends Segment implements ISegment{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The QuadraticBezierTo constructor accepts 7 optional arguments that define it's 
	 	* data, properties, coordinate type and a flag that specifies a short sequence.</p>
	 	
	 	* @param cx A number indicating the x-coordinate of the control point of the curve. 
	 	* @param cy A number indicating the y-coordinate of the control point of the curve.
	 	* @param x A number indicating the x-coordinate of the end point of the curve.
	 	* @param y A number indicating the y-coordinate of the end point of the curve.
	 	* @param data A string indicating the data to be used for this segment.
	 	* @param coordinateType A string indicating the coordinate type to be used for this segment.
	 	* @param isShortSequence A boolean indicating the if this segment is a short segment definition. 
	 	**/
		public function QuadraticBezierTo(cx:Number=0,cy:Number=0,x:Number=0,y:Number=0,data:String=null,coordinateType:String="absolute",isShortSequence:Boolean=false){
			
			this.cx =cx;
			this.cy =cy;
			this.x =x;
			this.y =y;
			
			this.data =data;
			this.coordinateType=coordinateType;
			this.isShortSequence =isShortSequence
			
			registerClassAlias("com.degrafa.geometry.segment.QuadraticBezierTo", QuadraticBezierTo);	
			
		}
		
		/**
		* Return the segment type
		**/		
		override public function get segmentType():String{
			return "QuadraticBezierTo";
		}
				
		/**
		* QuadraticBezierTo short hand data value.
		* 
		* <p>The quadratic Bézier data property expects exactly 4 values 
		* cx, cy, x and y separated by spaces.</p>
		* 
		* @see Segment#data
		* 
		**/
		override public function set data(value:String):void{
			
			if(super.data != value){
				super.data = value;
			
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 4)
				{
					_cx=tempArray[0];
					_cy=tempArray[1];
					_x=tempArray[2];
					_y=tempArray[3];
				}
				invalidated = true;
			}
		}  
				
		private var _x:Number=0;
		/**
		* The x-coordinate of the end point of the curve. If not specified 
		* a default value of 0 is used.
		**/
		public function get x():Number{
			return _x;
		}
		public function set x(value:Number):void{
			if(_x != value){
				_x = value;
				invalidated = true;
			}
			
		}
		
		
		private var _y:Number=0;
		/**
		* The y-coordinate of the end point of the curve. If not specified 
		* a default value of 0 is used.
		**/
		public function get y():Number{
			return _y;
		}
		public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
		
				
		private var _cx:Number=0;
		/**
		* The x-coordinate of the control point of the curve. If not specified 
		* a default value of 0 is used.
		**/
		public function get cx():Number{
			return _cx;
		}
		public function set cx(value:Number):void{
			if(_cx != value){
				_cx = value;
				invalidated = true;
			}
		}
		
		
		private var _cy:Number=0;
		/**
		* The y-coordinate of the control point of the curve. If not specified 
		* a default value of 0 is used.
		**/
		public function get cy():Number{
			return _cy;
		}
		public function set cy(value:Number):void{
			if(_cy != value){
				_cy = value;
				invalidated = true;
			}
		}
		
		
		/**
		* Calculates the bounds for this segment. 
		**/	
		private function calcBounds():void{
			
			if(isShortSequence){
				_bounds = GeometryUtils.bezierBounds(lastPoint.x,lastPoint.y,lastPoint.x+(lastPoint.x-lastControlPoint.x),
				lastPoint.y+(lastPoint.y-lastControlPoint.y),absRelOffset.x+x,absRelOffset.y+y);
			}
			else{
				_bounds = GeometryUtils.bezierBounds(lastPoint.x,lastPoint.y,absRelOffset.x+cx,
				absRelOffset.y+cy,absRelOffset.x+x,absRelOffset.y+y);
			}
		}
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this segment as represented by a Rectangle object. 
		**/
		public function get bounds():Rectangle{
			return _bounds;	
		}
		
		/**
		* @inheritDoc 
		**/		
		override public function preDraw():void{
			calcBounds();
			invalidated = false;
		} 
		
		private var lastPoint:Point=new Point(NaN,NaN);
		private var absRelOffset:Point=new Point(NaN,NaN);
		private var lastControlPoint:Point=new Point(NaN,NaN);
		
		/**
		* Compute the segment adding instructions to the command stack. 
		**/
		public function computeSegment(firstPoint:Point,lastPoint:Point,absRelOffset:Point,lastControlPoint:Point,commandStack:CommandStack):void{
			
			if (!invalidated )
			{
				invalidated= (!lastPoint.equals(this.lastPoint) || !absRelOffset.equals(this.absRelOffset) || !lastControlPoint.equals(this.lastControlPoint))
			}
			
			
		
			if (invalidated){
			//not yet created need to build it 
			//otherwise just reset the values.
				if(!commandStackItem){	
					if(isShortSequence){
						commandStackItem = new CommandStackItem(CommandStackItem.CURVE_TO,
						NaN,
						NaN,
						absRelOffset.x+x,
						absRelOffset.y+y,
						lastPoint.x+(lastPoint.x-lastControlPoint.x),
						lastPoint.y+(lastPoint.y-lastControlPoint.y)
						);
					
						commandStack.addItem(commandStackItem);
					}
					else{
						commandStackItem = new CommandStackItem(CommandStackItem.CURVE_TO,
						NaN,
						NaN,
						absRelOffset.x+x,
						absRelOffset.y+y,
						absRelOffset.x+cx,
						absRelOffset.y+cy
						);
					
						commandStack.addItem(commandStackItem);
						
					}
				}
				else{
					if(isShortSequence){
						commandStackItem.cx = lastPoint.x+(lastPoint.x-lastControlPoint.x);
						commandStackItem.cy = lastPoint.y+(lastPoint.y-lastControlPoint.y),
						commandStackItem.x1 = absRelOffset.x+x,
						commandStackItem.y1 = absRelOffset.y+y;
					}
					else{
						commandStackItem.cx = absRelOffset.x+cx;
						commandStackItem.cy = absRelOffset.y+cy,
						commandStackItem.x1 = absRelOffset.x+x,
						commandStackItem.y1 = absRelOffset.y+y;
					}
				}
				this.lastPoint.x = lastPoint.x;
				this.lastPoint.y = lastPoint.y;
				this.absRelOffset.x = absRelOffset.x;
				this.absRelOffset.y = absRelOffset.y;
				this.lastControlPoint.x = lastControlPoint.x;
				this.lastControlPoint.y = lastControlPoint.y;				
			}
			
			//update the buildFlashCommandStack Point tracking reference
        		lastPoint.x = commandStackItem.x1;
				lastPoint.y = commandStackItem.y1;
				lastControlPoint.x = commandStackItem.cx;
				lastControlPoint.y = commandStackItem.cy;	
				
			
			//pre calculate the bounds for this segment
			preDraw();
		
		}
	}
}