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
	
	[IconFile("CubicBezierTo.png")]
	
	//(C,c,S,s) path data commands
	[Bindable]	
	/**
 	*  A cubic Bézier (C,c S,s) segment is defined by a end point and two control points.
 	*  
 	*  @see http://www.w3.org/TR/SVG/paths.html#PathDataCubicBezierCommands
 	*  
 	**/	
	public class CubicBezierTo extends Segment implements ISegment{
		/**
	 	* Constructor.
	 	*  
	 	* <p>The CubicBezierTo constructor accepts 9 optional arguments that define it's 
	 	* data, properties, coordinate type and a flag that specifies a short sequence.</p>
	 	* 
	 	* @param cx A number indicating the x-coordinate of the first control point of the curve. 
	 	* @param cy A number indicating the y-coordinate of the first control point of the curve.
	 	* @param cx1 A number indicating the x-coordinate of the second control point of the curve.
	 	* @param cy1 A number indicating the y-coordinate of the second control point of the curve.   
	 	* @param x A number indicating the x-coordinate of the end point of the curve.
	 	* @param y A number indicating the y-coordinate of the end point of the curve.
	  	* @param data A string indicating the data to be used for this segment.
	 	* @param coordinateType A string indicating the coordinate type (absolute or relative) to be used for this segment.
	 	* @param isShortSequence A boolean indicating the if this segment is a short segment definition. 
	 	**/
		public function CubicBezierTo(cx:Number=0,cy:Number=0,cx1:Number=0,cy1:Number=0,x:Number=0,y:Number=0,
		data:String=null,coordinateType:String="absolute",isShortSequence:Boolean=false){
			
			this.cx =cx;
			this.cy =cy;
			this.cx1 =cx1;
			this.cy1 =cy1;
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
			return "CubicBezierTo";
		}


		/**
		* CubicBezierTo short hand data value.
		* 
		* <p>The cubic Bézier data property expects exactly 6 values 
		* cx, cy, cx1, cy1, x and y separated by spaces.</p>
		* 
		* @see Segment#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
				
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 6){
					_cx=tempArray[0];
					_cy=tempArray[1];
					_cx1=tempArray[2];
					_cy1=tempArray[3];
					_x=tempArray[4];
					_y=tempArray[5];
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
		* The x-coordinate of the first control point of the curve. If not specified 
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
		* The y-coordinate of the first control point of the curve. If not specified 
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
		
		
		private var _cx1:Number=0;
		/**
		* The x-coordinate of the second control point of the curve. If not specified 
		* a default value of 0 is used.
		**/
		public function get cx1():Number{
			return _cx1;
		}
		public function set cx1(value:Number):void{
			if(_cx1 != value){
				_cx1 = value;
				invalidated = true;
			}
		}
		
		
		private var _cy1:Number=0;
		/**
		* The y-coordinate of the second control point of the curve. If not specified 
		* a default value of 0 is used.
		**/
		public function get cy1():Number{
			return _cy1;
		}
		public function set cy1(value:Number):void{
			if(_cy1 != value){
				_cy1 = value;
				invalidated = true;
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
		* Calculates the bounds for this segment. 
		**/	
		private function calcBounds():Rectangle{
			
			if(_commandStackItem.commandStack.length==0){return null;}
			
			
			var newx:Number = _absCoordType? x:lastPoint.x + x;
			var newy:Number = _absCoordType? y:lastPoint.y + y;
			var item:CommandStackItem;
			var lpX:Number;
			var lpY:Number;
			if (_bounds) { //re-use the existing Rectangle instance
				_bounds.x = Math.min(lastPoint.x, newx);
				_bounds.y = Math.min(lastPoint.y, newy);
				_bounds.bottom = Math.max(lastPoint.y, newy);
				_bounds.right = Math.max(lastPoint.x, newx);
				
			} else 	_bounds = new Rectangle(Math.min(lastPoint.x, newx), Math.min(lastPoint.y, newy), Math.abs(lastPoint.x - newx), Math.abs(lastPoint.y - newy));

			for each(item in _commandStackItem.commandStack.source){
				with(item)
					{
						if (type == CommandStackItem.LINE_TO) {
							_bounds = _bounds.union(new Rectangle(Math.min(lpX?lpX:lastPoint.x, x), Math.min(lpY?lpY:lastPoint.y), Math.abs(lpX?lpX:lastPoint.x - x), Math.abs(lpY?lpY:lastPoint.y - y)));
							lpX = x;
							lpY = y;
						}
						else {
						_bounds = _bounds.union(GeometryUtils.bezierBounds(lpX?lpX:lastPoint.x, lpY?lpY:lastPoint.y, cx, cy, x1, y1));
						lpX = x1;
						lpY = y1;
						}
					}
			}
			//adjustment for horizontal and vertical lines
			if (_bounds.width == 0) _bounds.width = 0.0001;
			if (_bounds.height == 0) _bounds.height = 0.0001;

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
		private var lastControlPoint:Point=new Point(NaN,NaN);
		private static var _cy1Offset:Number =0.000001;
		/**
		* Compute the segment adding instructions to the command stack. 
		**/
		public function computeSegment(firstPoint:Point,lastPoint:Point,lastControlPoint:Point,commandStack:CommandStack):void{
			
			if (!invalidated )
			{
				invalidated= (!lastPoint.equals(this.lastPoint) || !lastControlPoint.equals(this.lastControlPoint))
			}
			//if the last controly and the y are the same add a 
			//minute offset to avoid a display parasite that 
			//can sometimes occur from this.
			var cy1Offset:Number = (_cy1 == _y)? _cy1Offset:0;
			
			//some early references to the updated last tracking point coords in case we exit early
			var nlcpx:Number;
			var nlcpy:Number;
			var nlpx:Number; 
			var nlpy:Number;
			if (_absCoordType)
			{
				nlcpx = _cx1; nlcpy = cy1Offset + _cy1; nlpx = _x; nlpy = _y;
				
			} else {
				nlcpx = lastPoint.x + _cx1;
				nlcpy = lastPoint.y + _cy1 + cy1Offset;;
				nlpx = lastPoint.x + _x;
				nlpy = lastPoint.y + _y;				
			}
			
			//test if anything has changed and only recalculate if something has
			if(invalidated){
			
				var isNewItem:Boolean;
				
				//add for the first run
				if(!_commandStackItem){			
					_commandStackItem = new CommandStackItem(CommandStackItem.COMMAND_STACK,
					NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack());
					
					isNewItem =true;
				}
				
				//clear the array in this case as it's a complex item
				_commandStackItem.commandStack.length=0;
							
				 if(_isShortSequence){
                                        
						GeometryUtils.cubicToQuadratic(
						lastPoint.x,lastPoint.y,
						lastPoint.x+(lastPoint.x-lastControlPoint.x),lastPoint.y+(lastPoint.y-lastControlPoint.y),
						nlcpx,nlcpy,
						nlpx,nlpy,
						1,_commandStackItem.commandStack);
				}
				else{
						GeometryUtils.cubicToQuadratic(
						lastPoint.x,lastPoint.y,
						_absCoordType? _cx:lastPoint.x+_cx,_absCoordType ? _cy : lastPoint.y+_cy,
						nlcpx,nlcpy,
						nlpx,nlpy,
						1,_commandStackItem.commandStack);
				}
				if (!_commandStackItem.commandStack.length) trace('err')
				
				//not sure about this but it seems the best way temporarily
				_commandStackItem.end.x = nlpx;
				_commandStackItem.end.y = nlpy;
				
				//update the stack being built
				if(isNewItem){
					commandStack.addItem(_commandStackItem);
				}
				
				//update this segment's point references
				this.lastPoint.x = lastPoint.x;
				this.lastPoint.y = lastPoint.y;
				this.lastControlPoint.x = lastControlPoint.x;
				this.lastControlPoint.y = lastControlPoint.y;	
			}
						
			//update the buildFlashCommandStack Point tracking reference
			lastPoint.x = nlpx;
			lastPoint.y = nlpy;
			lastControlPoint.x = nlcpx;
			lastControlPoint.y = nlcpy;
						
			//pre calculate the bounds for this segment
			preDraw();
			
		}
			
		
	}
}