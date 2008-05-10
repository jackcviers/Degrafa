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

package com.degrafa.transform{
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.DegrafaObject;
	import com.degrafa.geometry.command.CommandStackItem;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	* Transform is a base transform class.  
	**/
	[DefaultProperty("data")]	
	public class Transform extends DegrafaObject implements ITransform{
		
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
		
		private var _transformMatrix:Matrix=new Matrix();
		
		protected function get transformMatrix():Matrix{
			return _transformMatrix;
		}
		protected function set transformMatrix(value:Matrix):void{
			_transformMatrix=value;
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
		
		protected var _registrationPoint:String;
		[Inspectable(category="General", enumeration="topLeft,centerLeft,bottomLeft,centerTop,center,centerBottom,topRight,centerRight,bottomRight")]
		/**
		* A value defining one of 9 possible registration points.
		**/
		public function get registrationPoint():String{
			return _registrationPoint;
		}
		public function set registrationPoint(value:String):void{			
			if(_registrationPoint != value){
				var oldValue:String=_registrationPoint;
				_registrationPoint = value;
			}
		}
		
		//pre cals but does not apply the matrix
		public function preCalculateMatrix(value:IGeometryComposition):Matrix{
			//overridden
			return null;
		}
		
		//calculates and applies the transformation to the geometry
		public function apply(value:IGeometryComposition):void{
			
			//overriden by subclassees if required
			
			if(!invalidated){
				return;
			}
			
			invalidated = false;
			
			//make sure we have a valid command stack
			if(value.commandStack.source.length==0){return;}
						
			var currentPoint:Point=new Point();
			
			var item:CommandStackItem;
			for each (item in value.commandStack.source){
				switch(item.type){
					
        			case CommandStackItem.MOVE_TO:
        				currentPoint.x=item.x;
        				currentPoint.y=item.y;
        				
        				//transform point
        				currentPoint = transformMatrix.transformPoint(currentPoint);
        			
        				item.x=currentPoint.x;
        				item.y=currentPoint.y;
        				break;
        				
        			case CommandStackItem.LINE_TO:
        				currentPoint.x=item.x1;
        				currentPoint.y=item.y1;
        				
        				//transform point
        				currentPoint = transformMatrix.transformPoint(currentPoint);
        			
        				item.x1=currentPoint.x;
        				item.y1=currentPoint.y;
        				break;
        			case CommandStackItem.CURVE_TO:
        			
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
		
		protected function getRegistrationPoint(value:IGeometryComposition):Point{
			
			var regPoint:Point;
			
			switch(_registrationPoint){
				
				case "topLeft":
					regPoint = value.bounds.topLeft;
					break;
				case "centerLeft":
					regPoint = new Point(value.bounds.left,value.bounds.y+value.bounds.height/2);
					break;
				case "bottomLeft":
					regPoint = new Point(value.bounds.left,value.bounds.bottom);
					break;
				case "centerTop":
					regPoint = new Point(value.bounds.x+value.bounds.width/2,value.bounds.y);
					break;
				case "center":
					regPoint = new Point(value.bounds.x+value.bounds.width/2,value.bounds.y+value.bounds.height/2);
					break;
				case "centerBottom":
					regPoint = new Point(value.bounds.x+value.bounds.width/2,value.bounds.bottom);
					break;
				case "topRight":
					regPoint = new Point(value.bounds.right,value.bounds.top);
					break;
				case "centerRight":
					regPoint = new Point(value.bounds.right,value.bounds.y+value.bounds.height/2);
					break;
				case "bottomRight":
					regPoint = value.bounds.bottomRight;
					break;
				
			}
			
			return regPoint;
			
		}
		
		
	}
}