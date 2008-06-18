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
	import com.degrafa.geometry.utilities.ArcUtils;
	import com.degrafa.geometry.utilities.GeometryUtils;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	[Exclude(name="isShortSequence", kind="property")]
	
	//--------------------------------------
	//  Other metadata
	//--------------------------------------
	
	[IconFile("EllipticalArcTo.png")]
	
	//(A or a) path data command
	[Bindable]	
	
	/**
	* Defines an elliptical arc (A,a) segment from the current point.
	*  
	* @see http://www.w3.org/TR/SVG/paths.html#PathDataEllipticalArcCommands 
	**/
	public class EllipticalArcTo extends Segment implements ISegment{
		
		/**
	 	* Constructor.
	 	*  
	 	* <p>The EllipticalArcTo constructor accepts 9 optional arguments that define it's 
	 	* data, properties and a coordinate type.</p>
	 	
	 	* @param rx A number indicating the x-coordinate radius of the arc.
	 	* @param ry A number indicating the y-coordinate radius of the arc..  
	 	* @param xAxisRotation A number indicating the x axis rotation of the arc.
	 	* @param largeArcFlag A number indicating if the arc is to use a large arc.
	 	* @param sweepFlag A number indicating if the arc is to use a sweep.
	 	* @param x A number indicating the x-coordinate of the end point of the arc. 
	 	* @param y A number indicating the y-coordinate of the end point of the arc.
	 	* @param data A string indicating the data to be used for this segment.
	 	* @param coordinateType A string indicating the coordinate type to be used for this segment.
	 	**/
		public function EllipticalArcTo(rx:Number=0,ry:Number=0,xAxisRotation:Number=0,
		largeArcFlag:Number=0,sweepFlag:Number=0,x:Number=0,y:Number=0,data:String=null,
		coordinateType:String="absolute"){
			
			this.rx =rx;
			this.ry =ry;
			this.xAxisRotation =xAxisRotation;
			this.largeArcFlag =largeArcFlag;
			this.sweepFlag =sweepFlag;
			this.x =x;
			this.y =y;
					
			
			this.data =data;
			this.coordinateType=coordinateType;
			this.isShortSequence = false;
			
				
		}
		
		/**
		* The isShortSequence property is ingnored on the EllipticalArcTo segment and 
		* setting it will have no effect. 
		**/
		override public function get isShortSequence():Boolean{return false;}
		override public function set isShortSequence(value:Boolean):void{}
		
		/**
		* Return the segment type
		**/
		override public function get segmentType():String{
			return "EllipticalArcTo";
		}
				
		/**
		* EllipticalArcTo short hand data value.
		* 
		* <p>The elliptical arc to data property expects exactly 7 values 
		* rx, ry, xAxisRotation, largeArcFlag, sweepFlag, x and y separated 
		* by spaces.</p>
		* 
		* @see Segment#data
		* 
		**/
		override public function set data(value:String):void{
			if(super.data != value){
				super.data = value;
				
				//parse the string on the space
				var tempArray:Array = value.split(" ");
				
				if (tempArray.length == 7)
				{
					_rx=tempArray[0]; //ry
					_ry=tempArray[1]; //rx
					_xAxisRotation=tempArray[2]; //x-axis-rotation  
					_largeArcFlag=tempArray[3]; //largeArcFlag
					_sweepFlag=tempArray[4]; //sweepFlag
					_x=tempArray[5]; //x end point
					_y=tempArray[6]; //y end point
					
				}
				invalidated = true;
			}
		}
												
		private var _rx:Number=0;
		/**
		* The x-coordinate radius of the arc. If not specified 
		* a default value of 0 is used.
		**/
		public function get rx():Number{
			return _rx;
		}
		public function set rx(value:Number):void{
			if(_rx != value){
				_rx = value;
				invalidated = true;
			}
		}
		
		
		private var _ry:Number=0;
		/**
		* The y-coordinate radius of the arc. If not specified 
		* a default value of 0 is used.
		**/
		public function get ry():Number{
			return _ry;
		}
		public function set ry(value:Number):void{			
			if(_ry != value){
				_ry = value;
				invalidated = true;
			}
			
		}
		
		
		private var _xAxisRotation:Number=0;
		/**
		* The x axis rotation of the arc. If not specified 
		* a default value of 0 is used.
		**/
		public function get xAxisRotation():Number{
			return _xAxisRotation;
		}
		public function set xAxisRotation(value:Number):void{	
			if(_xAxisRotation != value){
				_xAxisRotation = value;
				invalidated = true;
			}
			
		}
		
		
		
		private var _largeArcFlag:int=-1;
		/**
		* A value indicating if the arc is to use a large arc. 
		* A value of 0 = true and a value of 1 = false
		*
		* see@ http://www.w3.org/TR/SVG/paths.html#PathDataEllipticalArcCommands  
		**/
		public function get largeArcFlag():Number{
			return _largeArcFlag;
		}
		public function set largeArcFlag(value:Number):void{
			if(_largeArcFlag != value){
				_largeArcFlag = value;
				invalidated = true;
			}
		}
		
		
		private var _sweepFlag:int=-1;
		/**
		* A value indicating if the arc is to use a sweep. 
		* A value of 0 = true and a value of 1 = false
		*
		* see@ http://www.w3.org/TR/SVG/paths.html#PathDataEllipticalArcCommands  
		**/
		public function get sweepFlag():Number{
			return _sweepFlag;
		}
		public function set sweepFlag(value:Number):void{
			if(_sweepFlag != value){
				_sweepFlag = value;
				invalidated = true;
			}
		}
		
		private var _x:Number=0;
		/**
		* The x-coordinate of the end point of the arc. If not specified 
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
		* The y-coordinate of the end point of the arc. If not specified 
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
			return _bounds;	
		}
		
		/**
		* Calculates the bounds for this segment. 
		**/	
		private function calcBounds():void{
			
					
			if(_commandStackItem.type==CommandStackItem.COMMAND_STACK &&  _commandStackItem.commandStack.length==0){return;}
			var newx:Number = _absCoordType? x:lastPoint.x + x;
			var newy:Number = _absCoordType? y:lastPoint.y + y;
	
			var item:CommandStackItem;
			var lpX:Number;
			var lpY:Number;
			if (_bounds) {
				_bounds.x = Math.min(lastPoint.x, newx);
				_bounds.y = Math.min(lastPoint.y, newy);
				_bounds.bottom = Math.max(lastPoint.y, newy);
				_bounds.right = Math.max(lastPoint.x, newx);
				
			} else 	_bounds = new Rectangle(Math.min(lastPoint.x, newx), Math.min(lastPoint.y, newy), Math.abs(lastPoint.x - newx), Math.abs(lastPoint.y - newy));
			//handle the edge case where it could be a lineSegment (in which case we've already got the bounds)
			if (_commandStackItem.type == CommandStackItem.LINE_TO) {
				//deal with horizontal or vertical lines
				if (_bounds.width == 0) _bounds.width = 0.0001;
				if (_bounds.height == 0) _bounds.height = 0.0001;
				return;
			}
			//otherwise it's a regular commandStack of quadratic beziers
			//TODO: implement a (presumably) faster geometric bounds calculation in ArcUtils based on the arcTo parameters alone
			for each(item in _commandStackItem.commandStack.source){
				with(item)
					{
						_bounds = _bounds.union(GeometryUtils.bezierBounds(lpX?lpX:lastPoint.x, lpY?lpY:lastPoint.y, cx, cy, x1, y1));
						lpX = x1;
						lpY = y1;

					}

			}
	  				
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
		
			
			if (!invalidated )
			{
				invalidated= (!lastPoint.equals(this.lastPoint)  )
			}
			//precalc new last point tracking values
			var nlpx:Number = _absCoordType? x :lastPoint.x + _x;
			var nlpy:Number = _absCoordType? y : lastPoint.y + _y ;
			
			//edge case: if lastpoint and endpoint are the same, then ignore this arc segment (SVG implementation notes: F.6.2 Out-of-range parameters)
			if (nlpx == lastPoint.x && nlpy == lastPoint.y)
			{
				_bounds = new Rectangle(nlpx, nlpy, 0, 0);
				//or maybe:
				//_bounds = new Rectangle(nlpx, nlpy, 0.0001, 0.0001);
				invalidated = false;
				return;
			}
			
			//test if anything has changed and only recalculate if something has
			if(invalidated){
			
				var isNewItem:Boolean;
				
				//edge case: if either of the radii are zero, it's a straight line (SVG implementation notes)
				if (_rx == 0 || _ry == 0) {
					if (!_commandStackItem || _commandStackItem.type != CommandStackItem.LINE_TO)
					{
						_commandStackItem = new CommandStackItem(CommandStackItem.LINE_TO, nlpx, nlpy);
					} else {
						_commandStackItem.x = nlpx;
						_commandStackItem.y = nlpy;
					}
				} else {	
					
				if(!_commandStackItem){
					_commandStackItem = new CommandStackItem(CommandStackItem.COMMAND_STACK,
					NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,new CommandStack());
					
					isNewItem = true;
				}	
			
				var computedArc:Object = ArcUtils.computeSvgArc(_rx,_ry,xAxisRotation,Boolean(_largeArcFlag),
				Boolean(_sweepFlag), nlpx, nlpy , lastPoint.x, lastPoint.y);
		        
		        ArcUtils.drawArc(computedArc.x,computedArc.y,computedArc.startAngle,
		        computedArc.arc,computedArc.radius,computedArc.yRadius,
		        computedArc.xAxisRotation,_commandStackItem.commandStack);
				}
				//add the move to at the start of this stack
				//_commandStackItem.commandStack.source.unshift(new CommandStackItem(CommandStackItem.MOVE_TO,computedArc.x,computedArc.y));
				
				//update the stack being built
				if(isNewItem){
					commandStack.addItem(_commandStackItem);
				}
				
				//update this segment's point references
				this.lastPoint.x = lastPoint.x;
				this.lastPoint.y = lastPoint.y;
			}
			
			//update the buildFlashCommandStack Point tracking reference
        	lastPoint.x = nlpx;
			lastPoint.y = nlpy;
			
			//pre calculate the bounds for this segment
			preDraw();
					
		}
			
	}
}