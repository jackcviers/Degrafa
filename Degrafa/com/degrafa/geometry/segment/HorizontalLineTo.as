////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 Jason Hawryluk, Juan Sanchez, Andy McIntosh, Ben Stucki 
// and Pavan Podila.
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
	
	import com.degrafa.geometry.command.CommandStackItem;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Exclude(name="isShortSequence", kind="property")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("HorizontalLineTo.png")]
	
	//(H or h) path data command
	[Bindable]	
	/**
 	*  A horizontal line (H,h) segment is defined by a ending x-axis point.
 	*  
 	*  @see http://www.w3.org/TR/SVG/paths.html#PathDataLinetoCommands
 	*  
 	**/
	public class HorizontalLineTo extends Segment implements ISegment{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The HorizontalLineTo constructor accepts 3 optional arguments that define it's 
	 	* data, properties and a coordinate type.</p>
	 	* 
	 	* @param x A number indicating the x-coordinate of the end point of the line. 
	 	* @param data A string indicating the data to be used for this segment.
	 	* @param coordinateType A string indicating the coordinate type to be used for this segment.
	 	**/
		public function HorizontalLineTo(x:Number=0,data:String=null,coordinateType:String="absolute"){
			
			this.x =x;
			
			this.data =data;
			this.coordinateType=coordinateType;
			this.isShortSequence = false;		
		}
		
		/**
		* The isShortSequence property is ingnored on the HorizontalLineTo segment and 
		* setting it will have no effect. 
		**/
		override public function get isShortSequence():Boolean{return false;}
		override public function set isShortSequence(value:Boolean):void{}
		
		/**
		* Return the segment type
		**/
		override public function get segmentType():String{
			return "HorizontalLineTo";
		}
		
		/**
		* HorizontalLineTo short hand data value.
		* 
		* <p>The horizontal line to data property expects exactly 1 value 
		* x.</p>
		* 
		* @see Segment#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
				_x=Number(value);
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
		
		
		/**
		* Calculates the bounds for this segment. 
		**/	
		private function calcBounds():void{
			_bounds = new Rectangle(Math.min(lastPoint.x,absRelOffset.x+x),
			Math.min(lastPoint.y,lastPoint.y), absRelOffset.x+x-lastPoint.x,
			lastPoint.y-lastPoint.y);
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
		
		private var lastPoint:Point;
		private var absRelOffset:Point;
		
		/**
		* Compute the segment adding instructions to the command stack. 
		**/
		public function computeSegment(lastPoint:Point,absRelOffset:Point,commandArray:Array):void{
			
			if(!invalidated && lastPoint){
				if(this.lastPoint && !invalidated){
					if(!lastPoint.equals(this.lastPoint)){
						invalidated =true;
					}
				}
			}
			
			if(!invalidated && absRelOffset){
				if(this.absRelOffset && !invalidated){
					if(!absRelOffset.equals(this.absRelOffset)){
						invalidated =true;
					}
				}
			}
			
			var item:Object;
			
			if(!invalidated){
				for each(item in this.commandArray){
					commandArray.push(item);		
				}
			}
			
			//reset the array
			this.commandArray=[];
						
			this.commandArray.push(new CommandStackItem(CommandStackItem.LINE_TO,absRelOffset.x+x,lastPoint.y));
        	
        	//create a return command array adding each item from the local array
			for each(item in this.commandArray){
				commandArray.push(item);
			}
        	
			this.lastPoint =lastPoint;
			this.absRelOffset=absRelOffset;
			
			//pre calculate the bounds for this segment
			preDraw();
			
			//old just for refference tilltesting complete
        	//calcBounds(lastPoint,new Point(absRelOffset.x+x,lastPoint.y));
			
		}
		
		
	}
}