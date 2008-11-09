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
package com.degrafa.geometry.command{
	
	import com.degrafa.geometry.utilities.GeometryUtils;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	
	public class CommandStackItem{
		
		public static const MOVE_TO:int=0;
		public static const LINE_TO:int=1;
		public static const CURVE_TO:int=2;
		public static const DELEGATE_TO:int=3;
		public static const COMMAND_STACK:int=4;
						
		public var type:int;
		public var id:String;
		public var reference:String;
		
		public var invalidated:Boolean;
		
		private static var isRegistered:Boolean = false;
		
		public function CommandStackItem(type:int=0,x:Number=NaN,y:Number=NaN,x1:Number=NaN,y1:Number=NaN,cx:Number=NaN,cy:Number=NaN,commandStack:CommandStack=null){
			
			invalidated = true;
			
			this.type = type;
			_x=x;
			_y=y;
			_x1=x1;
			_y1=y1;
			_cx=cx;
			_cy=cy;
			
			if(commandStack){			
				this.commandStack = commandStack;
			}
									
			if(!isRegistered){
				registerClassAlias("com.degrafa.geometry.command.CommandStackItem", CommandStackItem);
				registerClassAlias("flash.geom.Point", Point);
				isRegistered = true;
			}
		}
		
		/**
		* A reference to the previouse item in the parent command stack.
		*/		
		private var _previous:CommandStackItem;
		public function get previous():CommandStackItem{
			return _previous;
		}
		public function set previous(value:CommandStackItem):void{
			if(_previous != value){
				_previous = value;
				
				//on set if this is a command stack then forward to the first item			
				if(type==CommandStackItem.COMMAND_STACK){
					CommandStackItem(commandStack.source[0]).previous = value;
				}
			}
		}
		
		/**
		* A reference to the next item in the parent command stack.
		*/		
		private var _next:CommandStackItem;
		public function get next():CommandStackItem{
			return _next;
		}
		public function set next(value:CommandStackItem):void{
			if(_next != value){
				_next = value;
				
				//on set if this is a command stack then forward to the last item			
				if(type==CommandStackItem.COMMAND_STACK){
					CommandStackItem(commandStack.source[commandStack.source.length-1]).next = value;
				}
				
			}
		}
		
		/**
		* The calculated bounds for this object.
		*/		
		private var _bounds:Rectangle;
		public function get bounds():Rectangle{
			return _bounds;
		}
				
		/**
		* Calculates the bounds for this item.
		**/
		public function calcBounds():void{
			
			if(!invalidated){return;}
			
			//using the previous item calculate the bounds for this object
			switch(type){
				
				case CommandStackItem.MOVE_TO:
					_bounds = new Rectangle(x,y,0.001,0.001);	
					break;			
				case CommandStackItem.LINE_TO:
					_bounds = new Rectangle(Math.min(x,start.x),Math.min(y,start.y),
					Math.abs(x-start.x),Math.abs(y-start.y));
					break;
			
				case CommandStackItem.CURVE_TO:
					_bounds = GeometryUtils.bezierBounds(start.x,start.y, cx, cy, x1, y1)
					break;
					
				case CommandStackItem.COMMAND_STACK:
					_bounds = commandStack.bounds;
					break;
			}
			
			//adjustment for horizontal and vertical lines
			if (_bounds.width == 0) _bounds.width = 0.0001;
			if (_bounds.height == 0) _bounds.height = 0.0001;
			
		}
		
				
		/**
		* Return the start point as a point object. This is considered to be
		* the previous segments end point. You can only get the start point 
		* you can not set it.
		**/
		public function get start():Point{
			if(_previous){
				return _previous.end.clone();
			}
			else{
				return new Point(0,0);
			}
			
			//TODO add case if the last item is a command stack type
			//unless decided to add the proper item in the case of 
			//command stack.
		
		
		}
		
		/**
		* Return the control point as a point object
		**/
		public function get control():Point{
			return new Point(cx,cy);
		}
		/**
		* Set the control point to the point value passed.
		**/
		public function set control(value:Point):void{
			cx = value.x;
			cy = value.y;
		}
		
		/**
		* Return the end point as a point object
		**/
		public function get end():Point{
			return new Point((type==1 || type==0)? _x:_x1,(type==1 || type==0)? _y:_y1);
		}
		
		/**
		* Set the end point to the point value passed.
		**/
		public function set end(value:Point):void{
			if (type==1 || type==0){
				x=value.x;
				y=value.y;
			}
			else{
				x1=value.x;
				y1=value.y;
			}
		}
		
		/**
		* Function to be called during the render loop when 
		* this item is encountered .
		*/		
		private var _delegate:Function;
		public function get delegate():Function{
			return _delegate;
		}
		public function set delegate(value:Function):void{
			if(_delegate != value){
				_delegate = value;
				invalidated = true;
			}
		}
		
		/**
		* Function to be called during the render loop when 
		* this item is about to be rendered.
		*/		
		private var _renderDelegateStart:Function;
		public function get renderDelegateStart():Function{
			return _renderDelegateStart;
		}
		public function set renderDelegateStart(value:Function):void{
			if(_renderDelegateStart != value){
				_renderDelegateStart = value;
				invalidated = true;
			}
		}
		
		/**
		* Function to be called during the render loop when 
		* this item has just been rendered.
		*/	
		private var _renderDelegateEnd:Function;
		public function get renderDelegateEnd():Function{
			return _renderDelegateEnd;
		}
		public function set renderDelegateEnd(value:Function):void{
			if(_renderDelegateEnd != value){
				_renderDelegateEnd = value;
				invalidated = true;
			}
		}
		
		
		
		
		/**
		* A nested command stack in the case of a command stack type
		**/
		private var _commandStack:CommandStack;
		public function get commandStack():CommandStack{
			return _commandStack;
		}
		public function set commandStack(value:CommandStack):void{
			if(_commandStack != value){
				_commandStack = value;
				invalidated = true;
			}
		}
		
		
		/**
		 * x coordinate for a LINE_TO or MOVE_TO
		 */		
		private var _x:Number;
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
		 * y coordinate for a LINE_TO or MOVE_TO
		 */
		private var _y:Number;
		public function get y():Number{
			return _y;
		}
		public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated = true;
			}
		}
		/**
		 *  x1 anchor point for a CURVE_TO
		 */		
		private var _x1:Number;
		public function get x1():Number{
			return _x1;
		}
		public function set x1(value:Number):void{
			if(_x1 != value){
				_x1 = value;
				invalidated = true;
			}
		}
		/**
		 *  y1 anchor point for CURVE_TO
		 */		
		private var _y1:Number;
		public function get y1():Number{
			return _y1;
		}
		public function set y1(value:Number):void{
			if(_y1 != value){
				_y1 = value;
				invalidated = true;
			}
		}
		/**
		 *  cx control point for a CURVE_TO
		 */
		private var _cx:Number;
		public function get cx():Number{
			return _cx;
		}
		public function set cx(value:Number):void{
			if(_cx != value){
				_cx = value;
				invalidated = true;
			}
		}
		/**
		 *  cy control point for a CURVE_TO
		 */
		private var _cy:Number;
		public function get cy():Number{
			return _cy;
		}
		public function set cy(value:Number):void{
			if(_cy != value){
				_cy = value;
				invalidated = true;
			}
		}
				
		/**
		* Returns the length of the this segment
		**/
		private var _segmentLength:Number=0;
		public function get segmentLength():Number{
			if(!_segmentLength || invalidated){
				switch(type){
					case CommandStackItem.MOVE_TO:
						_segmentLength =0;
						break;		
					case CommandStackItem.LINE_TO:
						_segmentLength =lineLength(start,end);
						break;
					case CommandStackItem.CURVE_TO:
						_segmentLength =curveLength();
						break;
					case CommandStackItem.COMMAND_STACK:
						_segmentLength =commandStack.pathLength;
						break;
					default:
						_segmentLength =0;
						break;		
				}
			}
			return _segmentLength;
			
		}
		
		/**
		* Returns the point on this segment at t (0-1)
		**/
		public function segmentPointAt(t:Number):Point{
			
			switch(type){
				case CommandStackItem.MOVE_TO:
					return start.clone();
				case CommandStackItem.LINE_TO:
					return linePointAt(t,start,end);
				case CommandStackItem.CURVE_TO:
					return curvePointAt(t);
				case CommandStackItem.COMMAND_STACK:
					return commandStack.pathPointAt(t);
				default:
					return null;		
			}
		}
		
		/**
		* Returns the angle of a point on this segment at t (0-1)
		**/
		public function segmentAngleAt(t:Number):Number{
			
			switch(type){
				case CommandStackItem.MOVE_TO:
					return 0;
				case CommandStackItem.LINE_TO:
					return lineAngleAt(t);
				case CommandStackItem.CURVE_TO:
					return curveAngleAt(t);
				case CommandStackItem.COMMAND_STACK:
					return commandStack.pathAngleAt(t);
				default:
					return 0;		
			}
			
		}
		
		//Based on code from Trevor McCauley, www.senocular.com
		/**
		* Returns the point on the line at t (0-1) of a line.
		**/
		private function linePointAt(t:Number, startPt:Point = null, endPt:Point = null):Point {
			if (!startPt) startPt = start;
			if (!endPt) endPt = end;
			var dx:Number = endPt.x - startPt.x;
			var dy:Number = endPt.y - startPt.y;
			return new Point(startPt.x + dx*t, startPt.y + dy*t);
		}

		/**
		* Returns the angle between start and end point.
		**/
		private function lineAngleAt(t:Number, startPt:Point = null, endPt:Point = null):Number {
			if (!startPt) startPt = start;
			if (!endPt) endPt = end;
			return Math.atan2(endPt.y - startPt.y, endPt.x - startPt.x);
		}

		/**
		* Returns the length of a line.
		**/
		private function lineLength(startPt:Point = null, endPt:Point = null):Number {
			if (!startPt) startPt = start;
			if (!endPt) endPt = end;
			var dx:Number = endPt.x - startPt.x;
			var dy:Number = endPt.y - startPt.y;
			return Math.sqrt(dx*dx + dy*dy);
		}
		
		
		/**
		* Returns the length of a quadratic curve
		**/
		private function curveLength(curveAccuracy:int=5,startPt:Point = null, controlPt:Point = null, endPt:Point = null):Number {
		
			if (!startPt) startPt = start;
			if (!controlPt) controlPt = control;
			if (!endPt) endPt = end;

			var dx:Number = endPt.x - startPt.x;
			var dy:Number = endPt.y - startPt.y;
			var cx:Number = (dx == 0) ? 0 : (controlPt.x - startPt.x)/dx;
			var cy:Number = (dy == 0) ? 0 : (controlPt.y - startPt.y)/dy;
			var f1:Number;
			var f2:Number;
			var t:Number;
			var d:Number = 0;
			var p:Point = startPt;
			var np:Point;
			var i:int;
			
			for (i=1; i<curveAccuracy; i++){
				t = i/curveAccuracy;
				f1 = 2*t*(1 - t);
				f2 = t*t;
				np = new Point(startPt.x + dx*(f1*cx + f2), startPt.y + dy*(f1*cy + f2));
				d += lineLength(p, np);
				p = np;
			}
			
			return d + lineLength(p, endPt);
			
		}
		
		/**
		* Returns the point on a curve at t (0-1) of a curve.
		**/
		private function curvePointAt(t:Number, startPt:Point = null, endPt:Point = null):Point {
			var p1:Point = Point.interpolate(control,start, t);
			var p2:Point = Point.interpolate(end, control, t);
			return Point.interpolate(p2, p1, t);
		}
		
		/**
		* Returns the angle of a point at t (0-1) a curve
		**/
		private function curveAngleAt(t:Number, startPt:Point = null, endPt:Point = null):Number {
			var startPt:Point = linePointAt(t,start, control);
			var endPt:Point = linePointAt(t, control, end);
			return lineAngleAt(t, startPt, endPt);
		}
		
		
		/**
		* An object to derive this objects properties from. When specified this 
		* object will derive it's unspecified properties from the passed object.
		**/
		public function derive(value:CommandStackItem):void
		{
			if (!type){type=value.type;}
			
			if (!x){_x=value.x;}
			if (!y){_y=value.y;}
			
			if (!x1){_x1=value.x1;}
			if (!y1){_y1=value.y1;}
			if (!cx){_cx=value.cx;}
			if (!cy){_cy=value.cy;}
						
			if (!reference){reference=value.reference;}
			
			invalidated = true;
		}
	}
}