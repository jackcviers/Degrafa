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
		
		public function CommandStackItem(type:int=0,x:Number=NaN,y:Number=NaN,x1:Number=NaN,y1:Number=NaN,cx:Number=NaN,cy:Number=NaN,originX:Number=NaN,originY:Number=NaN,commandStack:CommandStack=null){
			this.type = type;
			
			this.x=x;
			this.y=y;
			this.x1=x1;
			this.y1=y1;
			this.cx=cx;
			this.cy=cy;
			this.originX=originX;
			this.originY=originY;
			
			this.commandStack = commandStack;
			
			initPoints();
			
			registerClassAlias("com.degrafa.geometry.command.CommandStackItem", CommandStackItem);
			
		}
		
		private function initPoints():void{
			start.x = originX;
			start.y = originY;
			
			control.x = (cx)? cx:0;
			control.y = (cy)? cy:0;
			
			end.x = (type==1 || type==0)? x:x1;
			end.y = (type==1 || type==0)? y:y1;
		}
				
		public var type:int;
		public var id:String;
		public var reference:String;
		
		//Line or move to
		public var x:Number;
		public var y:Number;
		
		//curve only
		public var x1:Number;
		public var y1:Number;
		public var cx:Number;
		public var cy:Number;
		
		// Origin point 
		public var originX:Number;
		public var originY:Number;
				
		// Function used in a DELEGATE_TO command
		public var delegate:Function;
		
		public var commandStack:CommandStack;
				
		/**
		* Returns the length of the this segment
		**/
		private var _segmentLength:Number=0;
		public function get segmentLength():Number{
			if(!_segmentLength){
				switch(type){
					case CommandStackItem.LINE_TO:
						_segmentLength =lineLength(originX,originY,x,y);
						break;
					case CommandStackItem.CURVE_TO:
						_segmentLength =curveLength();
						break;
					
					case CommandStackItem.COMMAND_STACK:
						_segmentLength =commandStack.pathLength();
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
				case CommandStackItem.LINE_TO:
					return pointAt(t,originX,originY,x,y);
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
				case CommandStackItem.LINE_TO:
					return angle(originX,originY,x,y);
				case CommandStackItem.CURVE_TO:
					return curveAngleAt(t);
				case CommandStackItem.COMMAND_STACK:
					return commandStack.pathAngleAt(t);
					
				default:
					return 0;		
			}
			
		}
		
		
		/**
		* Returns the length of a line.
		**/
		private function lineLength(x:Number,y:Number,x1:Number,y1:Number):Number {
			var dx:Number = x - x1;
			var dy:Number = y - y1;
			return Math.sqrt(dx*dx + dy*dy);
		}

		/**
		* Returns the length of a quadratic curve
		**/
		private function curveLength(accuracy:Number=5):Number {
						
			var dx:Number = x1 - originX;
			var dy:Number = y1 - originY;
			var cx:Number = (cx - originX)/dx;
			var cy:Number = (cy - originY)/dy;
			var f1:Number;
			var f2:Number;
			var t:Number;
			var d:Number = 0;
			var p:Point = new Point(originX,originY);
			var np:Point;
			var i:Number;
			for (i=1; i<accuracy; i++){
				t = i/accuracy;
				f1 = 2*t*(1 - t);
				f2 = t*t;
				np = new Point(originX + dx*(f1*cx + f2), originY + dy*(f1*cy + f2));
				d += lineLength(p.x,p.y,np.x,np.y);
				p = np;
			}
			return d + lineLength(p.x,p.y, x1,y1);
		}

		/**
		* Returns the point on the line at t (0-1) of a line.
		**/
		private function pointAt(t:Number, x:Number,y:Number,x1:Number,y1:Number):Point {
			var dx:Number = x1 - x;
			var dy:Number = y1 - y;
			return new Point(x + dx*t, y + dy*t);
		}
	
	
		/**
		* Returns the point on a quadratic curve at t (0-1) of a curve.
		**/
		private function curvePointAt(t:Number):Point {
			var p1:Point = Point.interpolate(control, start, t);
			var p2:Point = Point.interpolate(end, control, t);
			return Point.interpolate(p2, p1, t);
		}
		
		/**
		* returns the angle at point t (0-1) on a curve
		**/
		private function curveAngleAt(t:Number):Number {
			var startPoint:Point = pointAt(t, start.x,start.y, control.x,control.y);
			var endPoint:Point = pointAt(t, control.x,control.y, end.x,end.y);
			return angle(startPoint.x,startPoint.y, endPoint.x,endPoint.y);
		}

		/**
		* Returns the angle between 2 points.
		**/
		private function angle(x:Number,y:Number, x1:Number,y1:Number):Number {
			return Math.atan2(y1 - y, x1 - x);
		}
		
	}
}