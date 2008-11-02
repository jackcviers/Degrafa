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
	
	[IconFile("VerticalLineTo.png")]
	
	//(V or v) path data command
	[Bindable]	
	/**
 	*  A vertical line (V,v) segment is defined by a ending y-axis point.
 	*  
 	*  @see http://www.w3.org/TR/SVG/paths.html#PathDataLinetoCommands
 	*  
 	**/
	public class VerticalLineTo extends Segment implements ISegment{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The VerticalLineTo constructor accepts 3 optional arguments that define it's 
	 	* data, properties and a coordinate type.</p>
	 	* 
	 	* @param y A number indicating the y-coordinate of the end point of the line. 
	 	* @param data A string indicating the data to be used for this segment.
	 	* @param coordinateType A string indicating the coordinate type to be used for this segment.
	 	**/
		public function VerticalLineTo(y:Number=0,data:String=null,coordinateType:String="absolute"){
			
			this.y =y;
			
			this.data =data;
			this.coordinateType=coordinateType;
			this.isShortSequence = false;
			
				
		}
		
		/**
		* The isShortSequence property is ingnored on the VerticalLineTo segment and 
		* setting it will have no effect. 
		**/
		override public function get isShortSequence():Boolean{return false;}
		override public function set isShortSequence(value:Boolean):void{}
		
		/**
		* Return the segment type
		**/
		override public function get segmentType():String{
			return "VerticalLineTo";
		}
		
		/**
		* VerticalLineTo short hand data value.
		* 
		* <p>The vertical line to data property expects exactly 1 value 
		* y.</p>
		* 
		* @see Segment#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
				_y=Number(value);
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
			calcBounds();
			invalidated = false;
		} 
		
		private var lastPoint:Point=new Point(NaN,NaN);
		
		/**
		* Compute the segment adding instructions to the command stack. 
		**/
	public function computeSegment(firstPoint:Point,lastPoint:Point,lastControlPoint:Point,commandStack:CommandStack):void{
			
			if(!invalidated) {
				invalidated= (lastPoint.x!=this.lastPoint.x || (!this._absCoordType && lastPoint.y!=this.lastPoint.y) )
			}
			
			if(invalidated){
			
			if(!commandStackItem){	
				_commandStackItem = new CommandStackItem(CommandStackItem.LINE_TO,
				lastPoint.x,
				_absCoordType? _y:lastPoint.y + _y);
				
				commandStack.addItem(_commandStackItem);
			}
			else{
				_commandStackItem.x = lastPoint.x;
				_commandStackItem.y = _absCoordType? _y:lastPoint.y + _y;
			}
				//update this segment's Point tracking reference
				this.lastPoint.x = lastPoint.x;
				this.lastPoint.y = lastPoint.y;
			}
			
			
			//update the buildFlashCommandStack Point tracking reference
			lastPoint.y = _commandStackItem.y;

			
			//pre calculate the bounds for this segment
			preDraw();
			
			
		}
		
	}
}