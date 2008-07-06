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
	
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	
	public class CommandStackItem{
		
		public static const MOVE_TO:int=0;
		public static const LINE_TO:int=1;
		public static const CURVE_TO:int=2;
		public static const DELEGATE_TO:int=3;
		public static const COMMAND_STACK:int=4;
		
		public var start:Point = new Point();
		public var control:Point = new Point();
		public var end:Point = new Point();
		
		private static var isRegistered:Boolean = false;
		
		public function CommandStackItem(type:int=0,x:Number=NaN,y:Number=NaN,x1:Number=NaN,y1:Number=NaN,cx:Number=NaN,cy:Number=NaN,originX:Number=NaN,originY:Number=NaN,commandStack:CommandStack=null){
			
			this.type = type;
			_x=x;
			_y=y;
			_x1=x1;
			_y1=y1;
			_cx=cx;
			_cy=cy;
			this.originX=originX;
			this.originY=originY;
			this.commandStack = commandStack;
			
			initPoints();
			
			if(!isRegistered){
				registerClassAlias("com.degrafa.geometry.command.CommandStackItem", CommandStackItem);
				registerClassAlias("flash.geom.Point", Point);
				isRegistered = true;
			}
		}
		
		public function initPoints():void{
			start.x = originX;
			start.y = originY;
			
			control.x = (_cx)? _cx:0;
			control.y = (_cy)? _cy:0;
			
			end.x = (type==1 || type==0)? _x:_x1;
			end.y = (type==1 || type==0)? _y:_y1;
			
			invalidated=true;			
		}
		
		public var type:int;
		public var id:String;
		public var reference:String;
		
		public var invalidated:Boolean;
		
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
		 * x value before a change to the drawing position
		 */		
		public var originX:Number;
		/**
		 * y value before a change to the drawing position
		 */	
		public var originY:Number;
				
		/**
		 * Function to be called during the draw loop 
		 */		
		public var delegate:Function;
		
		public var commandStack:CommandStack;
				
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
			
			if (!originX){originX=value.originX;}
			if (!originY){originY=value.originY;}
			
			if (!reference){reference=value.reference;}
			
			invalidated = true;
		}
	}
}