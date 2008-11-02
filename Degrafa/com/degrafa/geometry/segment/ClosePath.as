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
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("ClosePath.png")]
	
	//close path to the last used move
	//(Z or z) path data command
	[Exclude(name="data", kind="property")]
	[Exclude(name="coordinateType", kind="property")]
	[Exclude(name="isShortSequence", kind="property")]
	/**
	* The "closepath" (Z or z) ends the current subpath 
	* by drawing a straight line from the current point to 
	* current subpath's initial point.
	* 
	* @see http://www.w3.org/TR/SVG/paths.html#PathDataClosePathCommand 
	* 
	**/
	public class ClosePath extends Segment implements ISegment{
		public function ClosePath(){
			
			super();
					
		}
		
		/**
		* Setting data on ClosePath has no effect
		**/
		override public function set data(value:String):void{}
		override public function get data():String{return null;}
		
		/**
		* Setting coordinateType on ClosePath has no effect
		**/
		override public function set coordinateType(value:String):void{}
		override public function get coordinateType():String{return null;}
		
		/**
		* Setting isShortSequence on ClosePath has no effect
		**/
		override public function get isShortSequence():Boolean{return false;};
		override public function set isShortSequence(value:Boolean):void{};
		
		/**
		* Return the segment type
		**/
		override public function get segmentType():String{
			return "ClosePath";
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
		private var firstPoint:Point=new Point(NaN,NaN);
		
		/**
		* Compute the segment adding instructions to the command stack. 
		**/
		public function computeSegment(firstPoint:Point,lastPoint:Point,lastControlPoint:Point,commandStack:CommandStack):void{
			
			if (!invalidated )
				{
					invalidated= (!lastPoint.equals(this.lastPoint) || !firstPoint.equals(this.firstPoint) )
				}
			
			if (invalidated){
				if(!_commandStackItem){	
					_commandStackItem = new CommandStackItem(CommandStackItem.LINE_TO,firstPoint.x,firstPoint.y);
					commandStack.addItem(_commandStackItem);
				}
				else{
					_commandStackItem.x = firstPoint.x;
					_commandStackItem.y = firstPoint.y;
				}
				//update this segment's point references
				this.lastPoint.x = lastPoint.x;
				this.lastPoint.y = lastPoint.y;
				this.firstPoint.x = firstPoint.x;
				this.firstPoint.y = firstPoint.y;
			}
			//update the buildFlashCommandStack Point tracking reference
        		lastPoint.x = _commandStackItem.x;
				lastPoint.y = _commandStackItem.y;
				
			//pre calculate the bounds for this segment
			preDraw();
			
		}
	}
}