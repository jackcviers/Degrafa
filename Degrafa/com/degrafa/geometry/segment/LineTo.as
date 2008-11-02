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
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	[Exclude(name="isShortSequence", kind="property")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("LineTo.png")]
		
	//(L or l) path data command
	[Bindable]	
	/**
 	*  A line (L,l) segment is defined by a ending x-axis and y-axis point.
 	*  
 	*  @see http://www.w3.org/TR/SVG/paths.html#PathDataLinetoCommands
 	*  
 	**/
	public class LineTo extends Segment implements ISegment{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The LineTo constructor accepts 4 optional arguments that define it's 
	 	* data, properties and a coordinate type.</p>
	 	
	 	* @param x A number indicating the x-coordinate of the end point of the line.  
	 	* @param y A number indicating the y-coordinate of the end point of the line. 
	 	* @param data A string indicating the data to be used for this segment.
	 	* @param coordinateType A string indicating the coordinate type to be used for this segment.
	 	**/
		public function LineTo(x:Number=0,y:Number=0,data:String=null,coordinateType:String="absolute"){
			
			this.x =x;
			this.y =y;
			
			this.data =data;
			this.coordinateType=coordinateType;
			this.isShortSequence = false;
			
			
		}
		
		/**
		* The isShortSequence property is ingnored on the LineTo segment and 
		* setting it will have no effect. 
		**/
		override public function get isShortSequence():Boolean{return false;}
		override public function set isShortSequence(value:Boolean):void{}
		
		/**
		* Return the segment type
		**/
		override public function get segmentType():String{
			return "LineTo";
		}
		
		/**
		* LineTo short hand data value.
		* 
		* <p>The line to data property expects exactly 2 values 
		* x and y.</p>
		* 
		* @see Segment#data
		* 
		**/
		override public function set data(value:String):void{
			
			if(super.data != value){
				super.data = value;
				
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 2)
				{
					_x=tempArray[0];
					_y=tempArray[1];
				}
				
				invalidated = true;
			}
		}  		
						
		private var _x:Number=0;
		/**
		* The x-coordinate of the end point of the line. If not specified 
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
		* The y-coordinate of the end point of the line. If not specified 
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
		
		public var lastPoint:Point=new Point(NaN,NaN);
		
		/**
		* Compute the segment adding instructions to the command stack. 
		**/
		public function computeSegment(firstPoint:Point,lastPoint:Point,lastControlPoint:Point,commandStack:CommandStack):void{
		
			if (!invalidated )
				{
					invalidated= (!lastPoint.equals(this.lastPoint)  )
				}

			if(invalidated){
		
				if(!_commandStackItem){	
					_commandStackItem = new CommandStackItem(CommandStackItem.LINE_TO,_absCoordType? _x: lastPoint.x+_x,_absCoordType? _y: lastPoint.y+_y);
					commandStack.addItem(_commandStackItem);
				}
				else
				{
					if (_absCoordType)
					{
					_commandStackItem.x = _x;
					_commandStackItem.y = _y
					} else {
					_commandStackItem.x = lastPoint.x + _x;
					_commandStackItem.y = lastPoint.y + _y;
					}
				}
				
				//update this segment's point references
				this.lastPoint.x = lastPoint.x;
				this.lastPoint.y = lastPoint.y;	
			}
			
			//update the buildFlashCommandStack Point tracking reference
        		lastPoint.x = _commandStackItem.x;
				lastPoint.y = _commandStackItem.y;

			//pre calculate the bounds for this segment
			preDraw();
		}
		
	}
}