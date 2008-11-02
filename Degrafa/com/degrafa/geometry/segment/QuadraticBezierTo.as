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
		
		private var _bounds:Rectangle;
		/**
		* The tight bounds of this segment as represented by a Rectangle object. 
		**/
		public function get bounds():Rectangle{
			return commandStackItem.bounds;	
		}
		
		/**
		* @inheritDoc 
		**/		
		override public function preDraw():void{
			invalidated = false;
		} 
		
		private var lastPoint:Point=new Point(NaN,NaN);
		private var lastControlPoint:Point=new Point(NaN,NaN);
		
		/**
		* Compute the segment adding instructions to the command stack. 
		**/
		public function computeSegment(firstPoint:Point,lastPoint:Point,lastControlPoint:Point,commandStack:CommandStack):void{
			
			if (!invalidated )
			{
				invalidated= (!lastPoint.equals(this.lastPoint) || !lastControlPoint.equals(this.lastControlPoint))
			}
			
			
		
			if (invalidated){
			//not yet created need to build it 
			//otherwise just reset the values.
				if(!commandStackItem){	
					if(_isShortSequence){
						_commandStackItem = new CommandStackItem(CommandStackItem.CURVE_TO,
						NaN,
						NaN,
						_absCoordType? x:lastPoint.x+_x,
						_absCoordType? y:lastPoint.y+_y,
						lastPoint.x+(lastPoint.x-lastControlPoint.x),
						lastPoint.y+(lastPoint.y-lastControlPoint.y)
						);
					
						commandStack.addItem(_commandStackItem);
					}
					else{
						_commandStackItem = new CommandStackItem(CommandStackItem.CURVE_TO,
						NaN,
						NaN,
						_absCoordType? _x:lastPoint.x+_x,
						_absCoordType? _y:lastPoint.y+_y,
						_absCoordType? _cx:lastPoint.x+_cx,
						_absCoordType? _cy:lastPoint.y+_cy
						);
					
						commandStack.addItem(_commandStackItem);
						
					}
				}
				else{  
					if(isShortSequence){
						_commandStackItem.cx = lastPoint.x+(lastPoint.x-lastControlPoint.x);
						_commandStackItem.cy = lastPoint.y+(lastPoint.y-lastControlPoint.y),
						_commandStackItem.x1 = _absCoordType? _x:lastPoint.x+_x,
						_commandStackItem.y1 = _absCoordType? _y:lastPoint.y+_y;
					}
					else
					{
						if (_absCoordType)
						{
						_commandStackItem.cx = _cx;
						_commandStackItem.cy = _cy;
						_commandStackItem.x1 = _x;
						_commandStackItem.y1 = _y;
						} else {
						_commandStackItem.cx = lastPoint.x + _cx;
						_commandStackItem.cy = lastPoint.y + _cy;
						_commandStackItem.x1 = lastPoint.x + _x;
						_commandStackItem.y1 = lastPoint.y + _y;
						}
						
					}
				}
				//update this segment's point references
				this.lastPoint.x = lastPoint.x;
				this.lastPoint.y = lastPoint.y;
				this.lastControlPoint.x = lastControlPoint.x;
				this.lastControlPoint.y = lastControlPoint.y;				
			}
			
			//update the buildFlashCommandStack Point tracking reference
        		lastPoint.x = _commandStackItem.x1;
				lastPoint.y = _commandStackItem.y1;
				lastControlPoint.x = _commandStackItem.cx;
				lastControlPoint.y = _commandStackItem.cy;	
				
			
			//pre calculate the bounds for this segment
			preDraw();
		
		}
	}
}