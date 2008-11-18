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
package com.degrafa.geometry.layout{
	import com.degrafa.geometry.command.CommandStack;
	import com.degrafa.geometry.command.CommandStackItem;
	import com.degrafa.geometry.utilities.GeometryUtils;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	* LayoutUtils is an all staic helper class for layout related tasks.
	**/
	public class LayoutUtils{
		
		public function LayoutUtils(){}
		
		private static var width:Number;
		private static var height:Number;
		private static var x:Number;
		private static var y:Number;
		
		/**
		* Proportionally sizes each point in the command array to the given width and height
		* taking into account any additional x or y offset that the command data may have. 
		* This ensures that rendering is always started at point(0,0) and that the maximum
		* allotted spaced is used for both width and height.  
		**/
    	public static function calculateRatios(commandStack:CommandStack,destinationRectangle:Rectangle):void{
			
			
			x = destinationRectangle.x;
			y = destinationRectangle.y;
			width = destinationRectangle.width;
			height = destinationRectangle.height;
			
			
			var minPoint:Point = new Point(Number.POSITIVE_INFINITY,Number.POSITIVE_INFINITY);
			var maxPoint:Point = new Point(0,0);
			
			var lastX:Number=0;
			var lastY:Number=0;
			
			getCommandStackMinMax(commandStack,maxPoint,minPoint,lastX,lastY);
						
			//apply the offset
			applyOffsetToCommandStack(commandStack,
			width/(maxPoint.x-minPoint.x),
			height/(maxPoint.y-minPoint.y),
			minPoint);
			
		}
		
		/**
		* Traverses the given command stack and calculates the min and max points.
		**/
		public static function getCommandStackMinMax(commandStack:CommandStack,maxPoint:Point,minPoint:Point,lastX:Number,lastY:Number):void{
						
			var bezierRect:Rectangle;
			
			var item:CommandStackItem;
			
			for each (item in commandStack.source){
				switch(item.type){
					case CommandStackItem.MOVE_TO:
					case CommandStackItem.LINE_TO:
						maxPoint.x =Math.max(maxPoint.x,item.x);
						maxPoint.y =Math.max(maxPoint.y,item.y);
						
						minPoint.x =Math.min(minPoint.x,item.x);
						minPoint.y =Math.min(minPoint.y,item.y);
						
						//store for next iteration
						lastX=item.x;
						lastY=item.y;
						break;
					case CommandStackItem.CURVE_TO:	
																	
						bezierRect = GeometryUtils.bezierBounds(lastX,lastY,
						item.cx,item.cy,item.x1,item.y1);
												
						//now take our bounds into account
						maxPoint.x =Math.max(maxPoint.x,bezierRect.x);
						maxPoint.y =Math.max(maxPoint.y,bezierRect.y);
						
						maxPoint.x =Math.max(maxPoint.x,bezierRect.x+bezierRect.width);
						maxPoint.y =Math.max(maxPoint.y,bezierRect.y+bezierRect.height);
						
						minPoint.x =Math.min(minPoint.x,bezierRect.x);
						minPoint.y =Math.min(minPoint.y,bezierRect.y);
						
						minPoint.x =Math.min(minPoint.x,bezierRect.x+bezierRect.width);
						minPoint.y =Math.min(minPoint.y,bezierRect.y+bezierRect.height);
												
						//store for next iteration
						lastX=item.x1;
						lastY=item.y1;
						break;
						
					case CommandStackItem.COMMAND_STACK:
						//recurse
						getCommandStackMinMax(item.commandStack,maxPoint,minPoint,lastX,lastY);
						break;
				}
			}
					
		}
		
		
		/**
		* Traverses through the given command stack applying the offset.
		**/
		public static function applyOffsetToCommandStack(commandStack:CommandStack,xMultiplier:Number,yMultiplier:Number,minPoint:Point,lastPoint:Point=null):void{
			
			var item:CommandStackItem;
			
			//keep last point for recursion and setting the origin
			if(!lastPoint){
				lastPoint=minPoint.clone();
			}
			
			//multiply the axis by the difference
			for each (item in commandStack.source){
				switch(item.type){
					case CommandStackItem.MOVE_TO:
					case CommandStackItem.LINE_TO:
						if(item.x!=0){
							item.x = (item.x-minPoint.x) * xMultiplier;
						}
						if(item.y!=0){
							item.y = (item.y-minPoint.y) * yMultiplier;
						}
						
						//offset according to x and y
						item.x += x;
						item.y += y;
						
						lastPoint.x=item.x;
						lastPoint.y=item.y;
						
						break;
					case CommandStackItem.CURVE_TO:	
						if(item.cx!=0){
							item.cx = (item.cx-minPoint.x) * xMultiplier;
						} 
						if(item.cy!=0){
							item.cy = (item.cy-minPoint.y) * yMultiplier;
						}
						if(item.x1!=0){
							item.x1 = (item.x1-minPoint.x) * xMultiplier;
						}
						
						if(item.y1!=0){
							item.y1 = (item.y1-minPoint.y) * yMultiplier;
						}
						
						//offset according to x and y
						item.cx += x;
						item.cy += y;
						item.x1 += x;
						item.y1 += y;
						
						lastPoint.x=item.x1;
						lastPoint.y=item.y1;
						
						break;
					case CommandStackItem.COMMAND_STACK:
						//recurse
						applyOffsetToCommandStack(item.commandStack,xMultiplier,yMultiplier,minPoint,lastPoint);
						break;	
				}
							
			}
		}
	}
}