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
	
	import com.degrafa.IGeometryComposition;
	import com.degrafa.core.collections.DegrafaCursor;
	import com.degrafa.core.utils.CloneUtil;
	import com.degrafa.decorators.IDrawDecorator;
	import com.degrafa.geometry.Geometry;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CommandStack{
		
		public var source:Array = [];
		public var cmdSource:Array;
		public var pointer:Point = new Point(0,0);
		public var graphics:Graphics;
		
		//used to store the origin at creation time as items are added
		//and used to set the origin in the items as they are created
		private var currentPointX:Number=0;
		private var currentPointY:Number=0;
		
		private var lengthIsValid:Boolean;
		
		public var owner:Geometry;
		
		public function CommandStack(geometry:Geometry = null){
			super();
			
			this.owner = geometry;
		}
		
		public function draw(graphics:Graphics,rc:Rectangle):void{
			
			this.graphics = graphics;
						
			//exit if no command stack
			if(source.length==0){return;}
			
			if(owner.transform){
				owner.transform.apply(owner);
			}
						
			//setup the stroke
			owner.initStroke(graphics,rc);
			
			//setup the fill
			owner.initFill(graphics,rc);
			
			if(owner.decorators.length !=0){
				cmdSource = CloneUtil.clone(source)
				_cursor = new DegrafaCursor(cmdSource);
				
				for each(var decorator:Object in owner.decorators){
					if(decorator is IDrawDecorator){
						decorator.execute(this);
					}
				}
			
			}
			else{
				_cursor = new DegrafaCursor(source);	
			}
			
			renderCommandStack(_cursor);
			        	
        	if(owner.decorators.length !=0){
        		cmdSource.length = 0;
        	}
        	
        	endDraw(graphics);
		}
		
		private function renderCommandStack(cursor:DegrafaCursor=null):void{
			
			var item:CommandStackItem;
			while(cursor.moveNext()){	   			
	   			
	   			item = cursor.current;
					
				switch(item.type){
					
        			case CommandStackItem.MOVE_TO:
        				graphics.moveTo(item.x,item.y);
        				break;
        			
        			case CommandStackItem.LINE_TO:
        				graphics.lineTo(item.x,item.y);
        				break;
        			
        			case CommandStackItem.CURVE_TO:
        				graphics.curveTo(item.cx,item.cy,item.x1,item.y1);
        				break;
        				
        			case CommandStackItem.DELEGATE_TO:
        				item.delegate(this);
        				break;
        			
        			case CommandStackItem.COMMAND_STACK:
        				renderCommandStack(new DegrafaCursor(item.commandStack.source))
        		
        		}
        		
        		updatePointer(item);
        	}
			
				
		}
		
		protected function endDraw(graphics:Graphics):void{
			if (owner.fill){ 
	        	owner.fill.end(graphics);  
	        }
	        
	        //draw children
	        if (owner.geometry){
				for each (var geometryItem:IGeometryComposition in owner){
					geometryItem.draw(graphics,null);
				}
			}
	    }
		
		//create and add move to item
		public function addMoveTo(x:Number,y:Number):void{
			source.push(new CommandStackItem(CommandStackItem.MOVE_TO,
			x,y,NaN,NaN,NaN,NaN,currentPointX,currentPointY));
			
			currentPointX =x;
			currentPointY =y;
		}
		
		//create and add line to item
		public function addLineTo(x:Number,y:Number):void{
			source.push(new CommandStackItem(CommandStackItem.LINE_TO,
			x,y,NaN,NaN,NaN,NaN,currentPointX,currentPointY));
			
			currentPointX =x;
			currentPointY =y;
			
			lengthIsValid = false;
		}
		
		//create and add curve to item
		public function addCurveTo(cx:Number,cy:Number,x1:Number,y1:Number):void{
			source.push(new CommandStackItem(CommandStackItem.CURVE_TO,
			NaN,NaN,x1,y1,cx,cy,currentPointX,currentPointY));
			
			currentPointX =x1;
			currentPointY =y1;
		
			lengthIsValid = false;
		}
		
		//create and add delegate function item
		public function addDelegate(delegate:Function):void{
			source.push(new CommandStackItem(CommandStackItem.DELEGATE_TO));
		}
		
		//create and add command stack item
		public function addCommandStack(commandStack:CommandStack):void{
			source.push(new CommandStackItem(CommandStackItem.COMMAND_STACK,
			NaN,NaN,NaN,NaN,NaN,NaN,currentPointX,currentPointY,commandStack));
			
			//currentPointX =x;
			//currentPointY =y;
			
		}
		
		public function getItem(index:int):CommandStackItem{
			return source[index];
		}
		
		//add an already created item		
		public function addItem(value:CommandStackItem):void{
			
			value.originX=currentPointX;
			value.originY=currentPointY;
			currentPointX =value.end.x;
			currentPointY =value.end.y;
					
			source.push(value);
			
			if(value.type != CommandStackItem.COMMAND_STACK){
				lengthIsValid = false;
			}
			
		}
		
		protected function updatePointer(item:CommandStackItem):void{
			item.originX = pointer.x;
			item.originY = pointer.y;
			
			pointer.x = item.end.x;
			pointer.y = item.end.y;
			
		}
				
		protected var _cursor:DegrafaCursor;
		public function get cursor():DegrafaCursor{
			if(!_cursor)
				_cursor = new DegrafaCursor(source);
				
			return _cursor;
		}
		
		public function get length():int {
			return source.length;
		}
		
		public function set length(v:int):void {
			source.length = v;
		}
		
		private var _pathLength:Number=0;
		/**
		* Returns the length of the combined path elements.
		**/
		public function pathLength():Number{
			if(!lengthIsValid){
				lengthIsValid = true;
				for each (var item:CommandStackItem in source){
					_pathLength += item.segmentLength;
				}
			}
			return _pathLength;
		}
		
		/**
		* Returns the point at t(0-1) on the path.
		**/
		public function pathPointAt(t:Number):Point {
			t = cleant(t);
			if (t == 0){
				return CommandStackItem(source[0]).segmentPointAt(t);
				
			}else if (t == 1){
				var last:Number = source.length - 1;
				return source[last].segmentPointAt(t);
			}
			
			var tLength:Number = t*pathLength();
			var curLength:Number = 0;
			var lastLength:Number = 0;
			var seg:CommandStackItem;
			var n:Number = source.length;
			var i:Number;
			
			for (i=0; i<n; i++){
				seg = source[i];
				if (seg.type != 0){
					curLength += seg.segmentLength;
				}
				else{
					continue;
				}
				if (tLength <= curLength){
					trace(seg.segmentPointAt((tLength - lastLength)/seg.segmentLength));
					return seg.segmentPointAt((tLength - lastLength)/seg.segmentLength);
				}
				lastLength = curLength;
			}
			
			return new Point(0, 0);

		}
		
		/**
		* Returns the angle of a point t(0-1) on the path.
		**/
		public function pathAngleAt(t:Number):Number {
			t = cleant(t);
			
			var tLength:Number = t*pathLength();
			var curLength:Number = 0;
			var lastLength:Number = 0;
			var seg:CommandStackItem;
			var n:Number = source.length;
			var i:Number;
			
			for (i=0; i<n; i++){
				seg = source[i];
				
				if (seg.type != 0){
					curLength += seg.segmentLength;
				}
				else{
					continue;
				}
				
				if (tLength <= curLength){
					return seg.segmentAngleAt((tLength - lastLength)/seg.segmentLength);
				}
				lastLength = curLength;
			}
			return 0;
		}

		
		private function cleant(t:Number, base:Number=NaN):Number {
			if (isNaN(t)) t = base;
			else if (t < 0 || t > 1){
				t %= 1;
				if (t == 0) t = base;
				else if (t < 0) t += 1;
			}
			return t;
		}


		
	}
}