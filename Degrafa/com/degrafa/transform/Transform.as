////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 Jason Hawryluk, Juan Sanchez, Andy McIntosh, Ben Stucki, 
// Pavan Podila, Sean Chatman, Greg Dove and Thomas Gonzalez.
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

package com.degrafa.transform{
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	* Transform is a base transform class.  
	**/
	[DefaultProperty("data")]	
	public class Transform extends DegrafaObject implements ITransform{
		
		public var transformMatrix:Matrix=new Matrix();
		
		/**
		* Specifies whether this object is to be re calculated 
		* on the next cycle.
		**/
		public var invalidated:Boolean;
			
		private var _data:String;
		public function get data():String{
			return _data;
		}
		public function set data(value:String):void{
			_data=value;
		}
		
		
		
		
		private var _centerX:Number=0;
		/**
		* The center point of the transform along the x-axis.
		**/
		public function get centerX():Number{
			return _centerX;
		}
		public function set centerX(value:Number):void{
			
			if(_centerX != value){
				_centerX = value;
				invalidated = true;
			}
			
		}
		
		private var _centerY:Number=0;
		/**
		* The center point of the transform along the y-axis.
		**/
		public function get centerY():Number{
			return _centerY;
		}
		public function set centerY(value:Number):void{
			if(_centerY != value){
				_centerY = value;
				invalidated = true;
			}
			
		}
		
		//applies the transformation to the geometry
		public function apply(value:IGeometryComposition):void{
			
			//overriden by subclassees if required
			
			if(!invalidated){
				return;
			}
			
			invalidated = false;
			
			//make sure we have a valid command stack
			if(value.commandStack.length==0){return;}
						
			var currentPoint:Point=new Point();
			
			var item:Object;
			for each (item in value.commandStack){
				switch(item.type){
					
        			case "m":
        			case "l":
        				currentPoint.x=item.x;
        				currentPoint.y=item.y;
        				
        				//transform point
        				currentPoint = transformMatrix.transformPoint(currentPoint);
        			
        				item.x=currentPoint.x;
        				item.y=currentPoint.y;
        				break;
        			case "c":
        			
        				currentPoint.x=item.cx;
        				currentPoint.y=item.cy;
        			
        				//transform control
        				currentPoint= transformMatrix.transformPoint(currentPoint)
        			
        				item.cx=currentPoint.x;
        				item.cy=currentPoint.y;
        				
        				
        				currentPoint.x=item.x1;
        				currentPoint.y=item.y1;
        			
        				//transform anchor
        				currentPoint=transformMatrix.transformPoint(currentPoint)
        			
        				item.x1=currentPoint.x;
        				item.y1=currentPoint.y;
        				
        				break;
        		}
			}
		}
		
		/**
		* An Array of flash rendering commands that make up this element. 
		**/
		private var _commandStack:Array=[];
		public function get commandStack():Array{
			return _commandStack;
		}	
		public function set commandStack(value:Array):void{
			_commandStack=value;
		}
		
	}
}